import "dart:async";
import "dart:developer";
import "dart:io";
import "dart:ui";

import "package:dynamic_color/dynamic_color.dart";
import "package:financemate/constants.dart";
import "package:financemate/entity/profile.dart";
import "package:financemate/entity/transaction.dart";
import "package:financemate/l10n/flow_localizations.dart";
import "package:financemate/objectbox.dart";
import "package:financemate/objectbox/actions.dart";
import "package:financemate/prefs.dart";
import "package:financemate/routes.dart";
import "package:financemate/services/exchange_rates.dart";
import "package:financemate/theme/color_themes/registry.dart";
import "package:financemate/theme/flow_color_scheme.dart";
import "package:financemate/theme/theme.dart";
import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:intl/intl.dart";
import "package:moment_dart/moment_dart.dart";
import "package:package_info_plus/package_info_plus.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const String debugBuildSuffix = debugBuild ? " (dev)" : "";

  unawaited(PackageInfo.fromPlatform()
      .then((value) =>
          appVersion = "${value.version}+${value.buildNumber}$debugBuildSuffix")
      .catchError((e) {
    log("An error was occured while fetching app version: $e");
    return appVersion = "<unknown>+<0>$debugBuildSuffix";
  }));

  if (flowDebugMode) {
    FlowLocalizations.printMissingKeys();
  }

  /// [ObjectBox] MUST initialize before [LocalPreferences] because prefs
  /// access [ObjectBox] upon initialization.
  await ObjectBox.initialize();
  await LocalPreferences.initialize();

  /// Set `sortOrder` values if there are any unset (-1) values
  await ObjectBox().updateAccountOrderList(ignoreIfNoUnsetValue: true);

  ExchangeRatesService().init();

  try {
    LocalPreferences().privacyMode.addListener(
          () => LocalPreferences().sessionPrivacyMode.set(
                LocalPreferences().privacyMode.get(),
              ),
        );
  } catch (e) {
    log("Failed to add listener updates prefs.sessionPrivacyMode");
  }

  runApp(const Flow());
}

class Flow extends StatefulWidget {
  const Flow({super.key});

  @override
  State<Flow> createState() => FlowState();

  static FlowState of(BuildContext context) =>
      context.findAncestorStateOfType<FlowState>()!;
}

class FlowState extends State<Flow> {
  Locale _locale = FlowLocalizations.supportedLanguages.first;
  ThemeMode _themeMode = ThemeMode.system;

  ThemeFactory _themeFactory = ThemeFactory.fromThemeName(null);

  ThemeMode get themeMode => _themeMode;

  bool get useDarkTheme => (_themeMode == ThemeMode.system
      ? (PlatformDispatcher.instance.platformBrightness == Brightness.dark)
      : (_themeMode == ThemeMode.dark));

  @override
  void initState() {
    super.initState();

    _reloadLocale();
    _reloadTheme();

    LocalPreferences().localeOverride.addListener(_reloadLocale);
    LocalPreferences().themeName.addListener(_reloadTheme);
    LocalPreferences().primaryCurrency.addListener(_refreshExchangeRates);

    ObjectBox().box<Transaction>().query().watch().listen((event) {
      ObjectBox().invalidateAccountsTab();
    });

    if (ObjectBox().box<Profile>().count(limit: 1) == 0) {
      Profile.createDefaultProfile();
    }
  }

  @override
  void dispose() {
    LocalPreferences().localeOverride.removeListener(_reloadLocale);
    LocalPreferences().themeName.removeListener(_reloadTheme);
    LocalPreferences().primaryCurrency.removeListener(_refreshExchangeRates);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DynamicColorBuilder(
      builder: (dynamicLight, dynamicDark) {
        return MaterialApp.router(
          onGenerateTitle: (context) => "appName".t(context),
          localizationsDelegates: [
            GlobalMaterialLocalizations.delegate,
            if (flowDebugMode || Platform.isIOS)
              GlobalCupertinoLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            FlowLocalizations.delegate,
          ],
          supportedLocales: FlowLocalizations.supportedLanguages,
          locale: _locale,
          routerConfig: router,
          theme: _themeFactory.materialTheme,
          themeMode: _themeMode,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }

  void _reloadTheme() {
    final String? themeName = LocalPreferences().themeName.value;

    log("[Theme] Reloading theme $themeName");

    FlowColorScheme theme = getTheme(themeName, useDarkTheme);

    setState(() {
      _themeMode = theme.mode;
      _themeFactory = ThemeFactory(theme);
    });
  }

  void _reloadLocale() {
    final List<Locale> systemLocales =
        WidgetsBinding.instance.platformDispatcher.locales;

    final List<Locale> favorableLocales = systemLocales
        .where(
          (locale) => FlowLocalizations.supportedLanguages.any(
              (flowSupportedLocalization) =>
                  flowSupportedLocalization.languageCode ==
                  locale.languageCode),
        )
        .toList();

    final Locale overriddenLocale = LocalPreferences().localeOverride.value ??
        favorableLocales.firstOrNull ??
        _locale;

    _locale =
        Locale(overriddenLocale.languageCode, overriddenLocale.countryCode);
    Moment.setGlobalLocalization(
      MomentLocalizations.byLocale(overriddenLocale.code) ??
          MomentLocalizations.enUS(),
    );

    Intl.defaultLocale = overriddenLocale.code;
    setState(() {});
  }

  void _refreshExchangeRates() {
    ExchangeRatesService().tryFetchRates(
      LocalPreferences().getPrimaryCurrency(),
    );
  }
}

import "dart:developer";
import "dart:io";

import "package:app_settings/app_settings.dart";
import "package:financemate/l10n/flow_localizations.dart";
import "package:financemate/prefs.dart";
import "package:financemate/routes/preferences/language_selection_sheet.dart";
import "package:financemate/theme/color_themes/registry.dart";
import "package:financemate/theme/flow_color_scheme.dart";
import "package:financemate/widgets/select_currency_sheet.dart";
import "package:flutter/material.dart" hide Flow;
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class PreferencesPage extends StatefulWidget {
  const PreferencesPage({super.key});

  @override
  State<PreferencesPage> createState() => _PreferencesPageState();
}

class _PreferencesPageState extends State<PreferencesPage> {
  bool _currencyBusy = false;
  bool _languageBusy = false;

  @override
  Widget build(BuildContext context) {
    final FlowColorScheme currentTheme =
        getTheme(LocalPreferences().themeName.get());

    final bool enableGeo = LocalPreferences().enableGeo.get();
    final bool enableHapticFeedback =
        LocalPreferences().enableHapticFeedback.get();
    final bool autoAttachTransactionGeo =
        LocalPreferences().autoAttachTransactionGeo.get();
    final bool requirePendingTransactionConfrimation =
        LocalPreferences().requirePendingTransactionConfrimation.get();

    return Scaffold(
      appBar: AppBar(
        title: Text("preferences".t(context)),
      ),
      body: SafeArea(
        child: ListView(children: [
          ListTile(
            title: Text("preferences.pendingTransactions".t(context)),
            subtitle: Text(
              requirePendingTransactionConfrimation
                  ? "general.enabled".t(context)
                  : "general.disabled".t(context),
            ),
            leading: const Icon(Symbols.schedule_rounded),
            onTap: openPendingTransactionsPrefs,
            // subtitle: Text(FlowLocalizations.of(context).locale.endonym),
            trailing: const Icon(Symbols.chevron_right_rounded),
          ),
          ListTile(
            title: Text("preferences.theme".t(context)),
            leading: currentTheme.isDark
                ? const Icon(Symbols.dark_mode_rounded)
                : const Icon(Symbols.light_mode_rounded),
            subtitle: Text(currentTheme.name),
            onTap: openTheme,
            trailing: const Icon(Symbols.chevron_right_rounded),
          ),
          ListTile(
            title: Text("preferences.language".t(context)),
            leading: const Icon(Symbols.language_rounded),
            onTap: () => updateLanguage(),
            subtitle: Text(FlowLocalizations.of(context).locale.endonym),
            trailing: const Icon(Symbols.chevron_right_rounded),
          ),
          ListTile(
            title: Text("preferences.primaryCurrency".t(context)),
            leading: const Icon(Symbols.universal_currency_alt_rounded),
            onTap: () => updatePrimaryCurrency(),
            subtitle: Text(LocalPreferences().getPrimaryCurrency()),
            trailing: const Icon(Symbols.chevron_right_rounded),
          ),
          ListTile(
            title: Text("preferences.numpad".t(context)),
            leading: const Icon(Symbols.dialpad_rounded),
            onTap: () => pushAndRefreshAfter("/preferences/numpad"),
            subtitle: Text(
              LocalPreferences().usePhoneNumpadLayout.get()
                  ? "preferences.numpad.layout.modern".t(context)
                  : "preferences.numpad.layout.classic".t(context),
            ),
            trailing: const Icon(Symbols.chevron_right_rounded),
          ),
          ListTile(
            title: Text("preferences.transfer".t(context)),
            leading: const Icon(Symbols.sync_alt_rounded),
            onTap: () => pushAndRefreshAfter("/preferences/transfer"),
            subtitle: Text(
              "preferences.transfer.description".t(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Symbols.chevron_right_rounded),
          ),
          ListTile(
            title: Text("preferences.transactionButtonOrder".t(context)),
            leading: const Icon(Symbols.action_key_rounded),
            onTap: () =>
                pushAndRefreshAfter("/preferences/transactionButtonOrder"),
            subtitle: Text(
              "preferences.transactionButtonOrder.description".t(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Symbols.chevron_right_rounded),
          ),
          ListTile(
            title: Text("preferences.transactionGeo".t(context)),
            leading: const Icon(Symbols.location_pin_rounded),
            onTap: openTransactionGeo,
            subtitle: Text(
              enableGeo
                  ? (autoAttachTransactionGeo
                      ? "preferences.transactionGeo.auto.enabled".t(context)
                      : "general.enabled".t(context))
                  : "general.disabled".t(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Symbols.chevron_right_rounded),
          ),
          ListTile(
            title: Text("preferences.moneyFormatting".t(context)),
            leading: const Icon(Symbols.numbers_rounded),
            onTap: () => pushAndRefreshAfter("/preferences/moneyFormatting"),
            trailing: const Icon(Symbols.chevron_right_rounded),
          ),
          ListTile(
            title: Text("preferences.privacyMode".t(context)),
            leading: const Icon(Symbols.password_rounded),
            onTap: () => pushAndRefreshAfter("/preferences/privacy"),
            trailing: const Icon(Symbols.chevron_right_rounded),
          ),
          ListTile(
            title: Text("preferences.hapticFeedback".t(context)),
            leading: const Icon(Symbols.vibration_rounded),
            onTap: () => pushAndRefreshAfter("/preferences/haptics"),
            subtitle: Text(
              enableHapticFeedback
                  ? "general.enabled".t(context)
                  : "general.disabled".t(context),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: const Icon(Symbols.chevron_right_rounded),
          ),
        ]),
      ),
    );
  }

  void updateLanguage() async {
    if (Platform.isIOS) {
      await LocalPreferences().localeOverride.remove().catchError((e) {
        log("[PreferencesPage] failed to remove locale override: $e");
        return false;
      });
      try {
        await AppSettings.openAppSettings(type: AppSettingsType.appLocale);
        return;
      } catch (e) {
        log("[PreferencesPage] failed to open system app settings on iOS: $e");
      }
    }

    if (_languageBusy || !mounted) return;

    setState(() {
      _languageBusy = true;
    });

    try {
      Locale current = LocalPreferences().localeOverride.get() ??
          FlowLocalizations.supportedLanguages.first;

      final selected = await showModalBottomSheet<Locale>(
        context: context,
        builder: (context) => LanguageSelectionSheet(
          currentLocale: current,
        ),
      );

      if (selected != null) {
        await LocalPreferences().localeOverride.set(selected);
      }
    } finally {
      _languageBusy = false;
    }
  }

  void updatePrimaryCurrency() async {
    if (_currencyBusy) return;

    setState(() {
      _currencyBusy = true;
    });

    try {
      String current = LocalPreferences().getPrimaryCurrency();

      final selected = await showModalBottomSheet<String>(
        context: context,
        builder: (context) => SelectCurrencySheet(currentlySelected: current),
      );

      if (selected != null) {
        await LocalPreferences().primaryCurrency.set(selected);
      }
    } finally {
      _currencyBusy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void pushAndRefreshAfter(String path) async {
    await context.push(path);

    // Rebuild to update description text
    if (mounted) setState(() {});
  }

  void openTransactionGeo() async {
    await context.push("/preferences/transactionGeo");

    // Rebuild to update description text
    if (mounted) setState(() {});
  }

  void openPendingTransactionsPrefs() async {
    await context.push("/preferences/pendingTransactions");

    // Rebuild to update description text
    if (mounted) setState(() {});
  }

  void openTheme() async {
    await context.push("/preferences/theme");

    final bool themeChangesAppIcon =
        LocalPreferences().themeChangesAppIcon.get();

    trySetThemeIcon(
      themeChangesAppIcon ? LocalPreferences().themeName.get() : null,
    );

    // Rebuild to update description text
    if (mounted) setState(() {});
  }
}

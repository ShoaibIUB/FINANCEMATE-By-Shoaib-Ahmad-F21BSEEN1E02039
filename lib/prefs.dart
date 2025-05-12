import "dart:async";
import "dart:convert";
import "dart:developer";

import "package:financemate/data/exchange_rates_set.dart";
import "package:financemate/data/prefs/frecency.dart";
import "package:financemate/entity/account.dart";
import "package:financemate/entity/category.dart";
import "package:financemate/entity/transaction.dart";
import "package:financemate/objectbox.dart";
import "package:financemate/objectbox/objectbox.g.dart";
import "package:financemate/theme/color_themes/registry.dart";
import "package:intl/intl.dart";
import "package:local_settings/local_settings.dart";
import "package:moment_dart/moment_dart.dart";
import "package:shared_preferences/shared_preferences.dart";

/// This class contains everything that's stored on
/// device. Such as user preferences and per-device
/// settings
class LocalPreferences {
  final SharedPreferences _prefs;

  static const int pendingTransactionsHomeTimeframeDefault = 3;

  /// Main currency used in the app
  late final PrimitiveSettingsEntry<String> primaryCurrency;

  /// Whether to use phone numpad layout
  ///
  /// When set to true, 1 2 3 will be the top row like
  /// in a modern dialpad
  late final BoolSettingsEntry usePhoneNumpadLayout;

  /// Whether to enable haptic feedback upon certain actions
  late final BoolSettingsEntry enableHapticFeedback;

  /// Whether to combine transfer transactions in the transaction list
  ///
  /// Doesn't necessarily combine the transactions, but rather
  /// shows them as a single transaction in the transaction list
  ///
  /// It will not work in transactions list where a filter has applied
  late final BoolSettingsEntry combineTransferTransactions;

  /// Whether to exclude transfer transactions from the flow
  ///
  /// When set to true, transfer transactions will not contribute
  /// to total income/expense for a given context
  late final BoolSettingsEntry excludeTransferFromFlow;

  /// Shows next [homeTabPlannedTransactionsDays] days of planned transactions in the home tab
  late final PrimitiveSettingsEntry<int> pendingTransactionsHomeTimeframe;

  /// Whether to use date of confirmation for `transactionDate` for pending transactions
  late final BoolSettingsEntry pendingTransactionsUpdateDateUponConfirmation;

  late final JsonListSettingsEntry<TransactionType> transactionButtonOrder;

  late final BoolSettingsEntry completedInitialSetup;

  late final LocaleSettingsEntry localeOverride;

  /// Whether the user uses only one currency across accounts
  late final BoolSettingsEntry transitiveUsesSingleCurrency;

  late final DateTimeSettingsEntry transitiveLastTimeFrecencyUpdated;

  late final JsonSettingsEntry<ExchangeRatesSet> exchangeRatesCache;

  late final BoolSettingsEntry enableGeo;

  late final BoolSettingsEntry autoAttachTransactionGeo;

  late final PrimitiveSettingsEntry<String> themeName;
  late final BoolSettingsEntry themeChangesAppIcon;
  late final BoolSettingsEntry enableDynamicTheme;

  late final BoolSettingsEntry requirePendingTransactionConfrimation;

  late final BoolSettingsEntry privacyMode;
  late final BoolSettingsEntry sessionPrivacyMode;

  late final BoolSettingsEntry preferFullAmounts;
  late final BoolSettingsEntry useCurrencySymbol;

  LocalPreferences._internal(this._prefs) {
    SettingsEntry.defaultPrefix = "flow.";

    primaryCurrency = PrimitiveSettingsEntry<String>(
      key: "primaryCurrency",
      preferences: _prefs,
    );
    usePhoneNumpadLayout = BoolSettingsEntry(
      key: "usePhoneNumpadLayout",
      preferences: _prefs,
      initialValue: false,
    );
    enableHapticFeedback = BoolSettingsEntry(
      key: "enableHapticFeedback",
      preferences: _prefs,
      initialValue: true,
    );
    combineTransferTransactions = BoolSettingsEntry(
      key: "combineTransferTransactions",
      preferences: _prefs,
      initialValue: true,
    );
    excludeTransferFromFlow = BoolSettingsEntry(
      key: "excludeTransferFromFlow",
      preferences: _prefs,
      initialValue: false,
    );
    pendingTransactionsHomeTimeframe = PrimitiveSettingsEntry<int>(
      key: "pendingTransactions.homeTimeframe",
      preferences: _prefs,
      initialValue: pendingTransactionsHomeTimeframeDefault,
    );
    pendingTransactionsUpdateDateUponConfirmation = BoolSettingsEntry(
      key: "pendingTransactions.updateDateUponConfirmation",
      preferences: _prefs,
      initialValue: true,
    );
    transactionButtonOrder = JsonListSettingsEntry<TransactionType>(
      key: "transactionButtonOrder",
      preferences: _prefs,
      removeDuplicates: true,
      initialValue: TransactionType.values,
      fromJson: (json) =>
          TransactionType.fromJson(json) ?? TransactionType.expense,
      toJson: (transactionType) => transactionType.toJson(),
    );

    completedInitialSetup = BoolSettingsEntry(
      key: "completedInitialSetup",
      preferences: _prefs,
      initialValue: false,
    );

    localeOverride = LocaleSettingsEntry(
      key: "localeOverride",
      preferences: _prefs,
    );

    transitiveUsesSingleCurrency = BoolSettingsEntry(
      key: "transitive.usesSingleCurrency",
      preferences: _prefs,
      initialValue: true,
    );

    transitiveLastTimeFrecencyUpdated = DateTimeSettingsEntry(
      key: "transitive.lastTimeFrecencyUpdated",
      preferences: _prefs,
    );

    exchangeRatesCache = JsonSettingsEntry<ExchangeRatesSet>(
      initialValue: ExchangeRatesSet({}),
      key: "caches.exchangeRatesCache",
      preferences: _prefs,
      fromJson: (json) => ExchangeRatesSet.fromJson(json),
      toJson: (data) => data.toJson(),
    );

    enableGeo = BoolSettingsEntry(
      key: "enableGeo",
      preferences: _prefs,
      initialValue: false,
    );

    autoAttachTransactionGeo = BoolSettingsEntry(
      key: "autoAttachTransactionGeo",
      preferences: _prefs,
      initialValue: false,
    );

    themeName = PrimitiveSettingsEntry<String>(
      key: "themeName",
      preferences: _prefs,
      initialValue: lightThemes.keys.first,
    );
    themeChangesAppIcon = BoolSettingsEntry(
      key: "themeChangesAppIcon",
      preferences: _prefs,
      initialValue: true,
    );
    enableDynamicTheme = BoolSettingsEntry(
      key: "enableDynamicTheme",
      preferences: _prefs,
      initialValue: true,
    );

    requirePendingTransactionConfrimation = BoolSettingsEntry(
      key: "requirePendingTransactionConfrimation",
      preferences: _prefs,
      initialValue: true,
    );

    privacyMode = BoolSettingsEntry(
      key: "privacyMode",
      preferences: _prefs,
      initialValue: false,
    );
    sessionPrivacyMode = BoolSettingsEntry(
      key: "transitive.sessionPrivacyMode",
      preferences: _prefs,
      initialValue: false,
    );
    preferFullAmounts = BoolSettingsEntry(
      key: "preferFullAmounts",
      preferences: _prefs,
      initialValue: false,
    );
    useCurrencySymbol = BoolSettingsEntry(
      key: "useCurrencySymbol",
      preferences: _prefs,
      initialValue: true,
    );

    updateTransitiveProperties();
  }

  Future<void> updateTransitiveProperties() async {
    try {
      final accounts = await ObjectBox().box<Account>().getAllAsync();

      final usesSingleCurrency =
          accounts.map((e) => e.currency).toSet().length == 1;

      await transitiveUsesSingleCurrency.set(usesSingleCurrency);
    } catch (e) {
      log("[LocalPreferences] cannot update transitive properties due to: $e");
    }

    try {
      unawaited(sessionPrivacyMode.set(privacyMode.get()));
    } catch (e) {
      // Silent fail
    }

    try {
      if (transitiveLastTimeFrecencyUpdated.get() == null ||
          !transitiveLastTimeFrecencyUpdated
              .get()!
              .isAtSameDayAs(Moment.now())) {
        unawaited(_reevaluateCategoryFrecency());
        unawaited(_reevaluateAccountFrecency());
        unawaited(transitiveLastTimeFrecencyUpdated.set(DateTime.now()));
      }
    } catch (e) {
      // Silent fail
    }
  }

  Future<FrecencyData?> setFrecencyData(
    String type,
    String uuid,
    FrecencyData? value,
  ) async {
    final String prefixedKey = "transitive.frecency.$type.$uuid";

    if (value == null) {
      await _prefs.remove(prefixedKey);
      return null;
    } else {
      await _prefs.setString(prefixedKey, jsonEncode(value.toJson()));
      return value;
    }
  }

  Future<FrecencyData?> updateFrecencyData(
    String type,
    String uuid,
  ) async {
    final FrecencyData current = getFrecencyData(type, uuid) ??
        FrecencyData(lastUsed: DateTime.now(), useCount: 0, uuid: uuid);

    return await setFrecencyData(type, uuid, current.incremented());
  }

  FrecencyData? getFrecencyData(String type, String uuid) {
    final String prefixedKey = "transitive.frecency.$type.$uuid";

    final raw = _prefs.getString(prefixedKey);

    if (raw == null) return null;

    try {
      return FrecencyData.fromJson(jsonDecode(raw));
    } catch (e) {
      return null;
    }
  }

  Future<void> _reevaluateCategoryFrecency() async {
    final List<Category> categories =
        await ObjectBox().box<Category>().getAllAsync();

    if (categories.isEmpty) {
      return;
    }

    for (final category in categories) {
      try {
        final Query<Transaction> categoryTransactionsQuery = ObjectBox()
            .box<Transaction>()
            .query(Transaction_.categoryUuid.equals(category.uuid).and(
                Transaction_.transactionDate
                    .lessThan(DateTime.now().millisecondsSinceEpoch)))
            .order(Transaction_.transactionDate, flags: Order.descending)
            .build();

        final int useCount = categoryTransactionsQuery.count();
        final DateTime lastUsed =
            categoryTransactionsQuery.findFirst()?.transactionDate ??
                DateTime.fromMillisecondsSinceEpoch(0);

        categoryTransactionsQuery.close();

        unawaited(
          setFrecencyData(
            "category",
            category.uuid,
            FrecencyData(
              uuid: category.uuid,
              lastUsed: lastUsed,
              useCount: useCount,
            ),
          ),
        );
      } catch (e) {
        log("Failed to build category FrecencyData for $category due to: $e");
      }
    }
  }

  Future<void> _reevaluateAccountFrecency() async {
    final List<Account> accounts =
        await ObjectBox().box<Account>().getAllAsync();

    if (accounts.isEmpty) {
      return;
    }

    for (final account in accounts) {
      try {
        final Query<Transaction> accountTransactionsQuery = ObjectBox()
            .box<Transaction>()
            .query(Transaction_.accountUuid.equals(account.uuid).and(
                Transaction_.transactionDate
                    .lessThan(DateTime.now().millisecondsSinceEpoch)))
            .order(Transaction_.transactionDate, flags: Order.descending)
            .build();

        final int useCount = accountTransactionsQuery.count();
        final DateTime lastUsed =
            accountTransactionsQuery.findFirst()?.transactionDate ??
                DateTime.fromMillisecondsSinceEpoch(0);

        accountTransactionsQuery.close();

        unawaited(
          setFrecencyData(
            "account",
            account.uuid,
            FrecencyData(
              uuid: account.uuid,
              lastUsed: lastUsed,
              useCount: useCount,
            ),
          ),
        );
      } catch (e) {
        log("Failed to build account FrecencyData for $account due to: $e");
      }
    }
  }

  String getPrimaryCurrency() {
    String? primaryCurrencyName = primaryCurrency.value;

    if (primaryCurrencyName == null) {
      late final String? firstAccountCurency;

      try {
        final Query<Account> firstAccountQuery = ObjectBox()
            .box<Account>()
            .query()
            .order(Account_.createdDate)
            .build();

        firstAccountCurency = firstAccountQuery.findFirst()?.currency;

        firstAccountQuery.close();
      } catch (e) {
        firstAccountCurency = null;
      }

      if (firstAccountCurency == null) {
        // Generally, primary currency will be set up when the user first
        // opens the app. When recovering from a backup, backup logic should
        // handle setting this value.
        primaryCurrencyName =
            NumberFormat.currency(locale: Intl.defaultLocale ?? "en_US")
                    .currencyName ??
                "USD";
      } else {
        primaryCurrencyName = firstAccountCurency;
      }

      primaryCurrency.set(primaryCurrencyName);
    }

    return primaryCurrencyName;
  }

  String getCurrentTheme() {
    final String? preferencesTheme = LocalPreferences().themeName.get();
    return validateThemeName(preferencesTheme)
        ? preferencesTheme!
        : lightThemes.keys.first;
  }

  factory LocalPreferences() {
    if (_instance == null) {
      throw Exception(
        "You must initialize LocalPreferences by calling initialize().",
      );
    }

    return _instance!;
  }

  static LocalPreferences? _instance;

  static Future<void> initialize() async {
    _instance ??=
        LocalPreferences._internal(await SharedPreferences.getInstance());
  }
}

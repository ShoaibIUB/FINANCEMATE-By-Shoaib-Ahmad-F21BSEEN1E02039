import "package:financemate/data/exchange_rates.dart";
import "package:financemate/data/transactions_filter.dart";
import "package:financemate/entity/transaction.dart";
import "package:financemate/objectbox/actions.dart";
import "package:financemate/prefs.dart";
import "package:financemate/services/exchange_rates.dart";
import "package:financemate/utils/utils.dart";
import "package:financemate/widgets/default_transaction_filter_head.dart";
import "package:financemate/widgets/general/wavy_divider.dart";
import "package:financemate/widgets/grouped_transaction_list.dart";
import "package:financemate/widgets/home/greetings_bar.dart";
import "package:financemate/widgets/home/home/flow_cards.dart";
import "package:financemate/widgets/home/home/no_transactions.dart";
import "package:financemate/widgets/general/pending_transactions_header.dart";
import "package:financemate/widgets/rates_missing_warning.dart";
import "package:financemate/widgets/transactions_date_header.dart";
import "package:financemate/widgets/utils/time_and_range.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class HomeTab extends StatefulWidget {
  final ScrollController? scrollController;

  const HomeTab({super.key, this.scrollController});

  @override
  State<HomeTab> createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> with AutomaticKeepAliveClientMixin {
  late final AppLifecycleListener _listener;

  late int _plannedTransactionsNextNDays;

  final TransactionFilter defaultFilter = TransactionFilter(
    range: last30Days(),
  );

  late TransactionFilter currentFilter = defaultFilter.copyWithOptional();

  TransactionFilter get currentFilterWithPlanned {
    final DateTime plannedTransactionTo = Moment.now()
        .add(Duration(days: _plannedTransactionsNextNDays))
        .startOfNextDay();

    if (currentFilter.range != null &&
        currentFilter.range!.contains(Moment.now()) &&
        !currentFilter.range!.contains(plannedTransactionTo)) {
      return currentFilter.copyWithOptional(
        range: Optional(
          CustomTimeRange(
            currentFilter.range!.from,
            plannedTransactionTo,
          ),
        ),
      );
    }

    return currentFilter;
  }

  late final bool noTransactionsAtAll;

  @override
  void initState() {
    super.initState();
    _updatePlannedTransactionDays();
    LocalPreferences()
        .pendingTransactionsHomeTimeframe
        .addListener(_updatePlannedTransactionDays);

    _listener = AppLifecycleListener(onShow: () => setState(() {}));
  }

  @override
  void dispose() {
    _listener.dispose();
    LocalPreferences()
        .pendingTransactionsHomeTimeframe
        .removeListener(_updatePlannedTransactionDays);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    final bool isFilterModified = currentFilter != defaultFilter;

    return StreamBuilder<List<Transaction>>(
      stream: currentFilterWithPlanned
          .queryBuilder()
          .watch(triggerImmediately: true)
          .map(
            (event) =>
                event.find().filter(currentFilterWithPlanned.postPredicates),
          ),
      builder: (context, snapshot) {
        final DateTime now = Moment.now().startOfNextMinute();
        final ExchangeRates? rates =
            ExchangeRatesService().getPrimaryCurrencyRates();
        final List<Transaction>? transactions = snapshot.data;

        final Widget header = DefaultTransactionsFilterHead(
          defaultFilter: defaultFilter,
          current: currentFilter,
          onChanged: (value) {
            setState(() {
              currentFilter = value;
            });
          },
        );

        return Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: GreetingsBar(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: header,
            ),
            switch ((transactions?.length ?? 0, snapshot.hasData)) {
              (0, true) => Expanded(
                  child: NoTransactions(isFilterModified: isFilterModified),
                ),
              (_, true) => Expanded(
                  child:
                      buildGroupedList(context, now, transactions ?? [], rates),
                ),
              (_, false) => const Expanded(
                  child: Center(
                    child: CircularProgressIndicator.adaptive(),
                  ),
                ),
            }
          ],
        );
      },
    );
  }

  Widget buildGroupedList(
    BuildContext context,
    DateTime now,
    List<Transaction> transactions,
    ExchangeRates? rates,
  ) {
    final Map<TimeRange, List<Transaction>> grouped = transactions
        .where((transaction) =>
            !transaction.transactionDate.isAfter(now) &&
            transaction.isPending != true)
        .groupByDate();

    final List<Transaction> pendingTransactions = transactions
        .where((transaction) =>
            transaction.transactionDate.isAfter(now) ||
            transaction.isPending == true)
        .toList();

    final int actionNeededCount = pendingTransactions
        .where((transaction) => transaction.confirmable())
        .length;

    final Map<TimeRange, List<Transaction>> pendingTransactionsGrouped =
        pendingTransactions.groupByRange(
      rangeFn: (transaction) =>
          CustomTimeRange(Moment.minValue, Moment.maxValue),
    );

    final bool shouldCombineTransferIfNeeded =
        currentFilter.accounts?.isNotEmpty != true;

    return GroupedTransactionList(
      header: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12.0),
          FlowCards(
            transactions: transactions,
            rates: rates,
          ),
          if (rates == null) ...[
            const SizedBox(height: 12.0),
            RatesMissingWarning(),
          ],
        ],
      ),
      controller: widget.scrollController,
      transactions: grouped,
      pendingTransactions: pendingTransactionsGrouped,
      shouldCombineTransferIfNeeded: shouldCombineTransferIfNeeded,
      pendingDivider: const WavyDivider(),
      listPadding: const EdgeInsets.only(
        top: 0,
        bottom: 80.0,
      ),
      headerBuilder: (
        pendingGroup,
        range,
        transactions,
      ) {
        if (pendingGroup) {
          return PendingTransactionsHeader(
            transactions: transactions,
            range: range,
            badgeCount: actionNeededCount,
          );
        }

        return TransactionListDateHeader(
          transactions: transactions,
          range: range,
        );
      },
    );
  }

  void _updatePlannedTransactionDays() {
    _plannedTransactionsNextNDays =
        LocalPreferences().pendingTransactionsHomeTimeframe.get() ??
            LocalPreferences.pendingTransactionsHomeTimeframeDefault;
    setState(() {});
  }

  @override
  bool get wantKeepAlive => true;
}

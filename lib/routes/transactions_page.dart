import "package:financemate/entity/transaction.dart";
import "package:financemate/objectbox.dart";
import "package:financemate/objectbox/actions.dart";
import "package:financemate/objectbox/objectbox.g.dart";
import "package:financemate/widgets/general/spinner.dart";
import "package:financemate/widgets/general/wavy_divider.dart";
import "package:financemate/widgets/grouped_transaction_list.dart";
import "package:financemate/widgets/transactions_date_header.dart";
import "package:flutter/material.dart";
import "package:moment_dart/moment_dart.dart";

class TransactionsPage extends StatefulWidget {
  final QueryBuilder<Transaction> query;
  final String? title;

  final Widget? header;

  const TransactionsPage({
    super.key,
    required this.query,
    this.title,
    this.header,
  });

  factory TransactionsPage.account({
    Key? key,
    required int accountId,
    String? title,
    Widget? header,
  }) {
    final QueryBuilder<Transaction> queryBuilder = ObjectBox()
        .box<Transaction>()
        .query(Transaction_.account.equals(accountId))
        .order(Transaction_.transactionDate, flags: Order.descending);

    return TransactionsPage(
      query: queryBuilder,
      key: key,
      title: title,
      header: header,
    );
  }

  factory TransactionsPage.all({
    Key? key,
    String? title,
    Widget? header,
  }) {
    final QueryBuilder<Transaction> queryBuilder = ObjectBox()
        .box<Transaction>()
        .query()
        .order(Transaction_.transactionDate, flags: Order.descending);

    return TransactionsPage(
      query: queryBuilder,
      key: key,
      title: title,
      header: header,
    );
  }

  factory TransactionsPage.pending({
    Key? key,
    DateTime? anchor,
    String? title,
    Widget? header,
  }) {
    anchor ??= DateTime.now().startOfMinute();

    final QueryBuilder<Transaction> queryBuilder = ObjectBox()
        .box<Transaction>()
        .query(Transaction_.transactionDate
            .greaterThanDate(anchor)
            .or(Transaction_.isPending.equals(true)))
        .order(Transaction_.transactionDate);

    return TransactionsPage(
      query: queryBuilder,
      key: key,
      title: title,
      header: header,
    );
  }

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: widget.title == null ? null : Text(widget.title!),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Transaction>>(
          stream: widget.query
              .watch(triggerImmediately: true)
              .map((event) => event.find()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Spinner.center();
            }

            final DateTime now = DateTime.now().startOfNextMinute();

            final Map<TimeRange, List<Transaction>> transactions = snapshot
                .requireData
                .where((transaction) =>
                    !transaction.transactionDate.isAfter(now) &&
                    transaction.isPending != true)
                .groupByDate();
            final Map<TimeRange, List<Transaction>> pendingTransactions =
                snapshot.requireData
                    .where((transaction) =>
                        transaction.transactionDate.isAfter(now) ||
                        transaction.isPending == true)
                    .groupByDate();

            return GroupedTransactionList(
              transactions: transactions,
              pendingTransactions: pendingTransactions,
              headerBuilder: (pendingGroup, range, transactions) =>
                  TransactionListDateHeader(
                pendingGroup: pendingGroup,
                range: range,
                transactions: transactions,
              ),
              pendingDivider: WavyDivider(),
              header: widget.header,
            );
          },
        ),
      ),
    );
  }
}

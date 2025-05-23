import "package:financemate/entity/transaction.dart";
import "package:financemate/l10n/extensions.dart";
import "package:financemate/theme/theme.dart";
import "package:financemate/widgets/transactions_date_header.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:moment_dart/moment_dart.dart";

class PendingTransactionsHeader extends StatelessWidget {
  final TimeRange range;
  final List<Transaction> transactions;
  final int? badgeCount;

  const PendingTransactionsHeader({
    super.key,
    required this.range,
    required this.transactions,
    this.badgeCount,
  });

  @override
  Widget build(BuildContext context) {
    return TransactionListDateHeader(
      transactions: transactions,
      range: range,
      pendingGroup: true,
      resolveNonPrimaryCurrencies: false,
      titleOverride: Row(
        children: [
          Text("transactions.pending".t(context)),
          if (badgeCount != null && badgeCount! > 0)
            Padding(
              padding: const EdgeInsets.only(left: 8.0),
              child: Badge.count(
                count: badgeCount ?? 0,
                backgroundColor: context.flowColors.expense,
                isLabelVisible: (badgeCount ?? 0) > 0,
              ),
            ),
        ],
      ),
      action: TextButton.icon(
        onPressed: () => context.push("/transactions/pending"),
        label: Text("tabs.home.pendingTransactions.seeAll".t(context)),
        icon: Icon(Symbols.arrow_right_alt_rounded),
        iconAlignment: IconAlignment.end,
      ),
    );
  }
}

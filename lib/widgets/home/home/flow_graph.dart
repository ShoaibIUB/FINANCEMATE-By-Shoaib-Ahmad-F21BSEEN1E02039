import "package:financemate/entity/transaction.dart";
import "package:financemate/l10n/flow_localizations.dart";
import "package:financemate/theme/theme.dart";
import "package:financemate/widgets/home/home/analytics_card.dart";
import "package:financemate/widgets/home/home/flow_separate_line_chart.dart";
import "package:flutter/material.dart";

class FlowGraph extends StatelessWidget {
  final DateTime startDate;

  final List<Transaction>? transactions;

  const FlowGraph({
    super.key,
    this.transactions,
    required this.startDate,
  });

  @override
  Widget build(BuildContext context) {
    return AnalyticsCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0).copyWith(top: 12.0),
        child: Column(
          children: [
            Text(
              "tabs.home.last7days".t(context),
              style: context.textTheme.headlineSmall,
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: FlowSeparateLineChart(
                transactions: transactions ?? [],
                startDate: startDate,
                endDate: DateTime.now(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

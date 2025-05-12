import "package:financemate/data/flow_icon.dart";
import "package:financemate/entity/transaction.dart";
import "package:financemate/theme/theme.dart";
import "package:financemate/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class DemoTransactionListTile extends StatelessWidget {
  final TransactionType type;

  const DemoTransactionListTile({super.key, required this.type});

  @override
  Widget build(BuildContext context) {
    final IconData icon = switch (type) {
      TransactionType.transfer => Symbols.sync_alt_rounded,
      _ => Symbols.circle_rounded,
    };

    return Row(
      children: [
        FlowIcon(
          FlowIconData.icon(icon),
          plated: true,
          fill: 0.0,
        ),
        const SizedBox(width: 4.0),
        Text(
          "▅▅▅",
          style: context.textTheme.bodySmall?.semi(context),
        ),
        const Spacer(),
        Text(
          type == TransactionType.expense ? "-▇" : "▇",
          style: context.textTheme.bodyLarge?.copyWith(
            color: type.color(context),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

import "package:financemate/data/money.dart";
import "package:financemate/entity/category.dart";
import "package:financemate/objectbox/actions.dart";
import "package:financemate/prefs.dart";
import "package:financemate/theme/theme.dart";
import "package:financemate/utils/optional.dart";
import "package:financemate/widgets/general/flow_icon.dart";
import "package:financemate/widgets/general/surface.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";

class CategoryCard extends StatelessWidget {
  final Category category;

  final BorderRadius borderRadius;

  final bool showAmount;

  final Optional<VoidCallback>? onTapOverride;

  final Widget? trailing;

  const CategoryCard({
    super.key,
    required this.category,
    this.onTapOverride,
    this.trailing,
    this.showAmount = true,
    this.borderRadius = const BorderRadius.all(Radius.circular(16.0)),
  });

  @override
  Widget build(BuildContext context) {
    final String primaryCurrency = LocalPreferences().getPrimaryCurrency();

    return Surface(
      shape: RoundedRectangleBorder(borderRadius: borderRadius),
      builder: (context) => InkWell(
        borderRadius: borderRadius,
        onTap: onTapOverride == null
            ? () => context.push("/category/${category.id}")
            : onTapOverride!.value,
        child: Row(
          children: [
            FlowIcon(
              category.icon,
              size: 32.0,
              plated: true,
            ),
            const SizedBox(width: 12.0),
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name,
                  style: context.textTheme.titleSmall,
                ),
                if (showAmount)
                  Text(
                    Money(category.transactions.sumWithoutCurrency,
                            primaryCurrency)
                        .formatted,
                    style: context.textTheme.bodyMedium?.semi(context),
                  ),
              ],
            ),
            const Spacer(),
            if (trailing != null) ...[
              trailing!,
              const SizedBox(width: 12.0),
            ],
          ],
        ),
      ),
    );
  }
}

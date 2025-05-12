import "package:financemate/data/flow_icon.dart";
import "package:financemate/l10n/extensions.dart";
import "package:financemate/theme/theme.dart";
import "package:financemate/widgets/general/button.dart";
import "package:financemate/widgets/general/flow_icon.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";

class NoCategories extends StatelessWidget {
  const NoCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "categories.noCategories".t(context),
              textAlign: TextAlign.center,
              style: context.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8.0),
            FlowIcon(
              FlowIconData.icon(Symbols.category_rounded),
              size: 128.0,
              color: context.colorScheme.primary,
            ),
            const SizedBox(height: 8.0),
            Button(
              trailing: const Icon(
                Symbols.add_rounded,
                weight: 600.0,
              ),
              child: Text("category.new".t(context)),
              onTap: () => context.push("/category/new"),
            ),
          ],
        ),
      ),
    );
  }
}

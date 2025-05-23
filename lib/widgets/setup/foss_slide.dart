import "package:financemate/constants.dart";
import "package:financemate/data/flow_icon.dart";
import "package:financemate/l10n/extensions.dart";
import "package:financemate/theme/theme.dart";
import "package:financemate/utils/utils.dart";
import "package:financemate/widgets/general/flow_icon.dart";
import "package:flutter/gestures.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:simple_icons/simple_icons.dart";

class FossSlide extends StatelessWidget {
  const FossSlide({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Spacer(),
          Center(
            child: FlowIcon(
              FlowIconData.icon(Symbols.globe_rounded),
              size: 160.0,
              plated: true,
            ),
          ),
          const Spacer(),
          Text(
            "setup.slides.foss.title".t(context),
            style: context.textTheme.displayMedium?.copyWith(
              color: context.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8.0),
          Text.rich(
            TextSpan(
              style: context.textTheme.bodyLarge,
              children: [
                TextSpan(
                  text: "setup.slides.foss.description".t(context),
                  style: context.textTheme.bodyLarge,
                ),
                const TextSpan(text: " "),
                TextSpan(
                  text: String.fromCharCode(SimpleIcons.github.codePoint),
                  style: TextStyle(
                    fontFamily: SimpleIcons.github.fontFamily,
                    package: SimpleIcons.github.fontPackage,
                    height: 1.0,
                    color: context.colorScheme.primary,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = (() => openUrl(flowGitHubRepoLink)),
                ),
                const TextSpan(text: " "),
              ],
            ),
          ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}

import "package:financemate/theme/theme.dart";
import "package:financemate/widgets/general/surface.dart";
import "package:flutter/cupertino.dart";

class InfoCard extends StatelessWidget {
  final String title;

  final Widget? moneyText;

  final Widget? icon;

  const InfoCard({
    super.key,
    required this.title,
    this.icon,
    this.moneyText,
  });

  @override
  Widget build(BuildContext context) {
    return Surface(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.0)),
      builder: (BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: 16.0,
          vertical: 12.0,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text(
                  title,
                  style: context.textTheme.bodyMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (icon != null) ...[
                  const SizedBox(width: 4.0),
                  IconTheme(data: IconThemeData(size: 20.0), child: icon!),
                ],
              ],
            ),
            if (moneyText != null) moneyText!
          ],
        ),
      ),
    );
  }
}

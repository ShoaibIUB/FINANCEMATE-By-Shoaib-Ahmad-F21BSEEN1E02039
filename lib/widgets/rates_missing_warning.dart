import "package:financemate/l10n/extensions.dart";
import "package:financemate/prefs.dart";
import "package:financemate/services/exchange_rates.dart";
import "package:financemate/theme/theme.dart";
import "package:financemate/utils/extensions/toast.dart";
import "package:financemate/widgets/general/spinner.dart";
import "package:flutter/material.dart";
import "package:material_symbols_icons/symbols.dart";

class RatesMissingWarning extends StatefulWidget {
  const RatesMissingWarning({super.key});

  @override
  State<RatesMissingWarning> createState() => _RatesMissingWarningState();
}

class _RatesMissingWarningState extends State<RatesMissingWarning> {
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.all(Radius.circular(8.0)),
      onTap: fetch,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(
            Symbols.error_circle_rounded,
            fill: 0,
            color: context.colorScheme.error,
            size: 24.0,
          ),
          const SizedBox(width: 12.0),
          Expanded(
            child: DefaultTextStyle(
              style: context.textTheme.bodyMedium!
                  .semi(context)
                  .copyWith(color: context.colorScheme.error),
              child: Text("error.exchangeRates.inaccurateDataDueToMissingRates"
                  .t(context)),
            ),
          ),
          const SizedBox(width: 12.0),
          busy
              ? SizedBox(
                  width: 24.0,
                  height: 24.0,
                  child: Spinner(),
                )
              : Icon(
                  Symbols.refresh_rounded,
                  fill: 0,
                  size: 24.0,
                  color: context.colorScheme.error,
                ),
        ],
      ),
    );
  }

  void fetch() async {
    if (busy) return;

    setState(() {
      busy = true;
    });

    try {
      await ExchangeRatesService()
          .fetchRates(LocalPreferences().getPrimaryCurrency());
    } catch (e) {
      if (mounted) {
        context.showErrorToast(
          error: "error.exchangeRates.cannotFetch".t(context),
        );
      }
    } finally {
      busy = false;
      if (mounted) {
        setState(() {});
      }
    }
  }
}

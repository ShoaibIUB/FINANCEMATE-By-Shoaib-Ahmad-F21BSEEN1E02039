import "package:financemate/l10n/flow_localizations.dart";
import "package:financemate/prefs.dart";
import "package:financemate/services/exchange_rates.dart";
import "package:financemate/theme/helpers.dart";
import "package:financemate/widgets/general/button.dart";
import "package:flutter/material.dart";

class ExchangeMissingNotice extends StatefulWidget {
  const ExchangeMissingNotice({super.key});

  @override
  State<ExchangeMissingNotice> createState() => _ExchangeMissingNoticeState();
}

class _ExchangeMissingNoticeState extends State<ExchangeMissingNotice> {
  bool busy = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: 12.0,
        vertical: 8.0,
      ),
      color: context.flowColors.expense.withAlpha(0x80),
      child: Row(
        children: [
          Flexible(
            child: Text(
              "tabs.stats.chart.noExchangeRatesWarning".t(context),
            ),
          ),
          const SizedBox(width: 8.0),
          Button(
            onTap: busy ? null : fetchDefaultExchange,
            child: Text(
              "tabs.stats.chart.noExchangeRatesWarning.retry".t(context),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> fetchDefaultExchange() async {
    if (busy) {
      return;
    }

    setState(() {
      busy = true;
    });

    try {
      await ExchangeRatesService().tryFetchRates(
        LocalPreferences().getPrimaryCurrency(),
      );
      await Future.delayed(const Duration(milliseconds: 1000));
    } finally {
      setState(() {
        busy = false;
      });
    }
  }
}

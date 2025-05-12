import "package:financemate/entity/transaction.dart";
import "package:financemate/l10n/extensions.dart";
import "package:financemate/objectbox/actions.dart";
import "package:financemate/prefs.dart";
import "package:financemate/utils/utils.dart";
import "package:flutter/widgets.dart";

extension TransactionContextActions on BuildContext {
  Future<void> deleteTransaction(Transaction transaction) async {
    final String txnTitle =
        transaction.title ?? "transaction.fallbackTitle".t(this);

    final confirmation = await showConfirmDialog(
      isDeletionConfirmation: true,
      title: "general.delete.confirmName".t(this, txnTitle),
    );

    if (confirmation == true) {
      transaction.delete();
    }
  }

  Future<void> confirmTransaction(
    Transaction transaction, [
    bool confirm = true,
  ]) async {
    final bool updateTransactionDate =
        LocalPreferences().pendingTransactionsUpdateDateUponConfirmation.get();

    transaction.confirm(confirm, updateTransactionDate);
  }

  Future<void> duplicateTransaction(Transaction transaction) async {
    transaction.duplicate();
  }
}

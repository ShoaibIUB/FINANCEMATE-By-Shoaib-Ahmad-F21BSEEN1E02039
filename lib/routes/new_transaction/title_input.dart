import "package:financemate/entity/transaction.dart";
import "package:financemate/objectbox.dart";
import "package:financemate/objectbox/actions.dart";
import "package:financemate/theme/theme.dart";
import "package:financemate/widgets/general/frame.dart";
import "package:flutter/material.dart";
import "package:flutter_typeahead/flutter_typeahead.dart";

class TitleInput extends StatelessWidget {
  final FocusNode focusNode;
  final TextEditingController controller;

  final int? selectedAccountId;
  final int? selectedCategoryId;
  final TransactionType transactionType;

  final String fallbackTitle;

  final Function(String) onSubmitted;

  const TitleInput({
    super.key,
    required this.focusNode,
    required this.controller,
    this.selectedAccountId,
    this.selectedCategoryId,
    required this.transactionType,
    required this.fallbackTitle,
    required this.onSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    return Frame(
      child: TypeAheadField<RelevanceScoredTitle>(
        focusNode: focusNode,
        controller: controller,
        itemBuilder: (context, value) => ListTile(title: Text(value.title)),
        debounceDuration: const Duration(milliseconds: 180),
        decorationBuilder: (context, child) => Material(
          clipBehavior: Clip.hardEdge,
          elevation: 1.0,
          borderRadius: BorderRadius.circular(16.0),
          child: child,
        ),
        onSelected: (option) => controller.text = option.title,
        suggestionsCallback: getAutocompleteOptions,
        builder: (context, controller, focusNode) {
          return TextField(
            controller: controller,
            focusNode: focusNode,
            style: context.textTheme.headlineMedium,
            textAlign: TextAlign.center,
            maxLength: Transaction.maxTitleLength,
            onSubmitted: onSubmitted,
            autocorrect: false,
            decoration: InputDecoration(
              hintText: fallbackTitle,
              counter: const SizedBox.shrink(),
            ),
          );
        },
        hideOnEmpty: true,
      ),
    );
  }

  Future<List<RelevanceScoredTitle>> getAutocompleteOptions(
          String query) async =>
      ObjectBox().transactionTitleSuggestions(
        currentInput: query,
        accountId: selectedAccountId,
        categoryId: selectedCategoryId,
        type: transactionType,
        limit: 5,
      );
}

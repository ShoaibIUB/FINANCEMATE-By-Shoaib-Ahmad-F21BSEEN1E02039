import "package:financemate/entity/category.dart";
import "package:financemate/l10n/extensions.dart";
import "package:financemate/objectbox.dart";
import "package:financemate/objectbox/objectbox.g.dart";
import "package:financemate/widgets/categories/no_categories.dart";
import "package:financemate/widgets/category_card.dart";
import "package:financemate/widgets/add_category_card.dart";
import "package:financemate/widgets/general/spinner.dart";
import "package:flutter/material.dart";

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({super.key});

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  QueryBuilder<Category> qb() =>
      ObjectBox().box<Category>().query().order(Category_.createdDate);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("categories".t(context)),
      ),
      body: SafeArea(
        child: StreamBuilder<List<Category>>(
          stream:
              qb().watch(triggerImmediately: true).map((event) => event.find()),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Spinner.center();
            }

            final categories = snapshot.requireData;

            return switch (categories.length) {
              0 => const NoCategories(),
              _ => SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(bottom: 16.0),
                        child: AddCategoryCard(),
                      ),
                      ...categories.map(
                        (category) => Padding(
                          padding: const EdgeInsets.only(bottom: 16.0),
                          child: CategoryCard(
                            category: category,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                    ],
                  ),
                ),
            };
          },
        ),
      ),
    );
  }
}

import "package:financemate/l10n/extensions.dart";
import "package:financemate/l10n/named_enum.dart";
import "package:financemate/sync/import/import_v1.dart";
import "package:financemate/utils/utils.dart";
import "package:financemate/widgets/general/spinner.dart";
import "package:financemate/widgets/import_wizard/import_success.dart";
import "package:financemate/widgets/import_wizard/v1/backup_info.dart";
import "package:flutter/material.dart";

class ImportWizardV1Page extends StatefulWidget {
  final ImportV1 importer;

  const ImportWizardV1Page({super.key, required this.importer});

  @override
  State<ImportWizardV1Page> createState() => _ImportWizardV1PageState();
}

class _ImportWizardV1PageState extends State<ImportWizardV1Page> {
  ImportV1 get importer => widget.importer;

  dynamic error;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("sync.import".t(context)),
      ),
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: importer.progressNotifier,
          builder: (context, value, child) => switch (value) {
            ImportV1Progress.waitingConfirmation => BackupInfo(
                importer: importer,
                onTap: _start,
              ),
            ImportV1Progress.error => Text(error.toString()),
            ImportV1Progress.success => const ImportSuccess(),
            _ => Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Spinner.center(),
                    Center(
                      child: Text(
                        value.localizedNameContext(context),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
          },
        ),
      ),
    );
  }

  void _start() async {
    final bool? confirm = await context.showConfirmDialog(
      title: "sync.import.eraseWarning".t(context),
      isDeletionConfirmation: true,
      mainActionLabelOverride: "general.confirm".t(context),
    );

    if (confirm != true) return;

    try {
      await importer.execute();
    } catch (e) {
      error = e;
    } finally {
      if (mounted) {
        setState(() {});
      }
    }
  }
}

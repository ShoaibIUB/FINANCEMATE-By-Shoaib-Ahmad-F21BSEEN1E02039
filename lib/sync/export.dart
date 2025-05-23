import "dart:async";
import "dart:developer";
import "dart:io";
import "dart:math" as math;

import "package:financemate/entity/backup_entry.dart";
import "package:financemate/objectbox.dart";
import "package:financemate/sync/export/export_v1.dart";
import "package:financemate/sync/export/mode.dart";
import "package:financemate/sync/sync.dart";
import "package:financemate/utils/utils.dart";
import "package:moment_dart/moment_dart.dart";
import "package:path/path.dart" as path;
import "package:share_plus/share_plus.dart";

typedef ExportStatus = ({bool shareDialogSucceeded, String filePath});

/// Exports all user data (except for profile for now) in the format specified.
///
///
/// [mode] - defaults to `json`, see [ExportMode]
/// [subfolder] - Will put the backup in a subfolder. May be useful for
/// automated backups
Future<ExportStatus> export({
  required BackupEntryType type,
  ExportMode mode = ExportMode.json,
  bool showShareDialog = true,
  String? subfolder,
}) async {
  // Sharing [XFile]s aren't supported yet on Linux.
  //
  // https://pub.dev/packages/share_plus#platform-support
  final bool isShareSupported = !(Platform.isLinux || Platform.isFuchsia);

  final backupContent = switch ((mode, latestSyncModelVersion)) {
    (ExportMode.csv, 1) => await generateCSVContentV1(),
    (ExportMode.json, 1) => await generateBackupContentV1(),
    _ => throw UnimplementedError(),
  };
  final savedFilePath = await saveBackupFile(
    backupContent,
    isShareSupported,
    fileExt: mode.fileExt,
    subfolder: subfolder,
    type: type,
  );

  // Try to add backup record
  unawaited(
    ObjectBox()
        .box<BackupEntry>()
        .putAsync(BackupEntry(
          filePath: savedFilePath,
          type: type.value,
          fileExt: mode.fileExt,
        ))
        .catchError(
      (error) {
        log("[Export] Failed to add BackupEntry due to: $error");
        return -1;
      },
    ),
  );

  if (!showShareDialog) {
    return (shareDialogSucceeded: false, filePath: savedFilePath);
  }

  return await showFileSaveDialog(savedFilePath, isShareSupported);
}

/// Returns file path after successfully saving it
Future<String> saveBackupFile(
  String backupContent,
  bool isShareSupported, {
  required String fileExt,
  required BackupEntryType type,
  String? subfolder,
}) async {
  // Save to cache if it's possible to share later.
  // Otherwise, save to documents directory, and reveal the file on system.

  final Directory saveDir =
      Directory(path.join(ObjectBox.appDataDirectory, "backups"));

  final String dateTime = Moment.now().lll.replaceAll(RegExp("\\s"), "_");
  final String randomValue = math.Random().nextInt(536870912).toRadixString(36);
  final String filename = "flow_backup_${dateTime}_$randomValue.$fileExt";

  log("[Flow Sync] Writing to ${path.join(saveDir.path, filename)}");

  final File f = File(path.join(saveDir.path, subfolder ?? "", filename));
  f.createSync(recursive: true);
  f.writeAsStringSync(backupContent);

  log("[Flow Sync] Write successful. See file at: ${f.path}");

  return f.path;
}

/// Returns whether the file was saved/revealed successfully
Future<ExportStatus> showFileSaveDialog(
  String savedFilePath,
  bool isShareSupported,
) async {
  bool shareSuccess;

  if (isShareSupported) {
    final shareResult = await Share.shareXFiles(
      [XFile(savedFilePath)],
      subject: path.basename(savedFilePath),
      text: "Backup for Flow",
    );

    shareSuccess = shareResult.status == ShareResultStatus.success;
  } else {
    shareSuccess = await openUrl(
      Uri(
        scheme: "file",
        path: path.dirname(savedFilePath),
      ),
    );
  }

  final uri = Uri(
    scheme: "file",
    path: path.dirname(savedFilePath),
  );

  log("[Flow Sync] shareSuccess $shareSuccess $uri");

  return (shareDialogSucceeded: shareSuccess, filePath: savedFilePath);
}

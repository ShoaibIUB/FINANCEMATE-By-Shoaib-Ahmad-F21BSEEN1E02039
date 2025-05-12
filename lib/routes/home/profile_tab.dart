import "dart:async";

import "package:financemate/constants.dart";
import "package:financemate/l10n/extensions.dart";
import "package:financemate/objectbox.dart";
import "package:financemate/prefs.dart";
import "package:financemate/services/exchange_rates.dart";
import "package:financemate/sync/import.dart";
import "package:financemate/theme/color_themes/registry.dart";
import "package:financemate/theme/theme.dart";
import "package:financemate/utils/utils.dart";
import "package:financemate/widgets/general/button.dart";
import "package:financemate/widgets/general/list_header.dart";
import "package:financemate/widgets/home/prefs/profile_card.dart";
import "package:flutter/material.dart";
import "package:go_router/go_router.dart";
import "package:material_symbols_icons/symbols.dart";
import "package:shared_preferences/shared_preferences.dart";

class ProfileTab extends StatefulWidget {
  const ProfileTab({super.key});

  @override
  State<ProfileTab> createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  bool _debugDbBusy = false;
  bool _debugPrefsBusy = false;

  Timer? _debugDiscoTimer;
  int _debugDiscoIndex = 0;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      // padding: const EdgeInsets.all(16.0),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24.0),
          const Center(child: ProfileCard()),
          const SizedBox(height: 24.0),
          ListTile(
            title: Text("categories".t(context)),
            leading: const Icon(Symbols.category_rounded),
            onTap: () => context.push("/categories"),
          ),
          ListTile(
            title: Text("tabs.profile.preferences".t(context)),
            leading: const Icon(Symbols.settings_rounded),
            onTap: () => context.push("/preferences"),
          ),
          ListTile(
            title: Text("tabs.profile.backup".t(context)),
            leading: const Icon(Symbols.hard_drive_rounded),
            onTap: () => context.push("/exportOptions"),
          ),
          ListTile(
            title: Text("tabs.profile.import".t(context)),
            leading: const Icon(Symbols.restore_page_rounded),
            onTap: () => context.push("/import"),
          ),
          if (flowDebugMode) ...[
            const SizedBox(height: 32.0),
            const ListHeader("Debug options"),
            ListTile(
              title: _debugDiscoTimer == null
                  ? const Text("Turn on disco")
                  : const Text("Turn off disco"),
              leading: const Icon(Symbols.party_mode_rounded),
              onTap: toggleDisco,
            ),
            ListTile(
              title: const Text("Populate objectbox"),
              leading: const Icon(Symbols.adb_rounded),
              onTap: () => ObjectBox().createAndPutDebugData(),
            ),
            ListTile(
              title: const Text("Clear exchange rates cache"),
              onTap: () => clearExchangeRatesCache(),
              leading: const Icon(Symbols.adb_rounded),
            ),
            ListTile(
              title:
                  Text(_debugDbBusy ? "Clearing database" : "Clear objectbox"),
              onTap: () => resetDatabase(),
              leading: const Icon(Symbols.adb_rounded),
            ),
            ListTile(
              title: Text("Clear Shared Preferences"),
              onTap: () => resetPrefs(),
              leading: const Icon(Symbols.adb_rounded),
            ),
            ListTile(
              title: const Text("Jump to setup page"),
              onTap: () => context.pushReplacement("/setup"),
              leading: const Icon(Symbols.settings_rounded),
            ),
          ],
          const SizedBox(height: 64.0),
          Center(
            child: Text(
              "v$appVersion",
              style: context.textTheme.labelSmall,
            ),
          ),
          Center(
            child: InkWell(
              borderRadius: BorderRadius.circular(8.0),
              onTap: () => openUrl(maintainerGitHubLink),
              child: Opacity(
                opacity: 0.5,
                child: Text(
                  "tabs.profile.withLoveFromTheCreator".t(context),
                  style: context.textTheme.labelSmall,
                ),
              ),
            ),
          ),
          const SizedBox(height: 24.0),
          const SizedBox(height: 96.0),
        ],
      ),
    );
  }

  void toggleDisco() {
    if (_debugDiscoTimer != null) {
      _debugDiscoTimer!.cancel();
      _debugDiscoTimer = null;
    } else {
      _debugDiscoTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        try {
          final newThemeName = darkThemes.keys.elementAt(_debugDiscoIndex++);

          unawaited(
            LocalPreferences().themeName.set(newThemeName),
          );
        } catch (e) {
          timer.cancel();
          _debugDiscoTimer = null;
          if (mounted) {
            setState(() {});
          }
        }
      });
    }
    setState(() {});
  }

  void resetDatabase() async {
    if (_debugDbBusy) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text("[dev] Reset database?"),
        actions: [
          Button(
            onTap: () => context.pop(true),
            child: const Text("Confirm delete"),
          ),
          Button(
            onTap: () => context.pop(false),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );

    setState(() {
      _debugDbBusy = true;
    });

    try {
      if (confirm == true) {
        await ObjectBox().eraseMainData();
      }
    } finally {
      _debugDbBusy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void resetPrefs() async {
    if (_debugPrefsBusy) return;

    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog.adaptive(
        title: const Text("[dev] Clear Shared Preferences?"),
        actions: [
          Button(
            onTap: () => context.pop(true),
            child: const Text("Confirm clear"),
          ),
          Button(
            onTap: () => context.pop(false),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );

    setState(() {
      _debugPrefsBusy = true;
    });

    try {
      if (confirm == true) {
        final instance = await SharedPreferences.getInstance();
        await instance.clear();
      }
    } finally {
      _debugPrefsBusy = false;

      if (mounted) {
        setState(() {});
      }
    }
  }

  void clearExchangeRatesCache() {
    ExchangeRatesService().debugClearCache();
  }

  void import() async {
    try {
      await importBackupV1();
      if (mounted) {
        context.showToast(
          text: "sync.import.successful".t(context),
        );
      }
    } catch (e) {
      if (mounted) {
        context.showErrorToast(error: e);
      }
    }
  }
}

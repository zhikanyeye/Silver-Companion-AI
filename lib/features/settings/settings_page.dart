import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/app.dart';
import 'package:yinling_zhiban_demo/services/settings_store.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key, SettingsStore? store}) : _store = store;

  final SettingsStore? _store;

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final SettingsStore _store;
  bool _isLoading = true;
  String _model = '';

  @override
  void initState() {
    super.initState();
    _store = widget._store ?? SettingsStore();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final settings = await _store.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _model = settings.model;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Service Settings')),
      body: Container(
        key: const Key('settingsServiceShell'),
        decoration: const BoxDecoration(gradient: AppTheme.serviceGradient),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      children: [
                        Card(
                          child: ValueListenableBuilder<bool>(
                            valueListenable: App.isCareMode,
                            builder: (context, careMode, child) {
                              return SwitchListTile(
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                title: const Text(
                                  'Care Mode',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                                subtitle: const Text(
                                  'Enable larger text and stronger contrast.',
                                ),
                                value: careMode,
                                activeThumbColor: AppTheme.primary,
                                onChanged: (value) {
                                  App.isCareMode.value = value;
                                },
                                secondary: Container(
                                  width: 42,
                                  height: 42,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF4E8),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(
                                    Icons.text_increase_rounded,
                                    color: AppTheme.accent,
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          color: AppTheme.surfaceAlt,
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEAF2FF),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Text(
                                    'Service Status',
                                    style: theme.textTheme.labelLarge?.copyWith(
                                      color: AppTheme.serviceBluePrimary,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Text(
                                  'Cloud services connected',
                                  style: theme.textTheme.titleLarge,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Model selection is loaded from cloud configuration.',
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            title: const Text('Current Model'),
                            subtitle: Text(_model),
                            leading: Container(
                              width: 42,
                              height: 42,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF2FF),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: const Icon(
                                Icons.hub_outlined,
                                color: AppTheme.serviceBluePrimary,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }
}

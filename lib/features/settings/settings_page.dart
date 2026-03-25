import 'package:flutter/material.dart';

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
      appBar: AppBar(title: const Text('服务设置')),
      body: Container(
        key: const Key('settingsServiceShell'),
        decoration: const BoxDecoration(
          gradient: AppTheme.serviceGradient,
        ),
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SafeArea(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: AppTheme.surfaceAlt,
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAF2FF),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                '服务状态',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  color: AppTheme.serviceBluePrimary,
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            Text('云端服务已连接', style: theme.textTheme.titleLarge),
                            const SizedBox(height: 8),
                            Text('由云端配置管理', style: theme.textTheme.bodyMedium),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.white,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        title: const Text('当前模型'),
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
    );
  }
}

import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/services/settings_store.dart';

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
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            '云端服务已连接',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text('由云端配置管理'),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      title: const Text('当前模型'),
                      subtitle: Text(_model),
                      leading: Icon(
                        Icons.hub_outlined,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

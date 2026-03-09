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
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _modelController = TextEditingController();

  bool _isLoading = true;
  bool _usingFallbackApiKey = false;

  @override
  void initState() {
    super.initState();
    _store = widget._store ?? SettingsStore();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _modelController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final settings = await _store.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _apiKeyController.text = settings.apiKey;
      _modelController.text = settings.model;
      _usingFallbackApiKey = settings.usingFallbackApiKey;
      _isLoading = false;
    });
  }

  Future<void> _save() async {
    await _store.save(
      apiKey: _apiKeyController.text,
      model: _modelController.text,
    );
    if (!mounted) {
      return;
    }

    final reloaded = await _store.load();
    if (!mounted) {
      return;
    }

    setState(() {
      _usingFallbackApiKey = reloaded.usingFallbackApiKey;
      _apiKeyController.text = reloaded.apiKey;
      _modelController.text = reloaded.model;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Settings saved')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_usingFallbackApiKey)
                    const MaterialBanner(
                      content: Text('Using fallback API key from environment.'),
                      actions: [SizedBox.shrink()],
                    ),
                  TextField(
                    controller: _apiKeyController,
                    decoration: const InputDecoration(labelText: 'API key'),
                    obscureText: true,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _modelController,
                    decoration: const InputDecoration(labelText: 'Model'),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _save,
                    child: const Text('Save'),
                  ),
                ],
              ),
            ),
    );
  }
}

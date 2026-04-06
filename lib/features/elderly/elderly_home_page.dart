import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:yinling_zhiban_demo/features/elderly/mock_service_data.dart';
import 'package:yinling_zhiban_demo/routes.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class ElderlyHomePage extends StatelessWidget {
  const ElderlyHomePage({super.key});

  Future<void> _showHelpSheet(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFFFFFBF7),
      builder: (sheetContext) {
        String copiedMessage = '';
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'What kind of help do you need?',
                        style: Theme.of(sheetContext).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        'Reach family or community support first, or contact platform support if needed.',
                      ),
                      if (copiedMessage.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAF7EA),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(copiedMessage),
                        ),
                      ],
                      const SizedBox(height: 16),
                      for (final contact in elderlySupportContacts) ...[
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(contact.label, style: Theme.of(context).textTheme.titleMedium),
                                const SizedBox(height: 4),
                                Text(contact.name),
                                const SizedBox(height: 4),
                                Text(contact.phone),
                                const SizedBox(height: 8),
                                Text(contact.description),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: () {
                                      Clipboard.setData(ClipboardData(text: contact.phone));
                                      setModalState(() {
                                        copiedMessage = 'Contact number copied';
                                      });
                                    },
                                    child: const Text('Copy number'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        if (contact != elderlySupportContacts.last) const SizedBox(height: 10),
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showSOSDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _SOSDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = <_ServiceItem>[
      _ServiceItem(
        key: const Key('elderlyAiCompanionEntry'),
        title: 'AI Companion',
        description: 'Chat with the assistant naturally.',
        onTap: () => Navigator.of(context).pushNamed(chatRoute),
      ),
      _ServiceItem(
        key: const Key('elderlyHelpEntry'),
        title: 'Help',
        description: 'Reach family or support quickly.',
        onTap: () => _showHelpSheet(context),
      ),
      _ServiceItem(
        key: const Key('elderlyCommunityEntry'),
        title: 'Community',
        description: 'See today\'s neighborhood support posts.',
        onTap: () => Navigator.of(context).pushNamed(communityRoute),
      ),
      _ServiceItem(
        key: const Key('elderlyActivitiesEntry'),
        title: 'Activities',
        description: 'Check community activities for today.',
        onTap: () => Navigator.of(context).pushNamed(elderlyActivitiesRoute),
      ),
      _ServiceItem(
        key: const Key('childAvatarEntry'),
        title: 'Xiao Ling Online',
        description: 'Open chat directly with the assistant.',
        onTap: () => Navigator.of(context).pushNamed(chatRoute),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Elderly Home')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showSOSDialog(context),
        backgroundColor: AppTheme.error,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.sos_rounded),
        label: const Text('Emergency SOS'),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(gradient: AppTheme.serviceGradient),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final isCompact = constraints.maxWidth < 640;
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(32),
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFEAF3FF), Color(0xFFF9FCFF), Color(0xFFFFF1E8)],
                      ),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Today Service Hall', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
                        SizedBox(height: 12),
                        Text('What would you like to use first today?', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                        SizedBox(height: 8),
                        Text('Key entries are organized for chat, help, and community updates.'),
                        SizedBox(height: 16),
                        Text('Today key services', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  const Text('Common services', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 12),
                  if (isCompact)
                    Column(
                      key: const Key('elderlyServiceGridSingleColumn'),
                      children: [
                        for (var i = 0; i < services.length; i++) ...[
                          _ServiceCard(item: services[i]),
                          if (i != services.length - 1) const SizedBox(height: 12),
                        ],
                      ],
                    )
                  else
                    Wrap(
                      key: const Key('elderlyServiceGridMultiColumn'),
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        for (final item in services)
                          SizedBox(
                            width: (constraints.maxWidth - 48) / 2,
                            child: _ServiceCard(item: item),
                          ),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _ServiceItem {
  const _ServiceItem({
    this.key,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final Key? key;
  final String title;
  final String description;
  final VoidCallback onTap;
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.item});

  final _ServiceItem item;

  @override
  Widget build(BuildContext context) {
    return Card(
      key: item.key,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: item.onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.title, style: Theme.of(context).textTheme.titleLarge),
                    const SizedBox(height: 6),
                    Text(item.description),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

class _SOSDialog extends StatefulWidget {
  const _SOSDialog();

  @override
  State<_SOSDialog> createState() => _SOSDialogState();
}

class _SOSDialogState extends State<_SOSDialog> {
  int _countdown = 5;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown > 1) {
        setState(() {
          _countdown--;
        });
      } else {
        timer.cancel();
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Emergency SOS active'),
      content: Text('An emergency alert will be sent in $_countdown seconds unless canceled.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
      ],
    );
  }
}

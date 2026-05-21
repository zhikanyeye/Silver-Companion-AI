import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:yinling/config/config_loader.dart';
import 'package:yinling/features/chat/chat_controller.dart';
import 'package:yinling/features/chat/chat_message.dart';
import 'package:yinling/features/chat/chat_publish_action.dart';
import 'package:yinling/features/elderly/mock_service_data.dart';
import 'package:yinling/theme/app_theme.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, ChatController? controller})
      : _controller = controller;

  final ChatController? _controller;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatController _controller;
  late final bool _ownsController;
  final ConfigLoader _configLoader = ConfigLoader();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _autoSendVoice = true;

  @override
  void initState() {
    super.initState();
    _ownsController = widget._controller == null;
    _controller = (widget._controller ?? ChatController())
      ..addListener(_onControllerChanged)
      ..onInterimText = (text) {
        _applyRecognizedText(text);
      }
      ..onFinalText = (text) {
        _applyRecognizedText(text);
        if (_autoSendVoice) {
          Future.delayed(const Duration(milliseconds: 300), () {
            if (mounted) {
              _sendCurrentText();
            }
          });
        }
      };
    _loadConfig();
  }

  void _applyRecognizedText(String text) {
    if (!mounted) {
      return;
    }

    setState(() {
      _inputController.value = TextEditingValue(
        text: text,
        selection: TextSelection.collapsed(offset: text.length),
      );
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    if (_ownsController) {
      _controller.dispose();
    }
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) {
      return;
    }
    setState(() {});
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 240),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  Future<void> _loadConfig() async {
    final config = await _configLoader.load();
    if (config != null) {
      _controller.applyConfig(config);
    }
  }

  Future<void> _sendCurrentText() async {
    final text = _inputController.text;
    if (_controller.isLoading || text.trim().isEmpty) {
      return;
    }
    _inputController.clear();
    await _controller.sendText(text);
  }

  bool get _hasAssistantMessage =>
      _controller.messages.any((message) => message.role == ChatRole.assistant);

  @override
  Widget build(BuildContext context) {
    final pendingIntent = _controller.pendingPublishIntent;

    return Scaffold(
      appBar: AppBar(
        title: const Text('AI 助手'),
        actions: [
          IconButton(
            key: const Key('chatSpeechToggle'),
            onPressed: _controller.isSpeechOutputSupported
                ? _controller.toggleSpeechPlayback
                : null,
            icon: Icon(
              _controller.isSpeechPlaybackEnabled
                  ? Icons.volume_up_rounded
                  : Icons.volume_off_rounded,
            ),
            tooltip: _controller.isSpeechPlaybackEnabled ? '关闭语音播报' : '开启语音播报',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'clear') {
                await _controller.clearMessages();
                return;
              }
              if (value == 'auto_send') {
                setState(() {
                  _autoSendVoice = !_autoSendVoice;
                });
              }
            },
            itemBuilder: (context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(value: 'clear', child: Text('清空会话')),
              CheckedPopupMenuItem<String>(
                value: 'auto_send',
                checked: _autoSendVoice,
                child: const Text('语音自动发送'),
              ),
            ],
          ),
        ],
      ),
      body: Container(
        key: const Key('chatServiceShell'),
        decoration: const BoxDecoration(gradient: AppTheme.serviceGradient),
        child: Column(
          children: [
            if (_controller.hasRiskWarning)
              _Banner(
                color: AppTheme.warningSoft,
                icon: Icons.warning_amber_rounded,
                message: '风险提醒：未与家人核实前，请勿转账或透露验证码。',
              ),
            if (_controller.error != null)
              _Banner(
                color: AppTheme.dangerSoft,
                icon: Icons.error_outline,
                message: _controller.error!,
              ),
            if (_controller.isSpeechOutputSupported)
              _Banner(
                color: const Color(0xFFEFF5FF),
                icon: _controller.isSpeechPlaybackEnabled
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
                message: _controller.isSpeechPlaybackEnabled
                    ? '已开启助手回复语音播报。'
                    : '语音播报已关闭，可手动重播收听。',
              ),
            if (pendingIntent?.isReadyForConfirmation ?? false)
              _PendingPublishCard(
                intent: pendingIntent!,
                onConfirm: _controller.confirmPendingPublish,
                onCancel: _controller.cancelPendingPublish,
              ),
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: _controller.messages.length,
                itemBuilder: (context, index) {
                  final message = _controller.messages[index];
                  final isUser = message.role == ChatRole.user;
                  return _MessageBubble(
                    message: message,
                    isUser: isUser,
                    showReplay:
                        !isUser &&
                        index ==
                            _controller.messages.lastIndexWhere(
                              (entry) => entry.role == ChatRole.assistant,
                            ),
                    onCopy: () => _copyMessage(message.content),
                    onReplay: _controller.isSpeechOutputSupported
                        ? _controller.replayLastAssistantMessage
                        : null,
                  );
                },
              ),
            ),
            if (_controller.isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('AI 正在思考...'),
                  ],
                ),
              ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Semantics(
              label: _controller.isRecognizing ? '停止语音输入' : '语音输入',
              button: true,
              child: Container(
                width: AppTheme.minTouchTarget,
                height: AppTheme.minTouchTarget,
                decoration: BoxDecoration(
                  color: _controller.isRecognizing
                      ? AppTheme.warningSoft
                      : AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderSoft),
                ),
                child: IconButton(
                  key: const Key('voiceButton'),
                  onPressed: _controller.isSpeechInputSupported
                      ? () {
                          if (_controller.isRecognizing) {
                            _controller.stopRecognition();
                          } else {
                            _controller.startRecognition();
                          }
                        }
                      : null,
                  icon: Icon(
                    _controller.isRecognizing ? Icons.mic_off : Icons.mic,
                    color: _controller.isRecognizing
                        ? const Color(0xFFE74C3C)
                        : AppTheme.serviceBluePrimary,
                  ),
                  tooltip: _controller.isRecognizing ? '停止语音输入' : '语音输入',
                ),
              ),
            ),
            if (_hasAssistantMessage) ...[
              const SizedBox(width: 8),
              Container(
                width: AppTheme.minTouchTarget,
                height: AppTheme.minTouchTarget,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderSoft),
                ),
                child: IconButton(
                  key: const Key('chatReplayLastAssistantButton'),
                  onPressed: _controller.isSpeechOutputSupported
                      ? _controller.replayLastAssistantMessage
                      : null,
                  icon: const Icon(
                    Icons.play_circle_outline_rounded,
                    color: AppTheme.serviceBluePrimary,
                  ),
                  tooltip: '重播回复',
                ),
              ),
            ],
            const SizedBox(width: 8),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppTheme.borderSoft),
                ),
                child: TextField(
                  key: const Key('chatInputField'),
                  controller: _inputController,
                  readOnly: _controller.isRecognizing,
                  showCursor: !_controller.isRecognizing,
                  onSubmitted: (_) => _sendCurrentText(),
                  decoration: InputDecoration(
                    hintText: _controller.isRecognizing ? '正在聆听...' : '请输入消息',
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              label: '发送消息',
              button: true,
              child: Container(
                width: AppTheme.minTouchTarget,
                height: AppTheme.minTouchTarget,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A84E6), Color(0xFF2B67C7)],
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: IconButton(
                  key: const Key('sendMessageButton'),
                  onPressed: _controller.isLoading ? null : _sendCurrentText,
                  icon: const Icon(Icons.send, color: Colors.white),
                  tooltip: '发送',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _copyMessage(String content) async {
    final text = content.trim();
    if (text.isEmpty) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(content: Text('已复制消息内容')),
      );
  }
}

class _Banner extends StatelessWidget {
  const _Banner({
    required this.color,
    required this.icon,
    required this.message,
  });

  final Color color;
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: color,
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppTheme.textStrong),
          const SizedBox(width: 8),
          Expanded(child: SelectableText(message)),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.message,
    required this.isUser,
    required this.showReplay,
    required this.onCopy,
    required this.onReplay,
  });

  final ChatMessage message;
  final bool isUser;
  final bool showReplay;
  final VoidCallback onCopy;
  final Future<void> Function()? onReplay;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment: isUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF2B67C7) : AppTheme.surface,
                borderRadius: BorderRadius.circular(20),
              ),
              child: SelectableText(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : AppTheme.textStrong,
                ),
              ),
            ),
            if (showReplay)
              Wrap(
                spacing: 8,
                children: [
                  TextButton.icon(
                    key: const Key('chatCopyLastAssistantButton'),
                    onPressed: onCopy,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('复制'),
                  ),
                  TextButton.icon(
                    key: const Key('chatReplayLastAssistantButton'),
                    onPressed: onReplay,
                    icon: const Icon(Icons.volume_up_rounded, size: 18),
                    label: const Text('重播回复'),
                  ),
                ],
              )
            else
              TextButton.icon(
                key: isUser
                    ? const Key('chatCopyUserMessageButton')
                    : const Key('chatCopyAssistantMessageButton'),
                onPressed: onCopy,
                icon: const Icon(Icons.copy_rounded, size: 18),
                label: const Text('复制'),
              ),
          ],
        ),
      ),
    );
  }
}

class _PendingPublishCard extends StatelessWidget {
  const _PendingPublishCard({
    required this.intent,
    required this.onConfirm,
    required this.onCancel,
  });

  final ChatPublishIntent intent;
  final Future<void> Function() onConfirm;
  final Future<void> Function() onCancel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      key: const Key('chatPendingPublishCard'),
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: SelectionArea(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              intent.target == ChatPublishTarget.community
                  ? '待发布互助信息'
                  : '待发布社区活动',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 10),
            ..._buildDetails(),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    key: const Key('chatCancelPublishButton'),
                    onPressed: onCancel,
                    child: const Text('取消'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    key: const Key('chatConfirmPublishButton'),
                    onPressed: onConfirm,
                    child: const Text('确认发布'),
                  ),
                ),
              ],
            ),
          ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDetails() {
    switch (intent.target) {
      case ChatPublishTarget.community:
        final draft = intent.communityDraft!;
        return <Widget>[
          _DraftLine(label: '发起人', value: '${draft.username} / ${draft.identity}'),
          _DraftLine(label: '标题', value: draft.title),
          _DraftLine(label: '地点', value: draft.location),
          _DraftLine(label: '标签', value: draft.tag),
          _DraftLine(label: '内容', value: draft.summary),
        ];
      case ChatPublishTarget.activity:
        final draft = intent.activityDraft!;
        final groupLabel =
            draft.group == ElderlyActivityGroup.today ? '今日活动' : '本周活动';
        return <Widget>[
          _DraftLine(label: '组织者', value: draft.organizerName),
          _DraftLine(label: '标题', value: draft.title),
          _DraftLine(label: '时间', value: draft.time),
          _DraftLine(label: '地点', value: draft.location),
          _DraftLine(label: '标签', value: draft.tag),
          _DraftLine(label: '分组', value: groupLabel),
          _DraftLine(label: '介绍', value: draft.description),
        ];
      case null:
        return const <Widget>[];
    }
  }
}

class _DraftLine extends StatelessWidget {
  const _DraftLine({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: RichText(
        text: TextSpan(
          style: theme.textTheme.bodyMedium?.copyWith(color: AppTheme.textStrong),
          children: [
            TextSpan(
              text: '$label：',
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppTheme.textStrong,
              ),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/chat/chat_controller.dart';
import 'package:yinling_zhiban_demo/config/config_loader.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_message.dart';
import 'package:yinling_zhiban_demo/theme/app_theme.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatController _controller;
  final ConfigLoader _configLoader = ConfigLoader();
  final TextEditingController _inputController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = ChatController()..addListener(_onControllerChanged);
    _loadConfig();
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    _inputController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
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

  Future<void> _loadConfig() async {
    final cfg = await _configLoader.load();
    if (cfg != null) {
      _controller.applyConfig(cfg);
    }
  }

  bool get _hasAssistantMessage => _controller.messages.any(
    (message) => message.role == ChatRole.assistant,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceAlt,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: AppTheme.serviceBluePrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI智能助手',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                 Text(
                   '在线',
                   style: TextStyle(
                     fontSize: 12,
                     color: AppTheme.serviceBluePrimary,
                   ),
                 ),
              ],
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF333333)),
        actions: [
          IconButton(
            key: const Key('chatSpeechToggle'),
            onPressed: _controller.isSpeechSupported
                ? () => _controller.toggleSpeechPlayback()
                : null,
            icon: Icon(
              _controller.isSpeechPlaybackEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
            ),
            tooltip: _controller.isSpeechPlaybackEnabled ? '关闭播报' : '开启播报',
          ),
          PopupMenuButton<String>(
            itemBuilder: (context) => const [
              PopupMenuItem<String>(value: 'clear', child: Text('清空会话')),
            ],
          ),
        ],
      ),
      body: Container(
        key: const Key('chatServiceShell'),
        decoration: const BoxDecoration(
          gradient: AppTheme.serviceGradient,
        ),
        child: Column(
          children: [
          // Risk warning banner
          if (_controller.hasRiskWarning)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppTheme.warningSoft,
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Color(0xFFE65100),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                        '风险提示：请勿转账、勿透露验证码，遇事先联系家人。',
                        style: TextStyle(
                          color: AppTheme.accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                    ),
                  ),
                ],
              ),
            ),
          
          // Error message
          if (_controller.error != null)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: AppTheme.dangerSoft,
              child: Row(
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Color(0xFFC62828),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _controller.error!,
                      style: const TextStyle(
                        color: Color(0xFFC62828),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          
          if (_controller.isSpeechSupported)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              color: const Color(0xFFEFF5FF),
              child: Row(
                children: [
                  Icon(
                    _controller.isSpeechPlaybackEnabled ? Icons.volume_up_rounded : Icons.volume_off_rounded,
                    size: 18,
                    color: AppTheme.serviceBluePrimary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _controller.isSpeechPlaybackEnabled ? '已开启语音播报，可自动朗读 AI 回复' : '语音播报已关闭，可手动点按播放',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textMuted),
                    ),
                  ),
                ],
              ),
            ),

          // Chat messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _controller.messages.length,
              itemBuilder: (context, index) {
                final message = _controller.messages[index];
                final isUser = message.role == ChatRole.user;
                final showAvatar = !isUser;
                
                return _buildMessageCard(
                  message: message,
                  isUser: isUser,
                  showAvatar: showAvatar,
                  index: index,
                );
              },
            ),
          ),
          
          // Loading indicator
          if (_controller.isLoading)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppTheme.borderSoft),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'AI思考中...',
                           style: TextStyle(
                             fontSize: 13,
                             color: AppTheme.textMuted,
                           ),
                         ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          // Input area
          _buildInputArea(),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageCard({
    required ChatMessage message,
    required bool isUser,
    required bool showAvatar,
    required int index,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          // Avatar for AI
          if (showAvatar) ...[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: const Color(0xFFEAF2FF),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.smart_toy_rounded,
                color: AppTheme.serviceBluePrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
          ],
          
          // Message bubble
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        colors: [Color(0xFF4A84E6), Color(0xFF2B67C7)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: isUser ? null : AppTheme.surface,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(isUser ? 20 : 4),
                  topRight: Radius.circular(isUser ? 4 : 20),
                  bottomLeft: const Radius.circular(20),
                  bottomRight: const Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: isUser
                        ? const Color(0xFF2B67C7).withOpacity(0.25)
                        : Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.content,
                style: TextStyle(
                  color: isUser ? Colors.white : const Color(0xFF333333),
                  fontSize: 15,
                  height: 1.5,
                ),
              ),
            ),
          ),

          if (!isUser)
            Padding(
              padding: const EdgeInsets.only(left: 44, top: 6),
              child: Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  key: index == _controller.messages.lastIndexWhere((m) => m.role == ChatRole.assistant)
                      ? const Key('chatReplayLastAssistantButton')
                      : null,
                  onPressed: _controller.isSpeechSupported
                      ? () => _controller.replayLastAssistantMessage()
                      : null,
                  icon: const Icon(Icons.volume_up_rounded, size: 18),
                  label: const Text('播放回复'),
                ),
              ),
            ),
           
          // Spacer for user messages
          if (isUser) const SizedBox(width: 44),
        ],
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
              color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Voice button
             Container(
               width: 44,
               height: 44,
              decoration: BoxDecoration(
                color: _controller.isRecognizing
                    ? AppTheme.warningSoft
                    : AppTheme.surfaceAlt,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: AppTheme.borderSoft),
              ),
                child: IconButton(
                  key: const Key('voiceButton'),
                onPressed: _controller.isSpeechSupported
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
                tooltip: _controller.isRecognizing ? '停止识别' : '语音输入',
                ),
              ),
              const SizedBox(width: 8),

              if (_hasAssistantMessage)
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceAlt,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: AppTheme.borderSoft),
                    ),
                    child: IconButton(
                      key: const Key('chatReplayLastAssistantButton'),
                      onPressed: _controller.isSpeechSupported
                          ? () => _controller.replayLastAssistantMessage()
                          : null,
                      icon: const Icon(
                        Icons.play_circle_outline_rounded,
                        color: AppTheme.serviceBluePrimary,
                      ),
                      tooltip: '重播回复',
                    ),
                  ),
                ),
             
             // Text input
             Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceAlt,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: AppTheme.borderSoft,
                    width: 1,
                  ),
                ),
                child: TextField(
                  key: const Key('chatInputField'),
                  controller: _inputController,
                  decoration: InputDecoration(
                    hintText: _controller.isRecognizing ? '正在听您说话...' : '输入想说的话',
                    hintStyle: const TextStyle(
                      color: Color(0xFF999999),
                      fontSize: 15,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(fontSize: 15),
                  onSubmitted: (_) => _sendCurrentText(),
                  enabled: !_controller.isRecognizing,
                ),
              ),
            ),
            const SizedBox(width: 8),
            
            // Send button
            Container(
              width: 44,
              height: 44,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4A84E6), Color(0xFF2B67C7)],
                  ),
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2B67C7).withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                ],
              ),
              child: IconButton(
                key: const Key('sendMessageButton'),
                onPressed: _controller.isLoading ? null : _sendCurrentText,
                icon: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
                tooltip: '发送',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

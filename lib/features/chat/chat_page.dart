import 'package:flutter/material.dart';

import 'package:yinling_zhiban_demo/features/chat/chat_controller.dart';
import 'package:yinling_zhiban_demo/features/chat/chat_message.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  late final ChatController _controller;
  final TextEditingController _inputController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = ChatController()..addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller
      ..removeListener(_onControllerChanged)
      ..dispose();
    _inputController.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _sendCurrentText() async {
    final text = _inputController.text;
    _inputController.clear();
    await _controller.sendText(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI陪伴聊天')),
      body: SafeArea(
        child: Column(
          children: [
            if (_controller.hasRiskWarning)
              const Padding(
                padding: EdgeInsets.fromLTRB(12, 10, 12, 0),
                child: Text(
                  '风险提示：请勿转账、勿透露验证码，遇事先联系家人。',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            if (_controller.error != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Text(
                  _controller.error!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(12),
                itemCount: _controller.messages.length,
                itemBuilder: (context, index) {
                  final message = _controller.messages[index];
                  final isUser = message.role == ChatRole.user;
                  return Align(
                    alignment:
                        isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: isUser
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context)
                                .colorScheme
                                .secondaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(message.content),
                    ),
                  );
                },
              ),
            ),
            if (_controller.isLoading)
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: CircularProgressIndicator(),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      key: const Key('chatInputField'),
                      controller: _inputController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '输入想说的话',
                      ),
                      onSubmitted: (_) => _sendCurrentText(),
                    ),
                  ),
                  IconButton(
                    key: const Key('startVoiceButton'),
                    onPressed: _controller.startRecognition,
                    icon: const Icon(Icons.mic),
                    tooltip: '开始识别',
                  ),
                  IconButton(
                    key: const Key('stopVoiceButton'),
                    onPressed: _controller.stopRecognition,
                    icon: const Icon(Icons.stop_circle_outlined),
                    tooltip: '停止识别',
                  ),
                  IconButton(
                    key: const Key('sendMessageButton'),
                    onPressed: _controller.isLoading ? null : _sendCurrentText,
                    icon: const Icon(Icons.send),
                    tooltip: '发送',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

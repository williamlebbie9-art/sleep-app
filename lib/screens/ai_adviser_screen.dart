import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AIAdviserScreen extends StatefulWidget {
  const AIAdviserScreen({super.key});

  @override
  State<AIAdviserScreen> createState() => _AIAdviserScreenState();
}

class _AIAdviserScreenState extends State<AIAdviserScreen> {
  static const String _defaultEndpoint =
      'https://us-central1-sleeplock-20961.cloudfunctions.net/sleepCoachChat';

  final List<_ChatEntry> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  bool _isSending = false;

  String get _endpoint {
    const defined = String.fromEnvironment('SLEEP_COACH_ENDPOINT');
    if (defined.isNotEmpty) return defined;
    return _defaultEndpoint;
  }

  @override
  void initState() {
    super.initState();
    _messages.add(
      const _ChatEntry(
        role: _Role.assistant,
        text:
            'Hi, I\'m your Sleep Coach 🌙\n\nTell me about your sleep tonight and I\'ll help with a step-by-step plan.',
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty || _isSending) return;

    setState(() {
      _messages.add(_ChatEntry(role: _Role.user, text: text));
      _isSending = true;
    });
    _textController.clear();
    _scrollToBottom();

    try {
      final reply = await _requestCoachReply(text);
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatEntry(role: _Role.assistant, text: reply));
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _messages.add(
          const _ChatEntry(
            role: _Role.assistant,
            text:
                'I couldn\'t reach your Sleep Coach server. Please try again in a moment.',
          ),
        );
      });
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
      _scrollToBottom();
    }
  }

  Future<String> _requestCoachReply(String userText) async {
    final history = _messages
        .where((m) => m.role != _Role.system)
        .take(12)
        .map(
          (m) => {
            'role': m.role == _Role.user ? 'user' : 'assistant',
            'text': m.text,
          },
        )
        .toList();

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'message': userText, 'history': history}),
    );

    if (response.statusCode != 200) {
      throw Exception('Coach endpoint failed (${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final reply = (data['reply'] ?? '').toString().trim();
    if (reply.isEmpty) {
      throw Exception('Empty AI reply');
    }
    return reply;
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 80), () {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B2E),
      appBar: AppBar(
        title: const Text('AI Sleep Coach'),
        backgroundColor: const Color(0xFF2D2640),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _bubble(message);
              },
            ),
          ),
          if (_isSending)
            const Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: Text(
                'Sleep Coach is typing...',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          _inputBar(),
        ],
      ),
    );
  }

  Widget _bubble(_ChatEntry message) {
    final isUser = message.role == _Role.user;

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isUser ? const Color(0xFF6C63FF) : const Color(0xFF2D2640),
          border: Border.all(color: Colors.white10),
        ),
        child: Text(
          message.text,
          style: const TextStyle(color: Colors.white, height: 1.4),
        ),
      ),
    );
  }

  Widget _inputBar() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                minLines: 1,
                maxLines: 4,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Ask your Sleep Coach...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF2D2640),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: _isSending ? null : _sendMessage,
              icon: const Icon(Icons.send_rounded),
              color: const Color(0xFFB784FF),
            ),
          ],
        ),
      ),
    );
  }
}

enum _Role { user, assistant, system }

class _ChatEntry {
  final _Role role;
  final String text;

  const _ChatEntry({required this.role, required this.text});
}

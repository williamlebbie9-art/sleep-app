import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/ai_support_service.dart';
import 'package:url_launcher/url_launcher.dart';

class AISupportChatScreen extends StatefulWidget {
  const AISupportChatScreen({super.key});

  @override
  State<AISupportChatScreen> createState() => _AISupportChatScreenState();
}

class _AISupportChatScreenState extends State<AISupportChatScreen> {
  final List<ChatMessage> _messages = [];
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addBotMessage(
      "Hi! I'm your AI Support Assistant 🤖\n\n"
      "I can help you with:\n"
      "• Sleep Lock activation issues\n"
      "• Premium & subscriptions\n"
      "• Notifications & sounds\n"
      "• Account problems\n"
      "• App troubleshooting\n\n"
      "What can I help you with today?",
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: false, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(text: text, isUser: true, timestamp: DateTime.now()),
      );
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Future<void> _handleSubmit(String text) async {
    if (text.trim().isEmpty) return;

    _textController.clear();
    _addUserMessage(text);

    setState(() => _isTyping = true);

    // Check if needs human escalation
    if (AISupportService.needsHumanSupport(text)) {
      await Future.delayed(const Duration(milliseconds: 500));
      setState(() => _isTyping = false);
      _addBotMessage(
        "I understand this requires human assistance.\n\n"
        "📧 Email our support team:\nsupport@sleeploock.com\n\n"
        "We typically respond within 24 hours. Include:\n"
        "• Your issue description\n"
        "• Device model & OS version\n"
        "• Screenshots if applicable\n\n"
        "Would you like me to help with anything else?",
      );
      return;
    }

    // Get AI response
    try {
      final response = await AISupportService.getResponse(text);
      await Future.delayed(const Duration(milliseconds: 800));
      setState(() => _isTyping = false);
      _addBotMessage(response);
    } catch (e) {
      setState(() => _isTyping = false);
      _addBotMessage(
        "I'm having trouble connecting right now. Please try again or email support@sleeploock.com for immediate help.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E1B2E),
      appBar: AppBar(
        backgroundColor: const Color(0xFF2D2640),
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF6C63FF).withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.smart_toy,
                color: Color(0xFF6C63FF),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Support',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Always here to help',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                ],
              ),
            ),
          ],
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: const Icon(Icons.email_outlined),
            tooltip: 'Email Support',
            onPressed: () => _contactHumanSupport(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessage(_messages[index]);
              },
            ),
          ),
          if (_isTyping) _buildTypingIndicator(),
          _buildQuickActions(),
          _buildInputField(),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        decoration: BoxDecoration(
          gradient: message.isUser
              ? const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF5B4BDB)],
                )
              : null,
          color: message.isUser ? null : const Color(0xFF2D2640),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(20),
            topRight: const Radius.circular(20),
            bottomLeft: Radius.circular(message.isUser ? 20 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 20),
          ),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser)
              Row(
                children: [
                  Icon(
                    Icons.smart_toy,
                    size: 16,
                    color: const Color(0xFF6C63FF).withOpacity(0.8),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Support Bot',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            if (!message.isUser) const SizedBox(height: 8),
            Text(
              message.text,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.white,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(left: 16, bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF2D2640),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildDot(0),
            const SizedBox(width: 4),
            _buildDot(1),
            const SizedBox(width: 4),
            _buildDot(2),
          ],
        ),
      ),
    );
  }

  Widget _buildDot(int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (context, value, child) {
        return Opacity(
          opacity: (value + index * 0.3) % 1.0,
          child: Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: const Color(0xFF6C63FF),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  Widget _buildQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildQuickButton(
              '🔒 Activation Help',
              'How do I activate Sleep Lock?',
            ),
            _buildQuickButton('⭐ Premium Info', 'What is premium?'),
            _buildQuickButton('🔔 Notifications', 'Notifications not working'),
            _buildQuickButton('🐛 Report Bug', 'How to report a bug?'),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickButton(String label, String query) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: OutlinedButton(
        onPressed: () => _handleSubmit(query),
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: const Color(0xFF6C63FF).withOpacity(0.5)),
          backgroundColor: const Color(0xFF2D2640).withOpacity(0.5),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
      ),
    );
  }

  Widget _buildInputField() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2640),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Type your question...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.4)),
                  filled: true,
                  fillColor: const Color(0xFF1E1B2E),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                maxLines: null,
                textInputAction: TextInputAction.send,
                onSubmitted: _handleSubmit,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6C63FF), Color(0xFF5B4BDB)],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6C63FF).withOpacity(0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => _handleSubmit(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _contactHumanSupport(BuildContext context) async {
    final email = 'support@sleeploock.com';
    final subject = 'SleepLock Support Request';
    final body = 'Please describe your issue:\n\n';

    final uri = Uri(
      scheme: 'mailto',
      path: email,
      queryParameters: {'subject': subject, 'body': body},
    );

    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          _showEmailCopyDialog(context, email);
        }
      }
    } catch (e) {
      if (context.mounted) {
        _showEmailCopyDialog(context, email);
      }
    }
  }

  void _showEmailCopyDialog(BuildContext context, String email) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF2D2640),
        title: const Text(
          'Contact Support',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Copy our support email:',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E1B2E),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      email,
                      style: const TextStyle(
                        color: Color(0xFF6C63FF),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, color: Color(0xFF6C63FF)),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: email));
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Email copied!'),
                          backgroundColor: Color(0xFF6C63FF),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Close',
              style: TextStyle(color: Color(0xFF6C63FF)),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

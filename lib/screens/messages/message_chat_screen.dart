import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/conversation_model.dart';
import '../../models/message_model.dart';
import '../../services/messaging_service.dart';
import '../../services/user_session.dart';
import '../../utils/offline_handler.dart';

class MessageChatScreen extends StatefulWidget {
  final int conversationId;
  final String? initialTitle;

  const MessageChatScreen({
    super.key,
    required this.conversationId,
    this.initialTitle,
  });

  @override
  State<MessageChatScreen> createState() => _MessageChatScreenState();
}

class _MessageChatScreenState extends State<MessageChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ConversationDetailModel? _detail;
  bool _isLoading = true;
  bool _isSending = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadConversation();
    _refreshTimer = Timer.periodic(const Duration(seconds: 8), (_) {
      if (mounted) {
        _loadConversation(showLoader: false);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadConversation({bool showLoader = true}) async {
    final email = UserSession.email;
    if (email == null) {
      return;
    }

    if (showLoader && mounted) {
      setState(() => _isLoading = true);
    }

    try {
      final detail = await MessagingService.fetchConversationDetail(
        conversationId: widget.conversationId,
        userEmail: email,
      );
      await MessagingService.markConversationAsRead(
        conversationId: widget.conversationId,
        userEmail: email,
      );
      if (!mounted) return;
      setState(() {
        _detail = detail;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      OfflineHandler.showErrorSnackBar(
        context,
        e,
        onRetry: () => _loadConversation(showLoader: true),
      );
    }
  }

  Future<void> _sendMessage() async {
    final email = UserSession.email;
    final content = _messageController.text.trim();
    if (email == null || content.isEmpty || _isSending) {
      return;
    }

    setState(() => _isSending = true);
    try {
      await MessagingService.sendMessage(
        conversationId: widget.conversationId,
        senderEmail: email,
        content: content,
      );
      _messageController.clear();
      await _loadConversation(showLoader: false);
    } catch (e) {
      if (!mounted) return;
      OfflineHandler.showErrorSnackBar(context, e);
    } finally {
      if (mounted) {
        setState(() => _isSending = false);
      }
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String _formatTimestamp(DateTime dateTime) {
    final hour = dateTime.hour % 12 == 0 ? 12 : dateTime.hour % 12;
    final suffix = dateTime.hour >= 12 ? "PM" : "AM";
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return "$hour:$minute $suffix";
  }

  @override
  Widget build(BuildContext context) {
    final currentUserEmail = UserSession.email;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.initialTitle ?? _detail?.participantName ?? "Chat"),
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _detail == null
                ? const Center(child: Text("Conversation unavailable"))
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _detail!.messages.length,
                    itemBuilder: (context, index) {
                      final message = _detail!.messages[index];
                      final isMine =
                          currentUserEmail != null &&
                          message.senderEmail == currentUserEmail;
                      return _MessageBubble(
                        message: message,
                        isMine: isMine,
                        timestamp: _formatTimestamp(message.createdAt),
                      );
                    },
                  ),
          ),
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      minLines: 1,
                      maxLines: 4,
                      decoration: const InputDecoration(
                        hintText: "Type a message",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _isSending ? null : _sendMessage,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  final MessageModel message;
  final bool isMine;
  final String timestamp;

  const _MessageBubble({
    required this.message,
    required this.isMine,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
        ),
        decoration: BoxDecoration(
          color: isMine
              ? Theme.of(context).primaryColor
              : Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              message.content,
              style: TextStyle(
                color: isMine
                    ? Colors.white
                    : Theme.of(context).textTheme.bodyLarge?.color,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              timestamp,
              style: TextStyle(
                fontSize: 11,
                color: isMine ? Colors.white70 : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

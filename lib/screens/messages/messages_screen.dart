import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/conversation_model.dart';
import '../../services/messaging_service.dart';
import '../../services/user_session.dart';
import 'message_chat_screen.dart';

// Colors matching app theme
const Color kPrimary = Color(0xFF4F46E5);
const Color kSurface = Color(0xFFF8FAFC);
const Color kWhite = Color(0xFFFFFFFF);
const Color kDark = Color(0xFF1E293B);
const Color kTextDark = Color(0xFF0F172A);

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  bool _isLoading = true;
  List<ConversationModel> _conversations = [];
  List<ConversationModel> _filteredConversations = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadConversations();
  }

  Future<void> _loadConversations() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      final email = UserSession.email;
      if (email != null) {
        final convos = await MessagingService.fetchConversations(email);
        if (mounted) {
          setState(() {
            _conversations = convos;
            _filteredConversations = convos;
            _isLoading = false;
          });
          _filterConversations(_searchQuery);
        }
      }
    } catch (e) {
      debugPrint("Error loading conversations: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _filterConversations(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredConversations = List.from(_conversations);
      } else {
        _filteredConversations = _conversations.where((conv) {
          final name = _getDisplayName(conv).toLowerCase();
          return name.contains(query.toLowerCase());
        }).toList();
      }
    });
  }

  String _getDisplayName(ConversationModel conversation) {
    // If the participantEmail in the conversation matches the current user's email,
    // it means the backend returned 'me' as the participant.
    // In that case, we should show the worker's name as the other party.
    final currentUserEmail = UserSession.email?.trim().toLowerCase();
    final participantEmail = conversation.participantEmail.trim().toLowerCase();
    final userRole = UserSession.role?.trim().toLowerCase();

    // Priority Fix: If I am a standard 'user', I expect to see the Worker's name.
    if (userRole == 'user' &&
        conversation.workerName != null &&
        conversation.workerName!.isNotEmpty) {
      return conversation.workerName!;
    }

    if (currentUserEmail != null && participantEmail == currentUserEmail) {
      if (conversation.workerName != null &&
          conversation.workerName!.isNotEmpty) {
        return conversation.workerName!;
      }
    }

    return conversation.participantName.isNotEmpty
        ? conversation.participantName
        : (conversation.workerName ?? "Unknown User");
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF0F172A) : kSurface;
    final cardColor = isDark ? const Color(0xFF1E293B) : kWhite;
    final textColor = isDark ? kWhite : kTextDark;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E293B) : kPrimary,
        foregroundColor: Colors.white,
        title: const Text(
          "Messages",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Container(
            padding: const EdgeInsets.all(16.0),
            color: isDark ? const Color(0xFF1E293B) : backgroundColor,
            child: TextField(
              controller: _searchController,
              onChanged: _filterConversations,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                hintText: "Search conversations...",
                hintStyle: TextStyle(color: Colors.grey.shade500),
                prefixIcon: Icon(Icons.search, color: Colors.grey.shade500),
                filled: true,
                fillColor: isDark ? Colors.black26 : kWhite,
                contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          // --- Conversation List ---
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _loadConversations,
                    child: _filteredConversations.isEmpty
                        ? ListView(
                            children: [
                              const SizedBox(height: 60),
                              Icon(
                                Icons.chat_bubble_outline,
                                size: 64,
                                color: Colors.grey.shade400,
                              ),
                              const SizedBox(height: 16),
                              Center(
                                child: Text(
                                  _searchQuery.isEmpty
                                      ? "No messages yet"
                                      : "No results found",
                                  style: TextStyle(
                                    color: textColor.withValues(alpha: 0.7),
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: _filteredConversations.length,
                            itemBuilder: (context, index) {
                              final conversation =
                                  _filteredConversations[index];
                              return _buildConversationCard(
                                conversation,
                                cardColor,
                                textColor,
                                isDark,
                              );
                            },
                          ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildConversationCard(
    ConversationModel conversation,
    Color cardColor,
    Color textColor,
    bool isDark,
  ) {
    // Safe fallback for potentially missing fields
    final name = _getDisplayName(conversation);
    final lastMsg = conversation.lastMessage ?? "No messages";
    final unreadCount = conversation.unreadCount;
    final bool isUnread = unreadCount > 0;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.grey.shade200),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => MessageChatScreen(
                conversationId: conversation.id,
                initialTitle: name,
              ),
            ),
          );
          _loadConversations();
        },
        leading: CircleAvatar(
          radius: 28,
          backgroundColor: kPrimary.withValues(alpha: 0.1),
          // backgroundImage: conversation.otherUserImage != null ? NetworkImage(...) : null,
          child: Text(
            name.isNotEmpty ? name[0].toUpperCase() : "?",
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: kPrimary,
            ),
          ),
        ),
        title: Text(
          name,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: textColor,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            lastMsg,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isUnread ? textColor : Colors.grey,
              fontWeight: isUnread ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (conversation.lastMessageAt != null)
              Text(
                DateFormat('MMM d').format(conversation.lastMessageAt!),
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            if (isUnread) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: const BoxDecoration(
                  color: kPrimary,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  unreadCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

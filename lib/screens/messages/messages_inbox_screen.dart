import 'dart:async';

import 'package:flutter/material.dart';

import '../../models/conversation_model.dart';
import '../../services/messaging_service.dart';
import '../../services/user_session.dart';
import 'message_chat_screen.dart';

class MessagesInboxScreen extends StatefulWidget {
  const MessagesInboxScreen({super.key});

  @override
  State<MessagesInboxScreen> createState() => _MessagesInboxScreenState();
}

class _MessagesInboxScreenState extends State<MessagesInboxScreen> {
  late Future<List<ConversationModel>> _conversationsFuture;
  Timer? _refreshTimer;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    _loadConversations();
    _refreshTimer = Timer.periodic(const Duration(seconds: 12), (_) {
      if (mounted) {
        setState(_loadConversations);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _loadConversations() {
    final email = UserSession.email;
    if (email == null) {
      _conversationsFuture = Future.error("User not logged in");
      return;
    }
    _conversationsFuture = MessagingService.fetchConversations(email);
  }

  String _formatLastSeen(DateTime? dateTime) {
    if (dateTime == null) return "";
    final difference = DateTime.now().difference(dateTime);
    if (difference.inDays > 0) return "${difference.inDays}d";
    if (difference.inHours > 0) return "${difference.inHours}h";
    if (difference.inMinutes > 0) return "${difference.inMinutes}m";
    return "now";
  }

  String _getDisplayName(ConversationModel conversation) {
    final currentUserEmail = UserSession.email?.trim().toLowerCase();
    final participantEmail = conversation.participantEmail.trim().toLowerCase();
    final userRole = UserSession.role?.trim().toLowerCase();

    // Priority Fix: If I am a standard 'user', I expect to see the Worker's name.
    if (userRole == 'user' &&
        conversation.workerName != null &&
        conversation.workerName!.isNotEmpty) {
      return conversation.workerName!;
    }

    // If the backend returns the current user as the participant,
    // fallback to showing the worker's name (the other party).
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
    return Scaffold(
      appBar: AppBar(
        title: const Text("Messages"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(_loadConversations),
          ),
        ],
      ),
      body: Column(
        children: [
          // --- Search Bar ---
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: "Search conversations...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                filled: true,
                fillColor: Theme.of(context).cardColor,
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value.trim().toLowerCase();
                });
              },
            ),
          ),
          Expanded(
            child: FutureBuilder<List<ConversationModel>>(
              future: _conversationsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.chat_bubble_outline, size: 64),
                          const SizedBox(height: 12),
                          const Text("Failed to load conversations"),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => setState(_loadConversations),
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final allConversations = snapshot.data ?? [];
                // Filter based on search query
                final conversations = _searchQuery.isEmpty
                    ? allConversations
                    : allConversations.where((c) {
                        return _getDisplayName(
                          c,
                        ).toLowerCase().contains(_searchQuery);
                      }).toList();

                if (conversations.isEmpty) {
                  return Center(
                    child: Text(
                      allConversations.isEmpty
                          ? "No conversations yet. Start from a worker profile."
                          : "No results found",
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async => setState(_loadConversations),
                  child: ListView.separated(
                    itemCount: conversations.length,
                    separatorBuilder: (_, _) => const Divider(height: 1),
                    itemBuilder: (context, index) {
                      final conversation = conversations[index];
                      final displayName = _getDisplayName(conversation);
                      return ListTile(
                        leading: CircleAvatar(
                          child: Text(
                            displayName.isNotEmpty
                                ? displayName[0].toUpperCase()
                                : '?',
                          ),
                        ),
                        title: Text(
                          displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          conversation.lastMessage ?? "Open conversation",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(_formatLastSeen(conversation.lastMessageAt)),
                            const SizedBox(height: 4),
                            if (conversation.unreadCount > 0)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).primaryColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  conversation.unreadCount > 99
                                      ? '99+'
                                      : conversation.unreadCount.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MessageChatScreen(
                                conversationId: conversation.id,
                                initialTitle: displayName,
                              ),
                            ),
                          );
                          if (!mounted) return;
                          setState(_loadConversations);
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

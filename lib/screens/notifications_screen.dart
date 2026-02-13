import 'package:flutter/material.dart';
import '../models/notification_model.dart' as app_notification;

import '../services/notification_service.dart';
import '../services/job_service.dart';
import '../services/worker_service.dart';
import '../services/user_session.dart';
import '../services/theme_service.dart';
import 'jobs/job_detail_screen.dart';
import 'workers/worker_detail_screen.dart';
import 'profile/profile_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  late Future<List<app_notification.Notification>> _notificationsFuture;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  void _loadNotifications() {
    final email = UserSession.email;
    if (email != null) {
      _notificationsFuture = NotificationService.fetchNotifications(email);
    } else {
      _notificationsFuture = Future.error("User not logged in");
    }
  }

  Future<void> _markAsRead(int notificationId) async {
    try {
      await NotificationService.markAsRead(notificationId);
    } catch (e) {
      debugPrint("Error marking notification as read: $e");
    }
  }

  Future<void> _navigateToContent(
    app_notification.Notification notification,
  ) async {
    debugPrint('🔔 NOTIFICATION TAPPED:');
    debugPrint('  ID: ${notification.id}');
    debugPrint('  Type: ${notification.type}');
    debugPrint('  ReferenceId: ${notification.referenceId}');
    debugPrint('  Title: ${notification.title}');

    // Mark as read when tapped
    await _markAsRead(notification.id);

    if (notification.type == null || notification.referenceId == null) {
      debugPrint('⚠️ Cannot navigate: type or referenceId is null');
      // No navigation for notifications without type/reference
      return;
    }

    // Extract non-null values for type safety
    final refId = notification.referenceId!;
    final notifType = notification.type!;

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      switch (notifType) {
        case 'job':
          // Fetch job data first
          final jobs = await JobService.fetchJobs();
          final job = jobs.firstWhere(
            (j) => j.id == refId,
            orElse: () => throw Exception('Job not found'),
          );

          if (!mounted) return;
          Navigator.pop(context); // Close loading dialog

          // Navigate to job detail
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => JobDetailScreen(job: job)),
          );
          break;

        case 'worker':
          // Fetch worker data first
          final workers = await WorkerService.fetchWorkers();
          final worker = workers.firstWhere(
            (w) => w.id == refId,
            orElse: () => throw Exception('Worker not found'),
          );

          if (!mounted) return;
          Navigator.pop(context); // Close loading dialog

          // Navigate to worker detail
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WorkerDetailScreen(worker: worker),
            ),
          );
          break;

        case 'account':
          if (!mounted) return;
          Navigator.pop(context); // Close loading dialog

          // Navigate to profile
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
          break;

        case 'report':
          if (!mounted) return;
          Navigator.pop(context); // Close loading dialog

          // For report notifications, navigate to profile
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ProfileScreen()),
          );
          break;

        default:
          if (!mounted) return;
          Navigator.pop(context); // Close loading dialog
          break;
      }
    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Close loading dialog

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not open: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()}y ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()}mo ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  IconData _getNotificationIcon(String? type) {
    switch (type) {
      case 'job':
        return Icons.work_outline;
      case 'worker':
        return Icons.person_outline;
      case 'account':
        return Icons.account_circle_outlined;
      case 'report':
        return Icons.report_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getNotificationColor(String? type) {
    switch (type) {
      case 'job':
        return Colors.blue;
      case 'worker':
        return Colors.green;
      case 'account':
        return Colors.orange;
      case 'report':
        return Colors.red;
      default:
        return Colors.purple;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeService.themeNotifier,
      builder: (context, themeMode, child) {
        final isDark = themeMode == ThemeMode.dark;

        return Scaffold(
          backgroundColor: isDark ? Colors.grey[900] : Colors.grey[50],
          appBar: AppBar(
            title: const Text(
              "Notifications",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            backgroundColor: isDark ? Colors.grey[850] : Colors.white,
            foregroundColor: isDark ? Colors.white : Colors.black,
            elevation: 0,
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  setState(() {
                    _loadNotifications();
                  });
                },
              ),
            ],
          ),
          body: FutureBuilder<List<app_notification.Notification>>(
            future: _notificationsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: isDark ? Colors.white54 : Colors.grey,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Failed to load notifications",
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.grey[700],
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _loadNotifications();
                          });
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              }

              final notifications = snapshot.data ?? [];

              if (notifications.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: 80,
                        color: isDark ? Colors.white30 : Colors.grey[300],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "No notifications yet",
                        style: TextStyle(
                          color: isDark ? Colors.white54 : Colors.grey,
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "We'll notify you when something happens",
                        style: TextStyle(
                          color: isDark ? Colors.white38 : Colors.grey[400],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {
                    _loadNotifications();
                  });
                },
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    final iconColor = _getNotificationColor(notification.type);
                    final icon = _getNotificationIcon(notification.type);
                    final timeAgo = _formatTimeAgo(notification.createdAt);
                    final isClickable =
                        notification.type != null &&
                        notification.referenceId != null;

                    debugPrint(
                      '📋 Notification ${notification.id}: type=${notification.type}, refId=${notification.referenceId}, clickable=$isClickable',
                    );

                    return Dismissible(
                      key: Key(notification.id.toString()),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        margin: const EdgeInsets.only(bottom: 12),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (direction) async {
                        final scaffoldMessenger = ScaffoldMessenger.of(context);
                        try {
                          await NotificationService.markAsRead(notification.id);
                          setState(() {
                            notifications.removeAt(index);
                          });
                          if (!mounted) return;
                          scaffoldMessenger.showSnackBar(
                            const SnackBar(
                              content: Text("Notification dismissed"),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        } catch (e) {
                          debugPrint("Error dismissing notification: $e");
                        }
                      },

                      child: Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        color: isDark ? Colors.grey[850] : Colors.white,
                        child: InkWell(
                          onTap: isClickable
                              ? () => _navigateToContent(notification)
                              : null,
                          borderRadius: BorderRadius.circular(12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: iconColor.withAlpha(26),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(icon, color: iconColor, size: 24),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              notification.title,
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                                color: isDark
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ),
                                          if (!notification.isRead)
                                            Container(
                                              width: 8,
                                              height: 8,
                                              decoration: const BoxDecoration(
                                                color: Colors.red,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        notification.message,
                                        style: TextStyle(
                                          color: isDark
                                              ? Colors.white70
                                              : Colors.black54,
                                          fontSize: 14,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            size: 14,
                                            color: isDark
                                                ? Colors.white38
                                                : Colors.grey,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            timeAgo,
                                            style: TextStyle(
                                              color: isDark
                                                  ? Colors.white38
                                                  : Colors.grey,
                                              fontSize: 12,
                                            ),
                                          ),
                                          if (notification.type != null) ...[
                                            const SizedBox(width: 12),
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 8,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: iconColor.withAlpha(26),
                                                borderRadius:
                                                    BorderRadius.circular(4),
                                              ),
                                              child: Text(
                                                notification.type!
                                                    .toUpperCase(),
                                                style: TextStyle(
                                                  color: iconColor,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                          if (isClickable) ...[
                                            const SizedBox(width: 8),
                                            Icon(
                                              Icons.arrow_forward_ios,
                                              size: 12,
                                              color: isDark
                                                  ? Colors.white38
                                                  : Colors.grey,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../services/notification_service.dart';

class NotificationButton extends StatefulWidget {
  const NotificationButton({super.key});

  @override
  State<NotificationButton> createState() => _NotificationButtonState();
}

class _NotificationButtonState extends State<NotificationButton> {
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
    // Türkçe timeago mesajları
    timeago.setLocaleMessages('tr', timeago.TrMessages());
  }

  Future<void> _loadUnreadCount() async {
    final count = await NotificationService.getUnreadCount();
    if (mounted) {
      setState(() {
        _unreadCount = count;
      });
    }
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NotificationModal(
        onNotificationRead: () {
          _loadUnreadCount();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          icon: const Icon(Icons.notifications_outlined),
          onPressed: _showNotifications,
        ),
        if (_unreadCount > 0)
          Positioned(
            right: 8,
            top: 8,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              constraints: const BoxConstraints(
                minWidth: 16,
                minHeight: 16,
              ),
              child: Text(
                _unreadCount > 9 ? '9+' : _unreadCount.toString(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}

class NotificationModal extends StatefulWidget {
  final VoidCallback onNotificationRead;

  const NotificationModal({
    super.key,
    required this.onNotificationRead,
  });

  @override
  State<NotificationModal> createState() => _NotificationModalState();
}

class _NotificationModalState extends State<NotificationModal> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    final notifications = await NotificationService.getMyNotifications();
    if (mounted) {
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(int notificationId, int index) async {
    final success = await NotificationService.markAsRead(notificationId);
    if (success && mounted) {
      setState(() {
        _notifications[index]['isRead'] = true;
      });
      widget.onNotificationRead();
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : const Color(0xFFF5FFF5);
    final cardColor = isDark ? Colors.grey[850] : Colors.white.withOpacity(0.9);
    
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: Border(
              top: BorderSide(color: const Color(0xFF4CAF50).withOpacity(0.3), width: 1.5),
            ),
          ),
          child: Column(
            children: [
              // Handle bar
              Container(
                margin: const EdgeInsets.only(top: 12, bottom: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Header
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Bildirimler',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.white : const Color(0xFF3A5A40),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: isDark ? Colors.white70 : Colors.grey[700]),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              Divider(height: 1, color: const Color(0xFF4CAF50).withOpacity(0.2)),
              // Notifications list
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF4CAF50),
                        ),
                      )
                    : _notifications.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.notifications_none,
                                  size: 64,
                                  color: Colors.grey,
                                ),
                                SizedBox(height: 16),
                                Text(
                                  'Henüz bildirim yok',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : ListView.separated(
                            controller: scrollController,
                            padding: const EdgeInsets.all(8),
                            itemCount: _notifications.length,
                            separatorBuilder: (context, index) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final notification = _notifications[index];
                              
                              // Debug: notification yapısını kontrol et
                              // print('📬 Notification data: $notification');
                              
                              // Tüm field'ları güvenli şekilde parse et
                              final isRead = notification['isRead'] ?? notification['read'] ?? false;
                              
                              // createdAt'i güvenli parse et - Java LocalDateTime array format: [year, month, day, hour, minute, second, nano]
                              DateTime createdAt;
                              try {
                                final createdAtData = notification['createdAt'];
                                if (createdAtData is String) {
                                  createdAt = DateTime.parse(createdAtData);
                                } else if (createdAtData is List && createdAtData.length >= 3) {
                                  // Java LocalDateTime array format: [year, month, day, hour, minute, second, nano]
                                  createdAt = DateTime(
                                    createdAtData[0] as int,  // year
                                    createdAtData[1] as int,  // month
                                    createdAtData[2] as int,  // day
                                    createdAtData.length > 3 ? createdAtData[3] as int : 0,  // hour
                                    createdAtData.length > 4 ? createdAtData[4] as int : 0,  // minute
                                    createdAtData.length > 5 ? createdAtData[5] as int : 0,  // second
                                  );
                                } else {
                                  createdAt = DateTime.now();
                                }
                              } catch (e) {
                                print('⚠️ createdAt parse error: $e');
                                createdAt = DateTime.now();
                              }
                              
                              // Message'ı güvenli şekilde al
                              String message = '';
                              try {
                                if (notification['message'] is String) {
                                  message = notification['message'];
                                } else if (notification['message'] is List) {
                                  message = (notification['message'] as List).join(', ');
                                } else {
                                  message = notification['message']?.toString() ?? 'Bildirim';
                                }
                              } catch (e) {
                                print('⚠️ message parse error: $e');
                                message = 'Bildirim';
                              }
                              
                              // ID'yi güvenli al
                              final notificationId = notification['id'] is int 
                                  ? notification['id'] 
                                  : (notification['id'] is List && (notification['id'] as List).isNotEmpty
                                      ? (notification['id'] as List)[0]
                                      : 0);


                              return InkWell(
                                onTap: () {
                                  if (!isRead && notificationId != 0) {
                                    _markAsRead(notificationId, index);
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: isRead
                                        ? (isDark ? Colors.transparent : Colors.white.withOpacity(0.5))
                                        : const Color(0xFF4CAF50).withOpacity(isDark ? 0.15 : 0.12),
                                    border: Border(
                                      bottom: BorderSide(color: const Color(0xFF4CAF50).withOpacity(0.1), width: 0.5),
                                    ),
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        width: 40,
                                        height: 40,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4CAF50)
                                              .withOpacity(isRead ? 0.3 : 0.8),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.notifications,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              message,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: isRead
                                                    ? FontWeight.normal
                                                    : FontWeight.bold,
                                                color: isRead
                                                    ? (isDark ? Colors.grey[400] : Colors.grey[600])
                                                    : (isDark ? Colors.white : const Color(0xFF3A5A40)),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              timeago.format(createdAt, locale: 'tr'),
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: isDark ? Colors.grey[500] : Colors.grey[500],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (!isRead)
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF4CAF50),
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:synapseride/common/app_string.dart';
import 'package:synapseride/common/custom_color.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class NotificationItem {
  final String title;
  final String message;
  final DateTime time;
  bool isRead;
  final IconData icon;

  NotificationItem({
    required this.title,
    required this.message,
    required this.time,
    required this.isRead,
    required this.icon,
  });
}

class _NotificationScreenState extends State<NotificationScreen> {
  final List<NotificationItem> _notifications = [
    NotificationItem(
      title: AppStrings.updateAvailableTitle,
      message: AppStrings.updateAvailableMessage,
      time: DateTime.now().subtract(const Duration(hours: 2)),
      isRead: false,
      icon: Icons.system_update,
    ),
    NotificationItem(
      title: AppStrings.routeSavedTitle,
      message: AppStrings.routeSavedMessage,
      time: DateTime.now().subtract(const Duration(days: 1)),
      isRead: true,
      icon: Icons.save,
    ),
    NotificationItem(
      title: AppStrings.trafficAlertTitle,
      message: AppStrings.trafficAlertMessage,
      time: DateTime.now().subtract(const Duration(days: 2)),
      isRead: true,
      icon: Icons.traffic,
    ),
    NotificationItem(
      title: AppStrings.locationSharedTitle,
      message: AppStrings.locationSharedMessage,
      time: DateTime.now().subtract(const Duration(days: 3)),
      isRead: false,
      icon: Icons.share_location,
    ),
    NotificationItem(
      title: AppStrings.welcomeTitle,
      message: AppStrings.welcomeMessage,
      time: DateTime.now().subtract(const Duration(days: 7)),
      isRead: true,
      icon: Icons.waving_hand,
    ),
  ];

  void _markAsRead(int index) {
    setState(() {
      _notifications[index].isRead = true;
    });
  }

  String _getTimeAgo(DateTime time) {
    final Duration difference = DateTime.now().difference(time);

    if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }
  @override
  Widget build(BuildContext context) {
    final int unreadCount = _notifications.where((item) => !item.isRead).length;

    return Scaffold(
      backgroundColor: CustomColors.textPrimary,
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: CustomColors.background),
          onPressed: () => Get.back()
        ),
        backgroundColor: CustomColors.textPrimary,
        title: Text(
          '${AppStrings.notificationsTitle} ($unreadCount)',
          style: TextStyle(color: CustomColors.background),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all, color: CustomColors.background),
            onPressed: () {
              setState(() {
                for (var notification in _notifications) {
                  notification.isRead = true;
                }
              });
            },
            tooltip: AppStrings.markAllAsRead,
          ),
        ],
      ),
      body: _notifications.isEmpty
          ? Center(
        child: Text(
          AppStrings.noNotifications,
          style: TextStyle(color: CustomColors.background),
        ),
      )
          : ListView.builder(
        itemCount: _notifications.length,
        itemBuilder: (context, index) {
          final notification = _notifications[index];
          return Dismissible(
            key: Key(notification.title + index.toString()),
            background: Container(
              color: CustomColors.error,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20.0),
              child: const Icon(
                Icons.delete,
                color: CustomColors.background,
              ),
            ),
            direction: DismissDirection.endToStart,
            onDismissed: (direction) {
              setState(() {
                _notifications.removeAt(index);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text(AppStrings.notificationDismissed)),
              );
            },
            child: InkWell(
              onTap: () => _markAsRead(index),
              child: Container(
                color: notification.isRead
                    ? null
                    : Colors.blue.withOpacity(0.1),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.withOpacity(0.2),
                    child: Icon(
                      notification.icon,
                      color: CustomColors.yellow1,
                    ),
                  ),
                  title: Text(
                    notification.title,
                    style: TextStyle(
                      color: CustomColors.background,
                      fontWeight: notification.isRead
                          ? FontWeight.normal
                          : FontWeight.bold,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification.message,
                        style: TextStyle(
                          color: CustomColors.background.withOpacity(0.7),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getTimeAgo(notification.time),
                        style: const TextStyle(
                          fontSize: 12,
                          color: CustomColors.textSecondary,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                  isThreeLine: true,
                  trailing: notification.isRead
                      ? null
                      : const Icon(
                    Icons.circle,
                    color: CustomColors.yellow1,
                    size: 12,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

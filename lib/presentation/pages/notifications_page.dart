import 'package:flutter/material.dart';
import 'package:raktasetu/core/theme/app_theme.dart';
import 'package:raktasetu/core/di/service_locator.dart';
import 'package:raktasetu/core/services/firestore_service.dart';
import 'package:url_launcher/url_launcher.dart';

/// Notification Model
class AppNotification {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final DateTime timestamp;
  bool isRead;
  final String? actionLabel;
  final String? donorName;
  final String? donorBloodGroup;
  final String? location;
  final VoidCallback? onAction;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionLabel,
    this.donorName,
    this.donorBloodGroup,
    this.location,
    this.onAction,
  });
}

enum NotificationType {
  urgentNeed('Urgent Need', Icons.warning_rounded, Color(0xFFDC3545)),
  donorRequest('Donor Request', Icons.person_add_rounded, Color(0xFF0D6EFD)),
  nearbyAlert('Nearby Alert', Icons.location_on_rounded, Color(0xFF198754)),
  donationReminder(
    'Donation Reminder',
    Icons.calendar_today_rounded,
    Color(0xFFFFC107),
  ),
  successStory('Success Story', Icons.check_circle_rounded, Color(0xFF20C997)),
  systemUpdate('System Update', Icons.info_rounded, Color(0xFF6C757D));

  final String label;
  final IconData icon;
  final Color color;

  const NotificationType(this.label, this.icon, this.color);
}

/// Notifications Page
class NotificationsPage extends StatefulWidget {
  const NotificationsPage({Key? key}) : super(key: key);

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  String? _selectedFilter;
  List<AppNotification> _notifications = [];

  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLiveRequests();
  }

  Future<void> _fetchLiveRequests() async {
    setState(() => _isLoading = true);
    try {
      final requests = await getIt<FirestoreService>().getActiveBloodRequests();
      
      _notifications = requests.map((req) => AppNotification(
        id: req.id,
        title: 'Urgent Blood Need',
        message: '${req.urgency}: ${req.units} unit(s) of ${req.bloodGroup} needed for ${req.patientName}',
        type: NotificationType.urgentNeed,
        timestamp: req.createdAt,
        isRead: false,
        actionLabel: 'Help Now',
        location: req.hospitalName,
        onAction: () => launchUrl(Uri(scheme: 'tel', path: req.contactNumber)),
      )).toList();
    } catch (e) {
      _notifications = [];
      _showActionSnackbar('Failed to load real requests');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _initializeNotifications() {
    // Deprecated: Now using _fetchLiveRequests instead.
    _notifications = [];
  }

  void _showActionSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.bloodRed,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _toggleNotificationRead(AppNotification notification) {
    setState(() {
      notification.isRead = !notification.isRead;
    });
  }

  void _deleteNotification(AppNotification notification) {
    setState(() {
      _notifications.removeWhere((n) => n.id == notification.id);
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Notification dismissed')));
  }

  List<AppNotification> _getFilteredNotifications() {
    if (_selectedFilter == null) {
      return _notifications;
    }
    return _notifications.where((n) => n.type.name == _selectedFilter).toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  @override
  Widget build(BuildContext context) {
    final filteredNotifications = _getFilteredNotifications();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Notifications',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        elevation: 0,
        centerTitle: false,
        actions: [
          if (_unreadCount > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.bloodRed,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$_unreadCount',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : SingleChildScrollView(
              child: Column(
                children: [
                  // Premium Header Section
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.bloodRed,
                          AppTheme.bloodRed.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(24),
                        bottomRight: Radius.circular(24),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Stay Updated',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Important updates about blood donations and requests',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Filter Tabs
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Filter by Type',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              _buildFilterChip(
                                label: 'All',
                                isSelected: _selectedFilter == null,
                                onTap: () {
                                  setState(() => _selectedFilter = null);
                                },
                              ),
                              const SizedBox(width: 8),
                              ..._buildTypeFilterChips(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Notifications List
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: filteredNotifications.isEmpty
                        ? _buildEmptyFilterState()
                        : Column(
                            children: List.generate(
                              filteredNotifications.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: _buildNotificationCard(
                                  filteredNotifications[index],
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 100),
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: AppTheme.bloodRed.withOpacity(0.1),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 50,
              color: AppTheme.bloodRed,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'No Notifications',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'re all caught up! Check back later for updates',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  Widget _buildEmptyFilterState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 80),
          Icon(
            Icons.filter_list_off_rounded,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No notifications found',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            'Try selecting a different filter',
            style: TextStyle(fontSize: 13, color: Colors.grey[500]),
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.bloodRed : Colors.white,
          border: Border.all(
            color: isSelected ? AppTheme.bloodRed : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : Colors.grey[700],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildTypeFilterChips() {
    return [
          NotificationType.urgentNeed,
          NotificationType.donorRequest,
          NotificationType.nearbyAlert,
          NotificationType.donationReminder,
        ]
        .map(
          (type) => Padding(
            padding: const EdgeInsets.only(right: 8),
            child: _buildFilterChip(
              label: type.label,
              isSelected: _selectedFilter == type.name,
              onTap: () {
                setState(() => _selectedFilter = type.name);
              },
            ),
          ),
        )
        .toList();
  }

  Widget _buildNotificationCard(AppNotification notification) {
    return Container(
      decoration: BoxDecoration(
        color: notification.isRead ? Colors.white : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: notification.isRead ? Colors.grey[200]! : Colors.grey[300]!,
          width: notification.isRead ? 1 : 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(notification.isRead ? 0.03 : 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header with Icon, Title, and Timestamp
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Notification Icon
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: notification.type.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        notification.type.icon,
                        color: notification.type.color,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  notification.title,
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.grey[900],
                                  ),
                                ),
                              ),
                              if (!notification.isRead)
                                Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppTheme.bloodRed,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _getTimeAgo(notification.timestamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Message
                Text(
                  notification.message,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),

                // Donor Info (if available)
                if (notification.donorName != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_outline,
                          size: 18,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            notification.donorName!,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.bloodRed,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            notification.donorBloodGroup ?? 'Unknown',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                // Location (if available)
                if (notification.location != null) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 14,
                        color: Colors.grey[500],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        notification.location!,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: notification.onAction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.bloodRed,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      notification.actionLabel ?? 'Action',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      notification.isRead
                          ? Icons.mark_email_unread_outlined
                          : Icons.mark_email_read_outlined,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    onPressed: () => _toggleNotificationRead(notification),
                  ),
                ),
                SizedBox(
                  width: 40,
                  height: 40,
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    icon: Icon(
                      Icons.close_rounded,
                      size: 20,
                      color: Colors.grey[600],
                    ),
                    onPressed: () => _deleteNotification(notification),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}

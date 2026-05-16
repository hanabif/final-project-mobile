import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../l10n/app_localizations.dart';
import '../cubit/notification_cubit.dart';
import '../../domain/entities/notification_item.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date.toLocal());
    if (diff.inMinutes < 1)  return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours   < 24) return '${diff.inHours}h ago';
    if (diff.inDays    < 7)  return '${diff.inDays}d ago';
    final d = date.toLocal();
    const months = [
      'Jan','Feb','Mar','Apr','May','Jun',
      'Jul','Aug','Sep','Oct','Nov','Dec',
    ];
    return '${months[d.month - 1]} ${d.day}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n   = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F6FA),
      appBar: CustomAppBar(
        title: l10n.notifications,
        showBackButton: true,
        showThemeToggle: true,
        showNotification: false,
        backgroundColor: const Color(0xFF005C45),
        titleColor: isDark ? Colors.white : const Color(0xFF1A1A2E),
      ),
      body: BlocListener<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(state.message)));
          }
        },
        child: BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            if (state is NotificationLoading ||
                state is NotificationInitial) {
              return const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF005C45)),
              );
            }
            if (state is NotificationLoaded) {
              final notifications = state.notifications;
              final hasUnread = notifications.any((n) => !n.isRead);
              if (notifications.isEmpty) {
                return _EmptyState(l10n: l10n, isDark: isDark);
              }
              // Group: unread first
              final unread =
                  notifications.where((n) => !n.isRead).toList();
              final read =
                  notifications.where((n) => n.isRead).toList();

              return Column(
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                      child: TextButton.icon(
                        onPressed: hasUnread
                            ? () => context
                                .read<NotificationCubit>()
                                .markAllAsRead()
                            : null,
                        icon: Icon(
                          Icons.done_all_rounded,
                          size: 18,
                          color: hasUnread
                              ? const Color(0xFF005C45)
                              : Colors.grey.shade400,
                        ),
                        label: Text(
                          l10n.markAllAsRead,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: hasUnread
                                ? const Color(0xFF005C45)
                                : Colors.grey.shade400,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
                      children: [
                        if (unread.isNotEmpty) ...[
                          _GroupHeader(
                              label: 'New', count: unread.length, isDark: isDark),
                          const SizedBox(height: 8),
                          ...unread.map((n) => _NotificationCard(
                                notif: n,
                                isDark: isDark,
                                timeAgo: _timeAgo(n.date),
                                l10n: l10n,
                              )),
                          const SizedBox(height: 20),
                        ],
                        if (read.isNotEmpty) ...[
                          _GroupHeader(
                              label: 'Earlier',
                              count: read.length,
                              isDark: isDark),
                          const SizedBox(height: 8),
                          ...read.map((n) => _NotificationCard(
                                notif: n,
                                isDark: isDark,
                                timeAgo: _timeAgo(n.date),
                                l10n: l10n,
                              )),
                        ],
                      ],
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Notification Card
// ════════════════════════════════════════════════════════════════════════════

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({
    required this.notif,
    required this.isDark,
    required this.timeAgo,
    required this.l10n,
  });

  final NotificationItem notif;
  final bool isDark;
  final String timeAgo;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final isUnread = !notif.isRead;

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: isUnread
              ? Border.all(
                  color: const Color(0xFF005C45).withOpacity(0.25),
                  width: 1.5)
              : null,
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withOpacity(0.22)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 14,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Accent stripe for unread
                if (isUnread)
                  Container(
                    width: 4,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF005C45), Color(0xFF00A86B)],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Icon bubble
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: isUnread
                                ? const Color(0xFF005C45).withOpacity(0.12)
                                : (isDark
                                    ? Colors.white.withOpacity(0.06)
                                    : Colors.black.withOpacity(0.05)),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            isUnread
                                ? Icons.notifications_active_rounded
                                : Icons.notifications_none_rounded,
                            size: 20,
                            color: isUnread
                                ? const Color(0xFF005C45)
                                : (isDark
                                    ? Colors.white38
                                    : Colors.black38),
                          ),
                        ),
                        const SizedBox(width: 12),

                        // Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Text(
                                      notif.title,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: isUnread
                                            ? FontWeight.w700
                                            : FontWeight.w500,
                                        color: isDark
                                            ? Colors.white
                                            : const Color(0xFF1A1A2E),
                                        height: 1.3,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    timeAgo,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: isDark
                                          ? Colors.white38
                                          : Colors.black38,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                notif.body,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: isDark
                                      ? Colors.white54
                                      : Colors.black54,
                                  height: 1.4,
                                ),
                              ),
                              if (isUnread) ...[
                                const SizedBox(height: 10),
                                GestureDetector(
                                  onTap: () {
                                    context
                                        .read<NotificationCubit>()
                                        .markAsRead(notif.id);
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                      content: Text(
                                          l10n.notificationMarkedAsRead),
                                      duration:
                                          const Duration(seconds: 2),
                                    ));
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF005C45)
                                          .withOpacity(0.10),
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Text(
                                      l10n.markAsRead,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF005C45),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Group header
// ════════════════════════════════════════════════════════════════════════════

class _GroupHeader extends StatelessWidget {
  const _GroupHeader(
      {required this.label, required this.count, required this.isDark});
  final String label;
  final int count;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: isDark ? Colors.white54 : Colors.black45,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
          decoration: BoxDecoration(
            color: const Color(0xFF005C45).withOpacity(0.12),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$count',
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Color(0xFF005C45),
            ),
          ),
        ),
      ],
    );
  }
}

// ════════════════════════════════════════════════════════════════════════════
// Empty state
// ════════════════════════════════════════════════════════════════════════════

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.l10n, required this.isDark});
  final AppLocalizations l10n;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : const Color(0xFFF5F6FA),
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 42,
              color: isDark ? Colors.white24 : Colors.black12,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            l10n.noNotificationsYet,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : const Color(0xFF1A1A2E),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "You're all caught up!",
            style: TextStyle(
              fontSize: 13,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}
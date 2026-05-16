import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../features/settings/presentation/cubits/settings_cubit.dart';
import '../../features/settings/presentation/cubits/settings_state.dart';
import '../../features/notification/presentation/cubit/notification_cubit.dart';
import '../../features/complaint/presentation/cubits/profile/profile_cubit.dart';
import '../routes/route_names.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final bool showBackButton;
  final bool showThemeToggle;
  final bool showNotification;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor;
  final Color? titleColor;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    this.title,
    this.showBackButton = false,
    this.showThemeToggle = false,
    this.showNotification = false,
    this.onBackPressed,
    this.backgroundColor,
    this.titleColor,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? const Color(0xFF005C45),
      leading: showBackButton
          ? IconButton(
              icon: Icon(
                Icons.arrow_back,
                color: titleColor ?? Colors.white,
              ),
              onPressed: onBackPressed ?? () => Navigator.pop(context),
            )
          : null,
      title: title != null
          ? Text(
              title!,
              style: TextStyle(
                color: titleColor ?? Colors.white,
                fontWeight: FontWeight.bold,
              ),
            )
          : null,
      centerTitle: title != null,
      elevation: 0,
      bottom: bottom,
      actions: [
        if (showThemeToggle) _buildThemeToggleButton(context),
        if (showNotification) _buildNotificationButton(context),
      ],
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        int unreadCount = 0;
        if (state is NotificationLoaded) {
          unreadCount = state.notifications.where((n) => !n.isRead).length;
        }
        return IconButton(
          icon: unreadCount > 0
              ? Badge(
                  label: Text(unreadCount.toString()),
                  child: Icon(Icons.notifications, color: titleColor ?? Colors.white, size: 30),
                )
              : Icon(Icons.notifications, color: titleColor ?? Colors.white, size: 30),
          onPressed: () {
            Navigator.pushNamed(context, RouteNames.notifications);
          },
        );
      },
    );
  }

  Widget _buildThemeToggleButton(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        if (state is SettingsLoaded) {
          final isDark = state.settings.themeMode == 'Dark';
          return IconButton(
            icon: Icon(
              isDark ? Icons.light_mode : Icons.dark_mode,
              color: titleColor ?? Colors.white,
            ),
            onPressed: () {
              final newTheme = isDark ? 'Light' : 'Dark';
              context.read<SettingsCubit>().setThemeMode(newTheme);
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(
    kToolbarHeight + (bottom?.preferredSize.height ?? 0),
  );
}

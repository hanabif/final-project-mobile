import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../../features/settings/presentation/cubits/settings_cubit.dart';
import '../../features/settings/presentation/cubits/settings_state.dart';
import '../../features/notification/presentation/cubit/notification_cubit.dart';
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
  final String? logoAssetPath;
  final double logoWidth;
  final double logoHeight;
  final List<Widget>? actions;

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
    this.logoAssetPath,
    this.logoWidth = 96,
    this.logoHeight = 28,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final bool showLogo = logoAssetPath != null;
    final bool hasLeading = showBackButton || showLogo;

    // Dynamically calculate leadingWidth to accommodate both widgets safely
    final double? calculatedLeadingWidth = () {
      if (!hasLeading) return null;
      double width = 0.0;
      
      if (showBackButton) {
        width += 42.0; // 14dp left margin + 26dp icon size
      }
      if (showLogo) {
        width += logoWidth;
        width += showBackButton ? 10.0 : 16.0; // Tighter gap if back button exists
      }
      width += 8.0; // Safe cushion margin on the right side
      return width;
    }();

    return AppBar(
      backgroundColor: backgroundColor ?? const Color(0xFF005C45),
      leadingWidth: calculatedLeadingWidth,
      leading: hasLeading
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (showBackButton)
                  IconButton(
                    iconSize: 26,
                    icon: Icon(
                      Icons.arrow_back,
                      color: titleColor ?? Colors.white,
                    ),
                    onPressed: onBackPressed ?? () => Navigator.pop(context),
                  ),
                if (showLogo)
                  Padding(
                    // Give the logo some breathing room if there's no back button
                    padding: EdgeInsets.only(left: showBackButton ? 0.0 : 0.0),
                    child: Image.asset(
                      logoAssetPath!,
                      width: logoWidth,
                      height: logoHeight,
                      fit: BoxFit.contain,
                      color: titleColor ?? Colors.white,
                    ),
                  ),
              ],
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
      centerTitle: false,
      elevation: 0,
      bottom: bottom,
      actions: [
        if (showThemeToggle) _buildThemeToggleButton(context),
        if (showNotification) _buildNotificationButton(context),
        ...?actions,
      ],
    );
  }

  Widget _buildNotificationButton(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, settingsState) {
        bool notificationsEnabled = true;
        if (settingsState is SettingsLoaded) {
          notificationsEnabled = settingsState.settings.isNotificationsEnabled;
        }
        
        if (!notificationsEnabled) {
          return const SizedBox.shrink();
        }
        
        return BlocBuilder<NotificationCubit, NotificationState>(
          builder: (context, state) {
            int unreadCount = 0;
            if (state is NotificationLoaded) {
              unreadCount = state.notifications.where((n) => !n.isRead).length;
            }
            return IconButton(
              iconSize: 26,
              icon: unreadCount > 0
                  ? Badge(
                      label: Text(unreadCount.toString()),
                      child: Icon(Iconsax.notification, color: titleColor ?? Colors.white, size: 26),
                    )
                  : Icon(Iconsax.notification, color: titleColor ?? Colors.white, size: 26),
              onPressed: () {
                Navigator.pushNamed(context, RouteNames.notifications);
              },
            );
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
            iconSize: 26,
            icon: Icon(
              isDark ? Iconsax.sun_1 : Iconsax.moon,
              color: titleColor ?? Colors.white,
              size: 26,
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
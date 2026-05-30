import 'dart:async';
import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class ModernBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final FutureOr<void> Function() onHomeTap;
  final FutureOr<void> Function() onReportTap;
  final FutureOr<void> Function() onComplaintsTap;
  final FutureOr<void> Function() onProfileTap;

  const ModernBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onHomeTap,
    required this.onReportTap,
    required this.onComplaintsTap,
    required this.onProfileTap,
  });

  @override
  State<ModernBottomNavigationBar> createState() => _ModernBottomNavigationBarState();
}

class _ModernBottomNavigationBarState extends State<ModernBottomNavigationBar> {
  final GlobalKey<CurvedNavigationBarState> _navKey = GlobalKey();
  late int _internalIndex;

  @override
  void initState() {
    super.initState();
    _internalIndex = widget.currentIndex;
  }

  @override
  void didUpdateWidget(ModernBottomNavigationBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex != widget.currentIndex) {
      _internalIndex = widget.currentIndex;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenHeight = MediaQuery.of(context).size.height;
    
    // Making it responsive based on screen height
    final double navBarHeight = screenHeight > 800 ? 75.0 : 60.0;

    final l10n = AppLocalizations.of(context)!;

    return CurvedNavigationBar(
      key: _navKey,
      index: widget.currentIndex,
      height: navBarHeight,
      color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
      buttonBackgroundColor: const Color(0xFF005C45),
      backgroundColor: Colors.transparent, // transparent to blend with the scaffold background
      animationDuration: const Duration(milliseconds: 300), // Smooth transition
      items: [
        _NavItem(
          icon: Iconsax.home,
          label: l10n.home,
          isSelected: _internalIndex == 0,
          isDark: isDark,
        ),
        _NavItem(
          icon: Iconsax.document_text,
          label: l10n.report,
          isSelected: _internalIndex == 1,
          isDark: isDark,
        ),
        _NavItem(
          icon: Icons.receipt_long_rounded,
          label: l10n.bottomNavComplaints,
          isSelected: _internalIndex == 2,
          isDark: isDark,
        ),
        _NavItem(
          icon: Iconsax.user,
          label: l10n.profile,
          isSelected: _internalIndex == 3,
          isDark: isDark,
        ),
      ],
      onTap: (index) async {
        if (index == _internalIndex) return;

        setState(() {
          _internalIndex = index;
        });

        // Give the CurvedNavigationBar time to show its smooth transition animation
        await Future.delayed(const Duration(milliseconds: 300));

        if (index == 0) {
          await widget.onHomeTap();
          if (mounted && _internalIndex != widget.currentIndex) {
            setState(() => _internalIndex = widget.currentIndex);
            _navKey.currentState?.setPage(widget.currentIndex);
          }
        } else if (index == 1) {
          await widget.onReportTap();
          // Reset index after returning from Report screen
          if (mounted && _internalIndex != widget.currentIndex) {
            setState(() => _internalIndex = widget.currentIndex);
            _navKey.currentState?.setPage(widget.currentIndex);
          }
        } else if (index == 2) {
          await widget.onComplaintsTap();
          if (mounted && _internalIndex != widget.currentIndex) {
            setState(() => _internalIndex = widget.currentIndex);
            _navKey.currentState?.setPage(widget.currentIndex);
          }
        } else if (index == 3) {
          await widget.onProfileTap();
          // Reset index after returning from Profile screen
          if (mounted && _internalIndex != widget.currentIndex) {
            setState(() => _internalIndex = widget.currentIndex);
            _navKey.currentState?.setPage(widget.currentIndex);
          }
        }
      },
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.isDark,
  });

  final IconData icon;
  final String label;
  final bool isSelected;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.white : (isDark ? Colors.white70 : Colors.black87);

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: color,
          ),
        ),
      ],
    );
  }
}
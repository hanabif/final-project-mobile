import 'dart:async';
import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

class ModernBottomNavigationBar extends StatefulWidget {
  final int currentIndex;
  final FutureOr<void> Function() onHomeTap;
  final FutureOr<void> Function() onReportTap;
  final FutureOr<void> Function() onProfileTap;

  const ModernBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onHomeTap,
    required this.onReportTap,
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

    return CurvedNavigationBar(
      key: _navKey,
      index: widget.currentIndex,
      height: navBarHeight,
      color: isDark ? const Color(0xFF1C1F2E) : Colors.white,
      buttonBackgroundColor: const Color(0xFF005C45),
      backgroundColor: Colors.transparent, // transparent to blend with the scaffold background
      animationDuration: const Duration(milliseconds: 300), // Smooth transition
      items: [
        Icon(
          Iconsax.home,
          size: 30,
          color: _internalIndex == 0 ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
        ),
        Icon(
          Iconsax.document_text,
          size: 30,
          color: _internalIndex == 1 ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
        ),
        Icon(
          Iconsax.user,
          size: 30,
          color: _internalIndex == 2 ? Colors.white : (isDark ? Colors.white70 : Colors.black87),
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
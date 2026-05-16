import 'package:flutter/material.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';

import '../../l10n/app_localizations.dart';

class ModernBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final VoidCallback onHomeTap;
  final VoidCallback onReportTap;
  final VoidCallback onProfileTap;

  const ModernBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onHomeTap,
    required this.onReportTap,
    required this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      iconSize: 26,
      selectedFontSize: 12,
      unselectedFontSize: 12,
      selectedItemColor: const Color(0xFF005C45),
      unselectedItemColor: Colors.grey.shade600,
      onTap: (index) {
        if (index == 0) {
          onHomeTap();
        } else if (index == 1) {
          onReportTap();
        } else if (index == 2) {
          onProfileTap();
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: const Icon(Iconsax.home),
          label: l10n.home,
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Iconsax.document_text,
            size: 26,
            color: Colors.grey.shade600,
          ),
          activeIcon: const Icon(
            Iconsax.document_text,
            size: 26,
          ),
          label: l10n.report,
        ),
        BottomNavigationBarItem(
          icon: const Icon(Iconsax.user),
          label: l10n.profile,
        ),
      ],
    );
  }
}
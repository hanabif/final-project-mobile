import 'package:flutter/material.dart';

import '../../../../core/widgets/custom_app_bar.dart';
import '../../../../l10n/app_localizations.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final background =
        isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F6FA);

    final foreground = Theme.of(context).colorScheme.onSurface;

    final aboutText =
        '${l10n.aboutServiceShortDescription}\n\n${l10n.aboutServiceFocus}';

    return Scaffold(
      backgroundColor: background,
      appBar: CustomAppBar(
        title: l10n.about,
        showBackButton: true,
        showNotification: true,
        backgroundColor:
            isDark ? const Color(0xFF12161F) : const Color(0xFF005C45),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Icon
            Center(
              child: Container(
                width: 78,
                height: 78,
                decoration: BoxDecoration(
                  color: const Color(0xFFFCD703).withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.campaign_rounded,
                  size: 38,
                  color: Color(0xFF005C45),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // Title
            Text(
              l10n.aboutServiceTitle,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: foreground,
                height: 1.3,
              ),
            ),

            const SizedBox(height: 18),

            // Full Content
            Text(
              aboutText,
              style: TextStyle(
                fontSize: 15,
                height: 1.8,
                color: foreground.withValues(alpha: 0.82),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
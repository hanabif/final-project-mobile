import 'package:flutter/material.dart';

class ConnectionLostStateView extends StatelessWidget {
  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onRetry;

  const ConnectionLostStateView({
    super.key,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 240,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 180,
                    height: 180,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF7B83A6).withValues(alpha: 0.08),
                    ),
                  ),
                  Container(
                    width: 125,
                    height: 125,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF7B83A6).withValues(alpha: 0.10),
                    ),
                  ),
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF7B83A6).withValues(alpha: 0.16),
                    ),
                    child: const Icon(
                      Icons.wifi_off_rounded,
                      size: 34,
                      color: Color(0xFF2A2F45),
                    ),
                  ),
                  Positioned(
                    top: 36,
                    left: 34,
                    child: _DecorDot(isLine: false),
                  ),
                  Positioned(
                    top: 82,
                    right: 22,
                    child: _DecorDot(isLine: true),
                  ),
                  Positioned(
                    bottom: 56,
                    left: 20,
                    child: _DecorDot(isLine: true),
                  ),
                  Positioned(
                    bottom: 26,
                    right: 30,
                    child: _DecorDot(isLine: false),
                  ),
                  Positioned(
                    bottom: 22,
                    child: Container(
                      width: 150,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFF2A2F45).withValues(alpha: 0.25),
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
              decoration: BoxDecoration(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.06)
                    : const Color(0xFFF3F4FB),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : const Color(0xFF2A2F45),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                height: 1.5,
                color: isDark ? Colors.white70 : const Color(0xFF7B83A6),
              ),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF005C45),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(buttonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DecorDot extends StatelessWidget {
  final bool isLine;

  const _DecorDot({required this.isLine});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: isLine ? 14 : 18,
      height: isLine ? 14 : 18,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: const Color(0xFF7B83A6).withValues(alpha: 0.55),
          width: 3,
        ),
      ),
      child: isLine
          ? Center(
              child: Container(
                width: 4,
                height: 4,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF7B83A6),
                ),
              ),
            )
          : null,
    );
  }
}
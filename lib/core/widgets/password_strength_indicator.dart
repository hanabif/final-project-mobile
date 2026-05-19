import 'package:flutter/material.dart';
import '../utils/password_validator.dart';
import '../../l10n/app_localizations.dart';

class PasswordStrengthIndicator extends StatelessWidget {
  final String password;
  final bool isDark;

  const PasswordStrengthIndicator({
    required this.password,
    required this.isDark,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();

    final strength = PasswordValidator.getPasswordStrength(password);
    final l10n = AppLocalizations.of(context)!;

    String strengthLabel;
    Color strengthColor;

    switch (strength) {
      case PasswordStrength.weak:
        strengthLabel = l10n.passwordStrengthWeak;
        strengthColor = Colors.red;
        break;
      case PasswordStrength.fair:
        strengthLabel = l10n.passwordStrengthFair;
        strengthColor = Colors.orange;
        break;
      case PasswordStrength.good:
        strengthLabel = l10n.passwordStrengthGood;
        strengthColor = Colors.amber;
        break;
      case PasswordStrength.strong:
        strengthLabel = l10n.passwordStrengthStrong;
        strengthColor = Colors.green;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(top: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: strength.index / PasswordStrength.values.length,
                    minHeight: 4,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                strengthLabel,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: strengthColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Required: 8+ characters, uppercase, lowercase, number, and special character',
            style: TextStyle(
              fontSize: 11,
              color: isDark ? Colors.white38 : Colors.black38,
            ),
          ),
        ],
      ),
    );
  }
}

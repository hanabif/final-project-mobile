import 'package:flutter/material.dart';
import '../../../../l10n/app_localizations.dart';

class ComplaintSuccessScreen extends StatelessWidget {

  const ComplaintSuccessScreen({
    super.key
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.success),
        automaticallyImplyLeading: false, // Prevent going back to form
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 100,
              ),
              const SizedBox(height: 24),
              Text(
                l10n.complaintSubmittedSuccessfully,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),

              Text(
                '${l10n.statusSubmitted}',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 48),
              ElevatedButton(
                onPressed: () {
                  // Pop until we reach the dashboard (assuming dashboard is at root or specific route)
                  // For now, we'll just pop twice to simulate going back to dashboard,
                  // or use pushAndRemoveUntil if route is named.
                  if (Navigator.canPop(context)) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  }
                },
                child: Text(l10n.returnToDashboard),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

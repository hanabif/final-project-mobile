import 'package:flutter/material.dart';

class ComplaintSuccessScreen extends StatelessWidget {
  final String complaintId;

  const ComplaintSuccessScreen({
    super.key,
    required this.complaintId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Success'),
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
              const Text(
                'Complaint Submitted Successfully!',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    const Text('Complaint ID:'),
                    Text(
                      complaintId,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Status: Submitted',
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
                child: const Text('Return to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

class ComplaintStatusScreen extends StatelessWidget {
  final String complaintId;

  const ComplaintStatusScreen({
    super.key,
    required this.complaintId,
  });

  @override
  Widget build(BuildContext context) {
    // Note: In a real app, we'd use GetComplaintStatusUseCase via a Cubit
    // For now, this is a placeholder UI showing the status.
    return Scaffold(
      appBar: AppBar(
        title: const Text('Complaint Status'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Complaint Details',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            StatusItem(label: 'Complaint ID', value: complaintId),
            const StatusItem(label: 'Status', value: 'Submitted', valueColor: Colors.blue),
            const StatusItem(label: 'Date', value: 'March 9, 2026'),
            const StatusItem(label: 'Category', value: 'Infrastructure'),
            const SizedBox(height: 32),
            const Text(
              'Timeline',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const TimelineItem(
              title: 'Complaint Submitted',
              subtitle: 'Your complaint has been received and is being processed.',
              isLast: true,
            ),
          ],
        ),
      ),
    );
  }
}

class StatusItem extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const StatusItem({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 16)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: valueColor)),
        ],
      ),
    );
  }
}

class TimelineItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final bool isLast;

  const TimelineItem({
    super.key,
    required this.title,
    required this.subtitle,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            if (!isLast)
              Container(
                width: 2,
                height: 40,
                color: Colors.green,
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(subtitle, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ],
    );
  }
}

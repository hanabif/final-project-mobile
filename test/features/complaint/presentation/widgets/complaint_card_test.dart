import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:complaint_resolution_app/features/complaint/presentation/widgets/complaint_card.dart';
import 'package:complaint_resolution_app/features/complaint/domain/entities/complaint.dart';

void main() {
  final testComplaint = Complaint(
    id: '1',
    title: 'Water Leakage',
    description: 'There is a big water leak in my street.',
    latitude: 0.0,
    longitude: 0.0,
    organizationId: 'Water Board',
    status: 'Pending',
    createdAt: DateTime(2023, 10, 5),
  );

  Widget createTestableWidget(Widget child) {
    return MaterialApp(
      home: Scaffold(body: child),
    );
  }

  group('ComplaintCard Widget Tests', () {
    testWidgets('renders complaint details correctly', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(createTestableWidget(
        ComplaintCard(
          complaint: testComplaint,
          onTap: () => tapped = true,
        ),
      ));

      expect(find.text('Water Leakage'), findsOneWidget);
      expect(find.text('Water Board'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
      expect(find.textContaining('Oct 5, 2023'), findsOneWidget);

      await tester.tap(find.byType(ComplaintCard));
      expect(tapped, isTrue);
    });

    testWidgets('shows correct color for different statuses', (tester) async {
      expect(ComplaintCard.statusColor('Pending'), const Color(0xFF3B82F6));
      expect(ComplaintCard.statusColor('Resolved'), const Color(0xFF22C55E));
      expect(ComplaintCard.statusColor('Rejected'), const Color(0xFFEF4444));
      expect(ComplaintCard.statusColor('In Progress'), const Color(0xFFF59E0B));
    });

    testWidgets('shows correct icon for different statuses', (tester) async {
      expect(ComplaintCard.statusIcon('Pending'), Icons.upload_file_rounded);
      expect(ComplaintCard.statusIcon('Resolved'), Icons.check_circle_rounded);
      expect(ComplaintCard.statusIcon('Rejected'), Icons.cancel_rounded);
      expect(ComplaintCard.statusIcon('In Progress'), Icons.autorenew_rounded);
    });
  });
}

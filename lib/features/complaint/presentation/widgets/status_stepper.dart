import 'package:flutter/material.dart';

class StatusStepper extends StatelessWidget {
  final String status;

  const StatusStepper({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    // Determine current step index
    int currentStep = 0;
    String normalizedStatus = status.toLowerCase();
    if (normalizedStatus == 'submitted' || normalizedStatus == 'pending') {
      currentStep = 0;
    } else if (normalizedStatus == 'manual review' || normalizedStatus == 'manual_review' || normalizedStatus == 'under review') {
      currentStep = 1;
    } else if (normalizedStatus == 'in progress' || normalizedStatus == 'in_progress') {
      currentStep = 2;
    } else if (normalizedStatus == 'resolved' || normalizedStatus == 'completed') {
      currentStep = 3;
    } else if (normalizedStatus == 'rejected') {
      // represent rejected with a special flag by setting to final step but UI will be red
      currentStep = 4;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStep(
            icon: Icons.check,
            label: 'Submitted',
            isActive: currentStep >= 0,
            isCompleted: currentStep > 0,
          ),
          _buildConnector(isActive: currentStep >= 1),
          _buildStep(
            icon: Icons.hourglass_top,
            label: 'Manual Review',
            isActive: currentStep >= 1,
            isCompleted: currentStep > 1,
          ),
          _buildConnector(isActive: currentStep >= 2),
          _buildStep(
            icon: Icons.refresh_rounded,
            label: 'In Progress',
            isActive: currentStep >= 2,
            isCompleted: currentStep > 2,
          ),
          _buildConnector(isActive: currentStep >= 3),
          if (currentStep == 4)
            _buildStep(
              icon: Icons.block,
              label: 'Rejected',
              isActive: true,
              isCompleted: false,
              isLast: true,
            )
          else
            _buildStep(
              icon: Icons.flag_outlined,
              label: 'Resolved',
              isActive: currentStep >= 3,
              isCompleted: currentStep > 3,
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String label,
    required bool isActive,
    required bool isCompleted,
    bool isLast = false,
  }) {
    Color primaryColor = const Color(0xFF005C45);
    Color secondaryColor = const Color(0xFFFCD703);
    
    Color circleColor;
    Color iconColor;
    
    if (isCompleted) {
      circleColor = secondaryColor;
      iconColor = Colors.black;
    } else if (isActive) {
      circleColor = secondaryColor;
      iconColor = Colors.black;
    } else {
      circleColor = Colors.grey.shade200;
      iconColor = Colors.grey.shade400;
    }

    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: circleColor,
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
            color: isActive ? Colors.black87 : Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  Widget _buildConnector({required bool isActive}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 24),
        color: isActive ? const Color(0xFFFCD703) : Colors.grey.shade200,
      ),
    );
  }
}

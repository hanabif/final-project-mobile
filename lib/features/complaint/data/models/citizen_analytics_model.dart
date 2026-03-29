class CitizenAnalyticsModel {
  final int total;
  final int resolved;
  final int pending;
  final double resolvedPercentage;

  CitizenAnalyticsModel({
    required this.total,
    required this.resolved,
    required this.pending,
    required this.resolvedPercentage,
  });

  factory CitizenAnalyticsModel.fromJson(Map<String, dynamic> json) {
    return CitizenAnalyticsModel(
      total: (json['total'] ?? 0) as int,
      resolved: (json['resolved'] ?? 0) as int,
      pending: (json['pending'] ?? 0) as int,
      resolvedPercentage: (json['resolvedPercentage'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'resolved': resolved,
      'pending': pending,
      'resolvedPercentage': resolvedPercentage,
    };
  }
}

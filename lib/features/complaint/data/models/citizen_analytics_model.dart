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
      total: (json['total'] as num?)?.toInt() ?? 0,
      resolved: (json['resolved'] as num?)?.toInt() ?? 0,
      pending: (json['pending'] as num?)?.toInt() ?? 0,
      resolvedPercentage: (json['resolvedPercentage'] as num?)?.toDouble() ?? 0.0,
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

class SavingGoal {
  final double targetAmount; // Mục tiêu ban đầu (ví dụ: 1.000.000 đ)
  final String title;
  final DateTime createdAt;

  SavingGoal({
    required this.targetAmount,
    this.title = 'Mục tiêu tiết kiệm',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  SavingGoal copyWith({
    double? targetAmount,
    String? title,
    DateTime? createdAt,
  }) {
    return SavingGoal(
      targetAmount: targetAmount ?? this.targetAmount,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'targetAmount': targetAmount,
      'title': title,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory SavingGoal.fromJson(Map<String, dynamic> json) {
    return SavingGoal(
      targetAmount: (json['targetAmount'] as num?)?.toDouble() ?? 1000000.0,
      title: json['title'] as String? ?? 'Mục tiêu tiết kiệm',
      createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}

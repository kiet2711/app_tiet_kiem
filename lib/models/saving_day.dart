class SavingDay {
  final String id;
  final DateTime date;
  final double actualAmount; // Ô đã tiết kiệm được
  final double projectedAmount; // Ô có thể sẽ tiết kiệm được
  final String note;

  SavingDay({
    required this.id,
    required this.date,
    required this.actualAmount,
    required this.projectedAmount,
    this.note = '',
  });

  // Tổng số tiền của ngày đó (nếu tính cả dự kiến)
  double get totalDayPotential => actualAmount + projectedAmount;

  // Chuyển nhanh tiền dự kiến sang tiền đã tiết kiệm
  SavingDay convertProjectedToActual() {
    return copyWith(
      actualAmount: actualAmount + projectedAmount,
      projectedAmount: 0.0,
    );
  }

  SavingDay copyWith({
    String? id,
    DateTime? date,
    double? actualAmount,
    double? projectedAmount,
    String? note,
  }) {
    return SavingDay(
      id: id ?? this.id,
      date: date ?? this.date,
      actualAmount: actualAmount ?? this.actualAmount,
      projectedAmount: projectedAmount ?? this.projectedAmount,
      note: note ?? this.note,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'actualAmount': actualAmount,
      'projectedAmount': projectedAmount,
      'note': note,
    };
  }

  factory SavingDay.fromJson(Map<String, dynamic> json) {
    return SavingDay(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      date: DateTime.tryParse(json['date'] as String? ?? '') ?? DateTime.now(),
      actualAmount: (json['actualAmount'] as num?)?.toDouble() ?? 0.0,
      projectedAmount: (json['projectedAmount'] as num?)?.toDouble() ?? 0.0,
      note: json['note'] as String? ?? '',
    );
  }
}

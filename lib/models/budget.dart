class Budget {
  final String id;
  final String categoryId;
  final double monthlyLimit;
  final int month; // 1 - 12
  final int year;

  const Budget({
    required this.id,
    required this.categoryId,
    required this.monthlyLimit,
    required this.month,
    required this.year,
  });

  Budget copyWith({
    String? id,
    String? categoryId,
    double? monthlyLimit,
    int? month,
    int? year,
  }) {
    return Budget(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      month: month ?? this.month,
      year: year ?? this.year,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'categoryId': categoryId,
    'monthlyLimit': monthlyLimit,
    'month': month,
    'year': year,
  };

  factory Budget.fromJson(Map<String, dynamic> json) => Budget(
    id: json['id'] as String,
    categoryId: json['categoryId'] as String,
    monthlyLimit: (json['monthlyLimit'] as num).toDouble(),
    month: json['month'] as int,
    year: json['year'] as int,
  );
}

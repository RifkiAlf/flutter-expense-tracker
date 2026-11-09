import 'package:flutter/material.dart';
import '../utils/app_icons.dart';

class FinancialGoal {
  final String id;
  final String title;
  final double targetAmount;
  final double currentAmount;
  final DateTime targetDate;
  final int iconCodePoint;
  final int colorValue;
  final String? notes;

  const FinancialGoal({
    required this.id,
    required this.title,
    required this.targetAmount,
    required this.currentAmount,
    required this.targetDate,
    required this.iconCodePoint,
    required this.colorValue,
    this.notes,
  });

  IconData get icon => AppIcons.getIcon(iconCodePoint);
  Color get color => Color(colorValue);

  double get progress => targetAmount > 0 ? (currentAmount / targetAmount).clamp(0.0, 1.0) : 0.0;
  double get remainingAmount => (targetAmount - currentAmount).clamp(0.0, double.infinity);
  bool get isAchieved => currentAmount >= targetAmount;

  FinancialGoal copyWith({
    String? id,
    String? title,
    double? targetAmount,
    double? currentAmount,
    DateTime? targetDate,
    int? iconCodePoint,
    int? colorValue,
    String? notes,
  }) {
    return FinancialGoal(
      id: id ?? this.id,
      title: title ?? this.title,
      targetAmount: targetAmount ?? this.targetAmount,
      currentAmount: currentAmount ?? this.currentAmount,
      targetDate: targetDate ?? this.targetDate,
      iconCodePoint: iconCodePoint ?? this.iconCodePoint,
      colorValue: colorValue ?? this.colorValue,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'targetAmount': targetAmount,
    'currentAmount': currentAmount,
    'targetDate': targetDate.toIso8601String(),
    'iconCodePoint': iconCodePoint,
    'colorValue': colorValue,
    'notes': notes,
  };

  factory FinancialGoal.fromJson(Map<String, dynamic> json) => FinancialGoal(
    id: json['id'] as String,
    title: json['title'] as String,
    targetAmount: (json['targetAmount'] as num).toDouble(),
    currentAmount: (json['currentAmount'] as num).toDouble(),
    targetDate: DateTime.parse(json['targetDate'] as String),
    iconCodePoint: json['iconCodePoint'] as int,
    colorValue: json['colorValue'] as int,
    notes: json['notes'] as String?,
  );

  static List<FinancialGoal> get defaultGoals => [];
}

import 'package:flutter/material.dart';
import '../utils/app_icons.dart';

enum CategoryType { expense, income }

class ExpenseCategory {
  final String id;
  final String name;
  final int iconCodePoint;
  final int colorValue;
  final CategoryType type;

  const ExpenseCategory({
    required this.id,
    required this.name,
    required this.iconCodePoint,
    required this.colorValue,
    required this.type,
  });

  IconData get icon => AppIcons.getIcon(iconCodePoint);
  Color get color => Color(colorValue);

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'iconCodePoint': iconCodePoint,
    'colorValue': colorValue,
    'type': type.name,
  };

  factory ExpenseCategory.fromJson(Map<String, dynamic> json) => ExpenseCategory(
    id: json['id'] as String,
    name: json['name'] as String,
    iconCodePoint: json['iconCodePoint'] as int,
    colorValue: json['colorValue'] as int,
    type: CategoryType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => CategoryType.expense,
    ),
  );

  static List<ExpenseCategory> get defaultCategories => [
    // Pengeluaran
    ExpenseCategory(
      id: 'cat_food',
      name: 'Makanan & Minuman',
      iconCodePoint: Icons.restaurant.codePoint,
      colorValue: 0xFFFF5722, // Deep Orange
      type: CategoryType.expense,
    ),
    ExpenseCategory(
      id: 'cat_transport',
      name: 'Transportasi',
      iconCodePoint: Icons.directions_car.codePoint,
      colorValue: 0xFF2196F3, // Blue
      type: CategoryType.expense,
    ),
    ExpenseCategory(
      id: 'cat_groceries',
      name: 'Belanja Kebutuhan',
      iconCodePoint: Icons.shopping_cart.codePoint,
      colorValue: 0xFF9C27B0, // Purple
      type: CategoryType.expense,
    ),
    ExpenseCategory(
      id: 'cat_bills',
      name: 'Tagihan & Utilitas',
      iconCodePoint: Icons.receipt_long.codePoint,
      colorValue: 0xFFFF9800, // Amber/Orange
      type: CategoryType.expense,
    ),
    ExpenseCategory(
      id: 'cat_entertainment',
      name: 'Hiburan & Hobi',
      iconCodePoint: Icons.sports_esports.codePoint,
      colorValue: 0xFFE91E63, // Pink
      type: CategoryType.expense,
    ),
    ExpenseCategory(
      id: 'cat_health',
      name: 'Kesehatan & Obat',
      iconCodePoint: Icons.local_hospital.codePoint,
      colorValue: 0xFF009688, // Teal
      type: CategoryType.expense,
    ),
    ExpenseCategory(
      id: 'cat_education',
      name: 'Pendidikan',
      iconCodePoint: Icons.school.codePoint,
      colorValue: 0xFF3F51B5, // Indigo
      type: CategoryType.expense,
    ),
    ExpenseCategory(
      id: 'cat_donation',
      name: 'Zakat & Donasi',
      iconCodePoint: Icons.volunteer_activism.codePoint,
      colorValue: 0xFF4CAF50, // Green
      type: CategoryType.expense,
    ),
    ExpenseCategory(
      id: 'cat_other_exp',
      name: 'Pengeluaran Lain',
      iconCodePoint: Icons.category.codePoint,
      colorValue: 0xFF607D8B, // Blue Grey
      type: CategoryType.expense,
    ),

    // Pemasukan
    ExpenseCategory(
      id: 'cat_salary',
      name: 'Gaji Bulanan',
      iconCodePoint: Icons.payments.codePoint,
      colorValue: 0xFF2E7D32, // Dark Green
      type: CategoryType.income,
    ),
    ExpenseCategory(
      id: 'cat_bonus',
      name: 'Bonus & THR',
      iconCodePoint: Icons.card_giftcard.codePoint,
      colorValue: 0xFF00B0FF, // Light Blue
      type: CategoryType.income,
    ),
    ExpenseCategory(
      id: 'cat_business',
      name: 'Bisnis & Penjualan',
      iconCodePoint: Icons.storefront.codePoint,
      colorValue: 0xFFFF6D00, // Deep Orange
      type: CategoryType.income,
    ),
    ExpenseCategory(
      id: 'cat_investment',
      name: 'Investasi & Dividen',
      iconCodePoint: Icons.trending_up.codePoint,
      colorValue: 0xFF6200EA, // Deep Purple
      type: CategoryType.income,
    ),
    ExpenseCategory(
      id: 'cat_other_inc',
      name: 'Pemasukan Lain',
      iconCodePoint: Icons.account_balance_wallet.codePoint,
      colorValue: 0xFF00897B, // Teal
      type: CategoryType.income,
    ),
  ];
}

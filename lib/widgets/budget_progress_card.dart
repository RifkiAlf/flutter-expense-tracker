import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/app_colors.dart';
import 'category_icon_widget.dart';
import 'animated_pressable.dart';
import 'smooth_entrance.dart';

class BudgetProgressCard extends StatelessWidget {
  final Budget budget;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const BudgetProgressCard({
    super.key,
    required this.budget,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final category = provider.getCategoryById(budget.categoryId);
    final spent = provider.getSpentForCategory(
      budget.categoryId,
      month: budget.month,
      year: budget.year,
    );

    final double percentage = budget.monthlyLimit > 0
        ? (spent / budget.monthlyLimit).clamp(0.0, 1.5)
        : 0.0;
    final double displayPercentage = budget.monthlyLimit > 0
        ? (spent / budget.monthlyLimit) * 100
        : 0.0;

    final double remaining = budget.monthlyLimit - spent;
    final bool isOverBudget = remaining < 0;

    Color progressColor = AppColors.income;
    if (percentage >= 1.0) {
      progressColor = AppColors.coral;
    } else if (percentage >= 0.8) {
      progressColor = AppColors.warning;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SmoothEntrance(
      duration: const Duration(milliseconds: 280),
      child: AnimatedPressable(
        scaleDown: 0.98,
        onTap: onEdit,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isDark ? AppColors.cardDarkGlass : Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isDark
                  ? AppColors.borderDarkGlass.withValues(alpha: 0.38)
                  : AppColors.borderLight,
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: isDark ? const Color(0x35000000) : const Color(0x0C192C50),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                  children: [
                    if (category != null)
                      CategoryIconWidget(
                        icon: category.icon,
                        color: category.color,
                        size: 40,
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category?.name ?? 'Kategori',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                          Text(
                            'Batas: ${CurrencyFormatter.format(budget.monthlyLimit)}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: const Icon(Icons.more_vert, size: 20),
                      onSelected: (value) {
                        if (value == 'edit' && onEdit != null) onEdit!();
                        if (value == 'delete' && onDelete != null) onDelete!();
                      },
                      itemBuilder: (ctx) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18),
                              SizedBox(width: 8),
                              Text('Ubah Batas'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 18),
                              SizedBox(width: 8),
                              Text('Hapus Anggaran', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: percentage.clamp(0.0, 1.0)),
                    duration: const Duration(milliseconds: 550),
                    curve: Curves.easeOutCubic,
                    builder: (context, animValue, _) {
                      return LinearProgressIndicator(
                        value: animValue,
                        minHeight: 8,
                        backgroundColor: Colors.grey.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Terpakai: ${CurrencyFormatter.format(spent)} (${displayPercentage.toStringAsFixed(0)}%)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: isOverBudget ? Colors.red : Colors.grey.shade700,
                      ),
                    ),
                    Text(
                      isOverBudget
                          ? 'Lebih ${CurrencyFormatter.format(remaining.abs())}'
                          : 'Sisa ${CurrencyFormatter.format(remaining)}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isOverBudget ? Colors.red : const Color(0xFF10B981),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
  }
}

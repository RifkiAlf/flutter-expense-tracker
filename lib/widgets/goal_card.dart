import 'package:flutter/material.dart';
import '../models/goal.dart';
import '../utils/currency_formatter.dart';
import '../utils/app_date_utils.dart';
import '../utils/app_colors.dart';
import 'category_icon_widget.dart';
import 'animated_pressable.dart';
import 'smooth_entrance.dart';

class GoalCard extends StatelessWidget {
  final FinancialGoal goal;
  final VoidCallback onContribute;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const GoalCard({
    super.key,
    required this.goal,
    required this.onContribute,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final double percentage = (goal.progress * 100).clamp(0, 100);
    final int daysLeft = goal.targetDate.difference(DateTime.now()).inDays;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SmoothEntrance(
      duration: const Duration(milliseconds: 280),
      child: AnimatedPressable(
        scaleDown: 0.985,
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
                    CategoryIconWidget(
                      icon: goal.icon,
                      color: goal.color,
                      size: 42,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 15.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            daysLeft > 0
                                ? 'Target: ${AppDateUtils.formatShortDate(goal.targetDate)} ($daysLeft hari lagi)'
                                : goal.isAchieved
                                    ? '🎉 Target Tercapai!'
                                    : 'Target: ${AppDateUtils.formatShortDate(goal.targetDate)}',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: goal.isAchieved
                                  ? const Color(0xFF10B981)
                                  : Colors.grey.shade600,
                              fontWeight: goal.isAchieved
                                  ? FontWeight.w600
                                  : FontWeight.normal,
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
                              Text('Edit Target'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 18),
                              SizedBox(width: 8),
                              Text('Hapus Target', style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        CurrencyFormatter.format(goal.currentAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.5,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        'Target: ${CurrencyFormatter.format(goal.targetAmount)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: goal.progress),
                    duration: const Duration(milliseconds: 550),
                    curve: Curves.easeOutCubic,
                    builder: (context, animProgress, _) {
                      return LinearProgressIndicator(
                        value: animProgress,
                        minHeight: 8,
                        backgroundColor: Colors.grey.withValues(alpha: 0.15),
                        valueColor: AlwaysStoppedAnimation<Color>(goal.color),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        '${percentage.toStringAsFixed(1)}% terkumpul',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: goal.color,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedPressable(
                      scaleDown: 0.92,
                      onTap: onContribute,
                      child: ElevatedButton.icon(
                        onPressed: onContribute,
                        icon: const Icon(Icons.add, size: 15),
                        label: const Text('Nabung'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                          backgroundColor: goal.color,
                        ),
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

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/app_colors.dart';
import 'animated_pressable.dart';
import 'smooth_entrance.dart';

/// Dua kartu metrik berbentuk "Pill / Squircle Capsule"
/// Sesuai dengan desain pill ganda pada mockup gambar di bawah kartu gunung
class StatPillCards extends StatelessWidget {
  final VoidCallback? onIncomeTap;
  final VoidCallback? onExpenseTap;

  const StatPillCards({
    super.key,
    this.onIncomeTap,
    this.onExpenseTap,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final isHidden = provider.hideBalance;
    final income = provider.getCurrentMonthIncome();
    final expense = provider.getCurrentMonthExpense();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Hitung rasio pengeluaran terhadap total arus masuk
    final totalFlow = income + expense;
    final expenseRatio = totalFlow > 0 ? (expense / totalFlow * 100).toStringAsFixed(0) : '0';
    final incomeRatio = totalFlow > 0 ? (income / totalFlow * 100).toStringAsFixed(0) : '0';

    return SmoothEntrance(
      delay: const Duration(milliseconds: 60),
      duration: const Duration(milliseconds: 320),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Row(
          children: [
            // Pill Kartu 1: Pemasukan
            Expanded(
              child: AnimatedPressable(
                scaleDown: 0.96,
                onTap: onIncomeTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cardDarkGlass.withValues(alpha: 0.85)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDarkGlass.withValues(alpha: 0.45)
                          : AppColors.borderLight,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? const Color(0x40000000)
                            : const Color(0x0E1A2C52),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pemasukan',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.income.withValues(alpha: isDark ? 0.25 : 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_upward_rounded,
                              size: 14,
                              color: AppColors.income,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                          return Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              ...previousChildren,
                              ?currentChild,
                            ],
                          );
                        },
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
                          return FadeTransition(
                            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
                              alignment: Alignment.centerLeft,
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          isHidden ? '••••••' : CurrencyFormatter.formatCompact(income),
                          key: ValueKey<String>('${isHidden}_$income'),
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.income.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$incomeRatio% alur',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.income,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Pill Kartu 2: Pengeluaran
            Expanded(
              child: AnimatedPressable(
                scaleDown: 0.96,
                onTap: onExpenseTap,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cardDarkGlass.withValues(alpha: 0.85)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDarkGlass.withValues(alpha: 0.45)
                          : AppColors.borderLight,
                      width: 1.2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isDark
                            ? const Color(0x40000000)
                            : const Color(0x0E1A2C52),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pengeluaran',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: AppColors.coral.withValues(alpha: isDark ? 0.25 : 0.12),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.arrow_downward_rounded,
                              size: 14,
                              color: AppColors.coral,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
                          return Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              ...previousChildren,
                              ?currentChild,
                            ],
                          );
                        },
                        transitionBuilder: (Widget child, Animation<double> animation) {
                          final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
                          return FadeTransition(
                            opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                            child: ScaleTransition(
                              scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
                              alignment: Alignment.centerLeft,
                              child: child,
                            ),
                          );
                        },
                        child: Text(
                          isHidden ? '••••••' : CurrencyFormatter.formatCompact(expense),
                          key: ValueKey<String>('${isHidden}_$expense'),
                          style: TextStyle(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.coral.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '$expenseRatio% alur',
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: AppColors.coral,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

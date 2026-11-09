import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/app_date_utils.dart';
import '../utils/app_colors.dart';
import 'category_icon_widget.dart';
import 'animated_pressable.dart';

class TransactionTile extends StatelessWidget {
  final FinancialTransaction transaction;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const TransactionTile({
    super.key,
    required this.transaction,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ExpenseProvider>();
    final isExpense = transaction.type == TransactionType.expense;
    final isIncome = transaction.type == TransactionType.income;
    final isTransfer = transaction.type == TransactionType.transfer;

    final category = isTransfer
        ? null
        : provider.getCategoryById(transaction.categoryId);
    final wallet = provider.getWalletById(transaction.walletId);
    final toWallet = isTransfer && transaction.toWalletId != null
        ? provider.getWalletById(transaction.toWalletId!)
        : null;

    final Color amountColor = isIncome
        ? AppColors.income
        : isExpense
            ? AppColors.expense
            : AppColors.steelBlue;

    final String prefix = isIncome
        ? '+'
        : isExpense
            ? '-'
            : '⇄';

    IconData displayIcon = Icons.swap_horiz;
    Color displayColor = AppColors.steelBlue;

    if (!isTransfer && category != null) {
      displayIcon = category.icon;
      displayColor = category.color;
    }

    String displayTitle = transaction.title;
    if (isTransfer) {
      if (transaction.notes != null && transaction.notes!.trim().isNotEmpty) {
        displayTitle = transaction.notes!;
      } else if (transaction.title.startsWith('Transfer:')) {
        displayTitle = 'Transfer Dana';
      }
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedPressable(
      scaleDown: 0.98,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isDark
              ? AppColors.cardDarkGlass.withValues(alpha: 0.85)
              : Colors.white.withValues(alpha: 0.90),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? AppColors.borderDarkGlass.withValues(alpha: 0.38)
                : Colors.white.withValues(alpha: 0.85),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0x35000000)
                  : const Color(0x0B192C50),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            CategoryIconWidget(
              icon: displayIcon,
              color: displayColor,
              size: 46,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayTitle,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      color: isDark ? Colors.white : AppColors.textPrimaryLight,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2.5),
                          decoration: BoxDecoration(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.1)
                                : AppColors.deepNavy.withValues(alpha: 0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isTransfer
                                ? '${wallet?.name ?? 'Dompet'} ➔ ${toWallet?.name ?? 'Tujuan'}'
                                : wallet?.name ?? 'Dompet',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        AppDateUtils.getRelativeDate(transaction.date),
                        style: TextStyle(
                          fontSize: 11,
                          color: isDark ? Colors.white54 : Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 130),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$prefix ${CurrencyFormatter.format(transaction.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 14.5,
                      color: amountColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (transaction.notes != null &&
                      transaction.notes!.trim().isNotEmpty &&
                      !isTransfer) ...[
                    const SizedBox(height: 3),
                    Text(
                      transaction.notes!,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : Colors.grey.shade500,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

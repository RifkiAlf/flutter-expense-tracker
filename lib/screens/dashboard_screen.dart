import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/expense_provider.dart';
import '../utils/app_colors.dart';
import '../widgets/mountain_hero_card.dart';
import '../widgets/transaction_tile.dart';
import '../widgets/animated_pressable.dart';
import '../widgets/smooth_entrance.dart';
import 'add_edit_transaction_screen.dart';
import 'transfer_screen.dart';
import 'goals_screen.dart';

class DashboardScreen extends StatelessWidget {
  final Function(int) onNavigateTab;

  const DashboardScreen({super.key, required this.onNavigateTab});

  Widget _buildQuickActionItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? AppColors.cardDarkGlass.withValues(alpha: 0.85)
        : Colors.white.withValues(alpha: 0.90);
    final borderCol = isDark
        ? AppColors.borderDarkGlass.withValues(alpha: 0.35)
        : Colors.white.withValues(alpha: 0.85);

    return Expanded(
      child: AnimatedPressable(
        scaleDown: 0.94,
        onTap: onTap,
        child: Container(
          height: 82,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          decoration: BoxDecoration(
            color: cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: borderCol, width: 1.2),
            boxShadow: [
              BoxShadow(
                color: isDark ? const Color(0x35000000) : const Color(0x0C182A4D),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(height: 6),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final recentTransactions = provider.getRecentTransactions(limit: 5);

    // Cek apakah ada budget yang over atau mendekati limit (>= 80%)
    final now = DateTime.now();
    final alertBudgets = provider.budgets.where((b) {
      if (b.month != now.month || b.year != now.year) return false;
      final spent = provider.getSpentForCategory(b.categoryId, month: b.month, year: b.year);
      return b.monthlyLimit > 0 && (spent / b.monthlyLimit) >= 0.8;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text(
          'Smart Money',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.only(bottom: 170),
          children: [
            // 1. Hero Card Pemandangan Gunung dengan Trajectory Finansial
            const MountainHeroCard(),

            const SizedBox(height: 8),

            // 2. Aksi Cepat
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                  children: [
                    _buildQuickActionItem(
                      context: context,
                      icon: Icons.remove_circle_outline,
                      label: 'Pengeluaran',
                      color: AppColors.coral,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => const AddEditTransactionScreen(
                              initialType: TransactionType.expense,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionItem(
                      context: context,
                      icon: Icons.add_circle_outline,
                      label: 'Pemasukan',
                      color: AppColors.income,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => const AddEditTransactionScreen(
                              initialType: TransactionType.income,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionItem(
                      context: context,
                      icon: Icons.swap_horiz_rounded,
                      label: 'Transfer',
                      color: AppColors.steelBlue,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => const TransferScreen(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    _buildQuickActionItem(
                      context: context,
                      icon: Icons.flag_outlined,
                      label: 'Target',
                      color: const Color(0xFFF59E0B),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (ctx) => const GoalsScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 14),

            // Peringatan Anggaran jika ada
            if (alertBudgets.isNotEmpty) ...[
              SmoothEntrance(
                delay: const Duration(milliseconds: 100),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.coral.withValues(alpha: 0.16)
                          : const Color(0xFFFEF2F2),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.coral.withValues(alpha: 0.45)
                            : const Color(0xFFFCA5A5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.coral
                              : const Color(0xFFDC2626),
                          size: 20,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${alertBudgets.length} kategori mendekati/melebihi batas anggaran.',
                            style: TextStyle(
                              color: Theme.of(context).brightness == Brightness.dark
                                  ? Colors.white.withValues(alpha: 0.92)
                                  : const Color(0xFF991B1B),
                              fontSize: 12,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () => onNavigateTab(3),
                          child: const Text('Lihat', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Transaksi Terkini Header
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Transaksi Terkini',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                  if (recentTransactions.isNotEmpty)
                    TextButton(
                      onPressed: () => onNavigateTab(1),
                      child: const Text('Lihat Semua'),
                    ),
                ],
              ),
            ),

            // List Transaksi Terkini atau Empty State
            if (recentTransactions.isEmpty)
              SmoothEntrance(
                delay: const Duration(milliseconds: 120),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.borderDark
                            : AppColors.borderLight,
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.edit_note_rounded, size: 48, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'Belum ada transaksi dicatat',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Mulai catat pengeluaran atau pemasukan pertama Anda',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12.5, color: Colors.grey.shade500),
                        ),
                        const SizedBox(height: 18),
                        AnimatedPressable(
                          scaleDown: 0.95,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (ctx) => const AddEditTransactionScreen(),
                              ),
                            );
                          },
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.add, size: 18),
                            label: const Text('Catat Transaksi Pertama'),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (ctx) => const AddEditTransactionScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ...recentTransactions.map((tx) {
                return TransactionTile(
                  transaction: tx,
                  onTap: () {
                    if (tx.type != TransactionType.transfer) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (ctx) => AddEditTransactionScreen(
                            transactionToEdit: tx,
                          ),
                        ),
                      );
                    }
                  },
                );
              }),
          ],
        ),
      ),
    );
  }
}

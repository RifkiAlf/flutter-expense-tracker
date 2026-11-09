import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/budget.dart';
import '../models/category.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/app_date_utils.dart';
import '../utils/app_colors.dart';
import '../widgets/budget_progress_card.dart';

class BudgetsScreen extends StatefulWidget {
  const BudgetsScreen({super.key});

  @override
  State<BudgetsScreen> createState() => _BudgetsScreenState();
}

class _BudgetsScreenState extends State<BudgetsScreen> {
  DateTime _currentDate = DateTime.now();

  void _showAddEditBudgetDialog([Budget? budgetToEdit]) {
    final provider = context.read<ExpenseProvider>();
    final expenseCategories = provider.categories
        .where((c) => c.type == CategoryType.expense)
        .toList();

    String selectedCategoryId = budgetToEdit?.categoryId ??
        (expenseCategories.isNotEmpty ? expenseCategories.first.id : '');
    final limitController = TextEditingController(
      text: budgetToEdit != null ? budgetToEdit.monthlyLimit.toInt().toString() : '',
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        budgetToEdit != null ? 'Ubah Anggaran' : 'Buat Anggaran Baru',
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text('Pilih Kategori', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  DropdownButtonFormField<String>(
                    isExpanded: true,
                    initialValue: selectedCategoryId,
                    items: expenseCategories.map((c) {
                      return DropdownMenuItem<String>(
                        value: c.id,
                        child: Row(
                          children: [
                            Icon(c.icon, color: c.color, size: 20),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                c.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: budgetToEdit != null
                        ? null // Kategori dikunci saat edit
                        : (val) {
                            if (val != null) {
                              setModalState(() => selectedCategoryId = val);
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                  const Text('Batas Anggaran Bulanan', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: limitController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      prefixText: 'Rp ',
                      hintText: '1.000.000',
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        final limit = CurrencyFormatter.parse(limitController.text);
                        if (limit <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Batas anggaran harus lebih dari 0')),
                          );
                          return;
                        }
                        provider.setBudget(
                          categoryId: selectedCategoryId,
                          monthlyLimit: limit,
                          month: _currentDate.month,
                          year: _currentDate.year,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Anggaran berhasil disimpan')),
                        );
                      },
                      child: const Text('Simpan Anggaran'),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final monthBudgets = provider.budgets.where(
      (b) => b.month == _currentDate.month && b.year == _currentDate.year,
    ).toList();

    double totalLimit = 0;
    double totalSpent = 0;
    for (final b in monthBudgets) {
      totalLimit += b.monthlyLimit;
      totalSpent += provider.getSpentForCategory(b.categoryId, month: b.month, year: b.year);
    }
    final overallPercentage = totalLimit > 0 ? (totalSpent / totalLimit).clamp(0.0, 1.0) : 0.0;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Anggaran & Pengeluaran'),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.only(bottom: 170),
        children: [
          // Selector Bulan
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () {
                    setState(() {
                      _currentDate = DateTime(_currentDate.year, _currentDate.month - 1);
                    });
                  },
                ),
                Text(
                  'Periode: ${AppDateUtils.formatMonthYear(_currentDate)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    setState(() {
                      _currentDate = DateTime(_currentDate.year, _currentDate.month + 1);
                    });
                  },
                ),
              ],
            ),
          ),

          // Total Overview Card
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.borderDarkGlass.withValues(alpha: 0.4)
                    : const Color(0xFF1B3D6B),
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.abyss.withValues(alpha: 0.28),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.pie_chart, color: AppColors.iceBlue, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Ringkasan Anggaran Keseluruhan',
                      style: TextStyle(
                        color: AppColors.iceBlue.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Terpakai',
                          style: TextStyle(color: AppColors.softBlue.withValues(alpha: 0.9), fontSize: 12),
                        ),
                        Text(
                          CurrencyFormatter.format(totalSpent),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          'Batas Anggaran',
                          style: TextStyle(color: AppColors.softBlue.withValues(alpha: 0.9), fontSize: 12),
                        ),
                        Text(
                          CurrencyFormatter.format(totalLimit),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
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
                    tween: Tween<double>(begin: 0.0, end: overallPercentage),
                    duration: const Duration(milliseconds: 550),
                    curve: Curves.easeOutCubic,
                    builder: (context, animVal, _) {
                      return LinearProgressIndicator(
                        value: animVal,
                        minHeight: 8,
                        backgroundColor: AppColors.steelBlue.withValues(alpha: 0.3),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppColors.iceBlue),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${(overallPercentage * 100).toStringAsFixed(1)}% anggaran telah digunakan',
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Header Kategori Anggaran
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Daftar Anggaran Kategori',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                TextButton.icon(
                  onPressed: () => _showAddEditBudgetDialog(),
                  icon: const Icon(Icons.add, size: 16),
                  label: const Text('Tambah'),
                ),
              ],
            ),
          ),

          // List item anggaran
          if (monthBudgets.isEmpty) ...[
            const SizedBox(height: 30),
            Center(
              child: Column(
                children: [
                  Icon(Icons.savings_outlined, size: 60, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada anggaran untuk bulan ini',
                    style: TextStyle(fontSize: 15, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => _showAddEditBudgetDialog(),
                    child: const Text('Buat Anggaran Sekarang'),
                  ),
                ],
              ),
            ),
          ] else ...[
            ...monthBudgets.map((b) {
              return BudgetProgressCard(
                budget: b,
                onEdit: () => _showAddEditBudgetDialog(b),
                onDelete: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Hapus Anggaran?'),
                      content: const Text('Apakah Anda yakin ingin menghapus anggaran kategori ini?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Hapus'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    provider.deleteBudget(b.id);
                  }
                },
              );
            }),
          ],
        ],
      ),
    );
  }
}

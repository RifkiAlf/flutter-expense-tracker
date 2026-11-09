import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../providers/expense_provider.dart';
import '../utils/app_colors.dart';
import '../utils/app_date_utils.dart';
import '../widgets/transaction_tile.dart';
import 'add_edit_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  String _searchQuery = '';
  TransactionType? _selectedTypeFilter;
  String? _selectedWalletFilter;
  String? _selectedCategoryFilter;
  DateTime _selectedDate = DateTime.now();
  bool _isAllMonths = false;

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1);
      _isAllMonths = false;
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1);
      _isAllMonths = false;
    });
  }

  void _showMonthPickerSheet(BuildContext context) {
    int tempYear = _selectedDate.year;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            final now = DateTime.now();

            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withValues(alpha: 0.4),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: 14),

                    // Header with Year Selector
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Pilih Periode',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.chevron_left_rounded),
                              onPressed: () {
                                setModalState(() => tempYear--);
                              },
                            ),
                            Text(
                              '$tempYear',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            IconButton(
                              icon: const Icon(Icons.chevron_right_rounded),
                              onPressed: () {
                                setModalState(() => tempYear++);
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Grid Bulan (12 Bulan)
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        mainAxisSpacing: 8,
                        crossAxisSpacing: 8,
                        childAspectRatio: 2.1,
                      ),
                      itemCount: 12,
                      itemBuilder: (ctx, idx) {
                        final monthNum = idx + 1;
                        final isSelected = !_isAllMonths &&
                            _selectedDate.year == tempYear &&
                            _selectedDate.month == monthNum;
                        final isCurrentMonth = now.year == tempYear && now.month == monthNum;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              _selectedDate = DateTime(tempYear, monthNum);
                              _isAllMonths = false;
                            });
                            Navigator.pop(ctx);
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppColors.coral
                                  : (isCurrentMonth
                                      ? AppColors.coral.withValues(alpha: 0.15)
                                      : (isDark
                                          ? AppColors.cardDarkGlass
                                          : Colors.grey.shade100)),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? AppColors.coral
                                    : (isCurrentMonth
                                        ? AppColors.coral.withValues(alpha: 0.5)
                                        : Colors.transparent),
                                width: 1.2,
                              ),
                            ),
                            child: Text(
                              AppDateUtils.monthNames[idx],
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white : AppColors.textPrimaryLight),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Action buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedDate = DateTime.now();
                                _isAllMonths = false;
                              });
                              Navigator.pop(ctx);
                            },
                            child: const Text('Bulan Ini'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _isAllMonths ? AppColors.coral : null,
                            ),
                            onPressed: () {
                              setState(() {
                                _isAllMonths = true;
                              });
                              Navigator.pop(ctx);
                            },
                            child: const Text('Semua Periode'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<ExpenseProvider>();
    final allTransactions = provider.transactions;

    // Filter logic
    final filteredList = allTransactions.where((t) {
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        final matchTitle = t.title.toLowerCase().contains(q);
        final matchNote = t.notes?.toLowerCase().contains(q) ?? false;
        if (!matchTitle && !matchNote) return false;
      }

      if (!_isAllMonths) {
        if (t.date.month != _selectedDate.month || t.date.year != _selectedDate.year) {
          return false;
        }
      }

      if (_selectedTypeFilter != null && t.type != _selectedTypeFilter) {
        return false;
      }

      if (_selectedWalletFilter != null &&
          t.walletId != _selectedWalletFilter &&
          t.toWalletId != _selectedWalletFilter) {
        return false;
      }

      if (_selectedCategoryFilter != null &&
          t.categoryId != _selectedCategoryFilter) {
        return false;
      }

      return true;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Riwayat Transaksi'),
      ),
      body: Column(
        children: [
          // Search Box
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Cari transaksi atau catatan...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () => setState(() => _searchQuery = ''),
                      )
                    : null,
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              onChanged: (val) => setState(() => _searchQuery = val),
            ),
          ),

          // Selector Bulan & Tahun Ringkas (Pill Style)
          Container(
            margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            height: 50,
            decoration: BoxDecoration(
              color: isDark ? AppColors.cardDarkGlass : Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: isDark ? AppColors.borderDarkGlass : const Color(0xFFE2E8F0),
                width: 1.0,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  iconSize: 24,
                  splashRadius: 22,
                  tooltip: 'Bulan Sebelumnya',
                  onPressed: _previousMonth,
                ),
                Expanded(
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => _showMonthPickerSheet(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Center(
                        child: Text(
                          _isAllMonths
                              ? 'Semua Periode'
                              : AppDateUtils.formatMonthYear(_selectedDate),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.2,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  color: isDark ? Colors.white : const Color(0xFF1E293B),
                  iconSize: 24,
                  splashRadius: 22,
                  tooltip: 'Bulan Berikutnya',
                  onPressed: _nextMonth,
                ),
                const SizedBox(width: 4),
              ],
            ),
          ),

          // 2. Filter Tipe Transaksi (Semua, Pengeluaran, Pemasukan, Transfer)
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Semua'),
                  selected: _selectedTypeFilter == null,
                  selectedColor: AppColors.steelBlue.withValues(alpha: 0.25),
                  checkmarkColor: AppColors.steelBlue,
                  onSelected: (val) => setState(() => _selectedTypeFilter = null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pengeluaran'),
                  selected: _selectedTypeFilter == TransactionType.expense,
                  selectedColor: AppColors.expense.withValues(alpha: 0.25),
                  checkmarkColor: AppColors.expense,
                  onSelected: (val) => setState(() {
                    _selectedTypeFilter = val ? TransactionType.expense : null;
                  }),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Pemasukan'),
                  selected: _selectedTypeFilter == TransactionType.income,
                  selectedColor: AppColors.income.withValues(alpha: 0.25),
                  checkmarkColor: AppColors.income,
                  onSelected: (val) => setState(() {
                    _selectedTypeFilter = val ? TransactionType.income : null;
                  }),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Transfer'),
                  selected: _selectedTypeFilter == TransactionType.transfer,
                  selectedColor: AppColors.steelBlue.withValues(alpha: 0.25),
                  checkmarkColor: AppColors.steelBlue,
                  onSelected: (val) => setState(() {
                    _selectedTypeFilter = val ? TransactionType.transfer : null;
                  }),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),

          // List transaksi
          Expanded(
            child: filteredList.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.receipt_long_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'Tidak ada transaksi yang cocok',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Coba ubah kata kunci atau filter pencarian Anda',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.only(bottom: 170),
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final tx = filteredList[index];
                      return Dismissible(
                          key: Key(tx.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 24),
                            color: Colors.red.shade600,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.delete, color: Colors.white),
                                SizedBox(width: 8),
                                Text(
                                  'Hapus',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          confirmDismiss: (direction) async {
                            return await showDialog<bool>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                title: const Text('Hapus Transaksi?'),
                                content: Text(
                                  'Apakah Anda yakin ingin menghapus "${tx.title}"?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(ctx, false),
                                    child: const Text('Batal'),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.red,
                                    ),
                                    onPressed: () => Navigator.pop(ctx, true),
                                    child: const Text('Hapus'),
                                  ),
                                ],
                              ),
                            );
                          },
                          onDismissed: (_) {
                            provider.deleteTransaction(tx);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Transaksi "${tx.title}" telah dihapus')),
                            );
                          },
                          child: TransactionTile(
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
                          ),
                        );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

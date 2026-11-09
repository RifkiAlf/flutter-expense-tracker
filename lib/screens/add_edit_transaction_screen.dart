import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../models/category.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/app_date_utils.dart';
import '../utils/app_colors.dart';
import '../widgets/category_icon_widget.dart';
import '../widgets/animated_pressable.dart';

class AddEditTransactionScreen extends StatefulWidget {
  final FinancialTransaction? transactionToEdit;
  final TransactionType initialType;

  const AddEditTransactionScreen({
    super.key,
    this.transactionToEdit,
    this.initialType = TransactionType.expense,
  });

  @override
  State<AddEditTransactionScreen> createState() => _AddEditTransactionScreenState();
}

class _AddEditTransactionScreenState extends State<AddEditTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  late TransactionType _selectedType;
  String? _selectedCategoryId;
  String? _selectedWalletId;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    final edit = widget.transactionToEdit;
    if (edit != null) {
      _selectedType = edit.type;
      _titleController.text = edit.title;
      _amountController.text = edit.amount.toInt().toString();
      _selectedCategoryId = edit.categoryId;
      _selectedWalletId = edit.walletId;
      _selectedDate = edit.date;
      _notesController.text = edit.notes ?? '';
    } else {
      _selectedType = widget.initialType;
      _selectedDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _addQuickAmount(double addition) {
    final current = CurrencyFormatter.parse(_amountController.text);
    final newAmount = current + addition;
    setState(() {
      _amountController.text = newAmount.toInt().toString();
    });
  }

  Future<void> _pickDate() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
    );
    if (pickedDate != null) {
      if (!mounted) return;
      final pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_selectedDate),
      );
      setState(() {
        if (pickedTime != null) {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        } else {
          _selectedDate = DateTime(
            pickedDate.year,
            pickedDate.month,
            pickedDate.day,
            _selectedDate.hour,
            _selectedDate.minute,
          );
        }
      });
    }
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<ExpenseProvider>();
    final amount = CurrencyFormatter.parse(_amountController.text);
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih dari 0')),
      );
      return;
    }

    if (_selectedWalletId == null || _selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Silakan pilih dompet dan kategori')),
      );
      return;
    }

    final newTransaction = FinancialTransaction(
      id: widget.transactionToEdit?.id ?? const Uuid().v4(),
      title: _titleController.text.trim(),
      amount: amount,
      type: _selectedType,
      categoryId: _selectedCategoryId!,
      walletId: _selectedWalletId!,
      date: _selectedDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    if (widget.transactionToEdit != null) {
      provider.updateTransaction(widget.transactionToEdit!, newTransaction);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil diperbarui')),
      );
    } else {
      provider.addTransaction(newTransaction);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Transaksi berhasil dicatat')),
      );
    }

    Navigator.pop(context);
  }

  Widget _buildCardContainer({
    required BuildContext context,
    required List<Widget> children,
    EdgeInsetsGeometry? padding,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark ? AppColors.borderDark : AppColors.borderLight,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.25)
                : AppColors.softBlue.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required String title,
    String? subtitle,
    IconData? icon,
    Widget? trailing,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: isDark ? AppColors.softBlue : AppColors.twilightIndigo,
            ),
            const SizedBox(width: 8),
          ],
          Text(
            title,
            style: TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.2,
              color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(width: 6),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
                color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
              ),
            ),
          ],
          if (trailing != null) ...[
            const Spacer(),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _buildTypeTab({
    required TransactionType type,
    required String label,
    required IconData icon,
    required LinearGradient activeGradient,
    required Color activeShadowColor,
    required BuildContext context,
    required List<ExpenseCategory> allCategories,
  }) {
    final isSelected = _selectedType == type;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedPressable(
      scaleDown: 0.97,
      onTap: () {
        if (_selectedType != type) {
          setState(() {
            _selectedType = type;
            final newFiltered = allCategories.where((c) {
              return type == TransactionType.expense
                  ? c.type == CategoryType.expense
                  : c.type == CategoryType.income;
            }).toList();
            if (newFiltered.isNotEmpty && !newFiltered.any((c) => c.id == _selectedCategoryId)) {
              _selectedCategoryId = newFiltered.first.id;
            }
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          gradient: isSelected ? activeGradient : null,
          color: isSelected ? null : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: activeShadowColor.withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 17,
              color: isSelected
                  ? Colors.white
                  : (isDark ? AppColors.textSecondaryDark : Colors.grey.shade600),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : (isDark ? AppColors.textSecondaryDark : Colors.grey.shade600),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAmountChip({
    required String label,
    required double amount,
    required Color typeColor,
    required bool isDark,
  }) {
    return AnimatedPressable(
      scaleDown: 0.93,
      onTap: () => _addQuickAmount(amount),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDarkElevated : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isDark ? AppColors.borderDark : AppColors.borderLight,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
            color: isDark ? AppColors.textSecondaryDark : AppColors.deepNavy,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final isEdit = widget.transactionToEdit != null;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isExpense = _selectedType == TransactionType.expense;
    final typeColor = isExpense ? AppColors.coral : AppColors.income;

    final filteredCategories = provider.categories.where((c) {
      return isExpense
          ? c.type == CategoryType.expense
          : c.type == CategoryType.income;
    }).toList();

    // Pastikan selectedCategoryId valid
    if (_selectedCategoryId == null ||
        !filteredCategories.any((c) => c.id == _selectedCategoryId)) {
      if (filteredCategories.isNotEmpty) {
        _selectedCategoryId = filteredCategories.first.id;
      }
    }

    // Pastikan selectedWalletId valid
    if (_selectedWalletId == null ||
        !provider.wallets.any((w) => w.id == _selectedWalletId)) {
      if (provider.wallets.isNotEmpty) {
        _selectedWalletId = provider.wallets.first.id;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEdit
              ? (isExpense ? 'Ubah Pengeluaran' : 'Ubah Pemasukan')
              : (isExpense ? 'Catat Pengeluaran' : 'Catat Pemasukan'),
          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18.5),
        ),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: typeColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_rounded,
                size: 20,
                color: typeColor,
              ),
            ),
            onPressed: _save,
            tooltip: 'Simpan',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
          children: [
            // 1. Segmented Switcher: Pengeluaran vs Pemasukan
            Container(
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDarkElevated : Colors.grey.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1,
                ),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  Expanded(
                    child: _buildTypeTab(
                      type: TransactionType.expense,
                      label: 'Pengeluaran',
                      icon: Icons.arrow_downward_rounded,
                      activeGradient: AppColors.coralPillGradient,
                      activeShadowColor: AppColors.coral,
                      context: context,
                      allCategories: provider.categories,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: _buildTypeTab(
                      type: TransactionType.income,
                      label: 'Pemasukan',
                      icon: Icons.arrow_upward_rounded,
                      activeGradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      activeShadowColor: const Color(0xFF10B981),
                      context: context,
                      allCategories: provider.categories,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // 2. Hero Nominal Card (Amount Input & Quick Add Chips)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark ? AppColors.borderDark : AppColors.borderLight,
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? Colors.black.withValues(alpha: 0.25)
                        : AppColors.softBlue.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: typeColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isExpense
                                  ? Icons.arrow_downward_rounded
                                  : Icons.arrow_upward_rounded,
                              size: 13,
                              color: typeColor,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isExpense ? 'NOMINAL KELUAR' : 'NOMINAL MASUK',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: typeColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_amountController.text.isNotEmpty)
                        InkWell(
                          onTap: () {
                            setState(() => _amountController.clear());
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.backspace_outlined,
                                  size: 15,
                                  color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Hapus',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        'Rp',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: typeColor,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _amountController,
                          keyboardType: TextInputType.number,
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            color: isDark ? Colors.white : AppColors.textPrimaryLight,
                          ),
                          decoration: InputDecoration(
                            hintText: '0',
                            hintStyle: TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                              color: Colors.grey.withValues(alpha: 0.35),
                            ),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (_) {
                            setState(() {});
                          },
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Masukkan nominal transaksi';
                            }
                            if (CurrencyFormatter.parse(val) <= 0) {
                              return 'Nominal harus lebih dari 0';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Quick shortcut chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildQuickAmountChip(
                          label: '+10 Rb',
                          amount: 10000,
                          typeColor: typeColor,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildQuickAmountChip(
                          label: '+20 Rb',
                          amount: 20000,
                          typeColor: typeColor,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildQuickAmountChip(
                          label: '+50 Rb',
                          amount: 50000,
                          typeColor: typeColor,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildQuickAmountChip(
                          label: '+100 Rb',
                          amount: 100000,
                          typeColor: typeColor,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildQuickAmountChip(
                          label: '+500 Rb',
                          amount: 500000,
                          typeColor: typeColor,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // 3. Pilihan Kategori Transaksi
            _buildSectionHeader(
              context: context,
              title: 'Kategori',
              subtitle: '(${filteredCategories.length} pilihan)',
              icon: Icons.grid_view_rounded,
            ),
            Wrap(
              spacing: 8,
              runSpacing: 10,
              children: filteredCategories.map((cat) {
                final isSelected = cat.id == _selectedCategoryId;
                return AnimatedPressable(
                  scaleDown: 0.95,
                  onTap: () {
                    setState(() {
                      _selectedCategoryId = cat.id;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? cat.color.withValues(alpha: isDark ? 0.28 : 0.12)
                          : (isDark ? AppColors.cardDarkElevated : Colors.grey.withValues(alpha: 0.08)),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected ? cat.color : Colors.transparent,
                        width: 1.6,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CategoryIconWidget(
                          icon: cat.icon,
                          color: cat.color,
                          size: 26,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          cat.name,
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: isSelected
                                ? (isDark ? Colors.white : cat.color)
                                : (isDark ? Colors.grey.shade300 : AppColors.textPrimaryLight),
                          ),
                        ),
                        if (isSelected) ...[
                          const SizedBox(width: 6),
                          Icon(Icons.check_circle_rounded, size: 15, color: cat.color),
                        ],
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // 4. Pilihan Dompet / Akun (Horizontal Visual Cards)
            _buildSectionHeader(
              context: context,
              title: 'Sumber Dana / Dompet',
              subtitle: '(Pilih akun)',
              icon: Icons.account_balance_wallet_rounded,
            ),
            SizedBox(
              height: 76,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                clipBehavior: Clip.none,
                itemCount: provider.wallets.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final wallet = provider.wallets[index];
                  final isSelected = wallet.id == _selectedWalletId;
                  return AnimatedPressable(
                    scaleDown: 0.96,
                    onTap: () {
                      setState(() {
                        _selectedWalletId = wallet.id;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 165,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark
                                ? AppColors.cardDarkElevated
                                : wallet.color.withValues(alpha: 0.08))
                            : (isDark ? AppColors.cardDark : AppColors.cardLight),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? wallet.color
                              : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          width: isSelected ? 1.8 : 1.2,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: wallet.color.withValues(alpha: 0.22),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                )
                              ]
                            : null,
                      ),
                      child: Row(
                        children: [
                          CategoryIconWidget(
                            icon: wallet.icon,
                            color: wallet.color,
                            size: 34,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  wallet.name,
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  CurrencyFormatter.formatCompact(wallet.balance),
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w500,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          if (isSelected)
                            Icon(
                              Icons.check_circle_rounded,
                              size: 16,
                              color: wallet.color,
                            ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // 5. Informasi Transaksi Card (Nama, Tanggal, Catatan)
            _buildSectionHeader(
              context: context,
              title: 'Detail & Keterangan',
              icon: Icons.receipt_long_rounded,
            ),
            _buildCardContainer(
              context: context,
              padding: const EdgeInsets.all(16),
              children: [
                // Nama Transaksi
                Row(
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      size: 20,
                      color: isDark ? AppColors.softBlue : AppColors.twilightIndigo,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Nama Transaksi',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _titleController,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    hintText: isExpense
                        ? 'Contoh: Makan Siang, Bensin, Belanja'
                        : 'Contoh: Gaji Bulanan, Bonus, Penjualan',
                    hintStyle: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey.withValues(alpha: 0.6),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.cardDarkElevated.withValues(alpha: 0.5)
                        : AppColors.scaffoldLight.withValues(alpha: 0.7),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: typeColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) {
                      return 'Nama transaksi tidak boleh kosong';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                const SizedBox(height: 16),

                // Tanggal & Waktu
                InkWell(
                  onTap: _pickDate,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark
                          ? AppColors.cardDarkElevated.withValues(alpha: 0.5)
                          : AppColors.scaffoldLight.withValues(alpha: 0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: (isDark ? AppColors.softBlue : AppColors.twilightIndigo)
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: isDark ? AppColors.softBlue : AppColors.twilightIndigo,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Waktu Transaksi',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  color: isDark
                                      ? AppColors.textSecondaryDark
                                      : AppColors.textSecondaryLight,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                AppDateUtils.formatFullDate(_selectedDate),
                                style: TextStyle(
                                  fontSize: 13.5,
                                  fontWeight: FontWeight.w600,
                                  color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDark : Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: isDark ? AppColors.borderDark : AppColors.borderLight,
                            ),
                          ),
                          child: Text(
                            AppDateUtils.formatTime(_selectedDate),
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: typeColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Divider(height: 1, color: isDark ? AppColors.borderDark : AppColors.borderLight),
                const SizedBox(height: 16),

                // Catatan Tambahan (Opsional)
                Row(
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      size: 20,
                      color: isDark ? AppColors.softBlue : AppColors.twilightIndigo,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Catatan Tambahan',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.textSecondaryDark : Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '(Opsional)',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _notesController,
                  maxLines: 2,
                  style: TextStyle(
                    fontSize: 13.5,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tambahkan memo, nama toko, atau keterangan detail...',
                    hintStyle: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.withValues(alpha: 0.6),
                    ),
                    filled: true,
                    fillColor: isDark
                        ? AppColors.cardDarkElevated.withValues(alpha: 0.5)
                        : AppColors.scaffoldLight.withValues(alpha: 0.7),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: typeColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      // Sticky Ergonomic Bottom Action Button
      bottomNavigationBar: Container(
        padding: EdgeInsets.fromLTRB(
          18,
          12,
          18,
          MediaQuery.of(context).padding.bottom + 12,
        ),
        decoration: BoxDecoration(
          color: isDark ? AppColors.scaffoldDark : AppColors.scaffoldLight,
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.borderDark.withValues(alpha: 0.5) : AppColors.borderLight,
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: AnimatedPressable(
          scaleDown: 0.98,
          onTap: _save,
          child: Container(
            width: double.infinity,
            height: 52,
            decoration: BoxDecoration(
              gradient: isExpense
                  ? AppColors.coralPillGradient
                  : const LinearGradient(
                      colors: [Color(0xFF10B981), Color(0xFF059669)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: typeColor.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isEdit ? Icons.check_circle_outline_rounded : Icons.add_circle_outline_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEdit
                        ? (isExpense ? 'Perbarui Pengeluaran' : 'Perbarui Pemasukan')
                        : (isExpense ? 'Simpan Pengeluaran' : 'Simpan Pemasukan'),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

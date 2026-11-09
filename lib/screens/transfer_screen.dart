import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/transaction.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/app_date_utils.dart';
import '../utils/app_colors.dart';
import '../widgets/category_icon_widget.dart';
import '../widgets/animated_pressable.dart';

class TransferScreen extends StatefulWidget {
  const TransferScreen({super.key});

  @override
  State<TransferScreen> createState() => _TransferScreenState();
}

class _TransferScreenState extends State<TransferScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();

  String? _fromWalletId;
  String? _toWalletId;
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
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

  void _setExactAmount(double amount) {
    setState(() {
      _amountController.text = amount.toInt().toString();
    });
  }

  void _swapWallets() {
    if (_fromWalletId != null && _toWalletId != null) {
      setState(() {
        final temp = _fromWalletId;
        _fromWalletId = _toWalletId;
        _toWalletId = temp;
      });
    }
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

    if (_fromWalletId == null || _toWalletId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih dompet asal dan dompet tujuan')),
      );
      return;
    }

    if (_fromWalletId == _toWalletId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dompet asal dan tujuan tidak boleh sama')),
      );
      return;
    }

    final provider = context.read<ExpenseProvider>();
    final fromWallet = provider.getWalletById(_fromWalletId!);
    final toWallet = provider.getWalletById(_toWalletId!);
    final amount = CurrencyFormatter.parse(_amountController.text);

    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nominal harus lebih dari 0')),
      );
      return;
    }

    if (fromWallet != null && fromWallet.balance < amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Saldo ${fromWallet.name} tidak mencukupi (${CurrencyFormatter.format(fromWallet.balance)})',
          ),
          backgroundColor: AppColors.expense,
        ),
      );
      return;
    }

    final transferTx = FinancialTransaction(
      id: const Uuid().v4(),
      title: _notesController.text.trim().isNotEmpty
          ? _notesController.text.trim()
          : 'Transfer ke ${toWallet?.name ?? 'Dompet'}',
      amount: amount,
      type: TransactionType.transfer,
      categoryId: 'cat_other_exp',
      walletId: _fromWalletId!,
      toWalletId: _toWalletId,
      date: _selectedDate,
      notes: _notesController.text.trim().isEmpty ? null : _notesController.text.trim(),
    );

    provider.addTransaction(transferTx);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Transfer ${CurrencyFormatter.format(amount)} ke ${toWallet?.name ?? 'dompet tujuan'} berhasil',
        ),
      ),
    );
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

  Widget _buildQuickAmountChip({
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool isHighlight = false,
  }) {
    return AnimatedPressable(
      scaleDown: 0.93,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: isHighlight
              ? (isDark ? const Color(0xFF2E3D78) : const Color(0xFFE8EEFC))
              : (isDark ? AppColors.cardDarkElevated : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isHighlight
                ? AppColors.transfer
                : (isDark ? AppColors.borderDark : AppColors.borderLight),
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
            fontWeight: isHighlight ? FontWeight.w700 : FontWeight.w600,
            color: isHighlight
                ? AppColors.transfer
                : (isDark ? AppColors.textSecondaryDark : AppColors.deepNavy),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final wallets = provider.wallets;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_fromWalletId == null && wallets.isNotEmpty) {
      _fromWalletId = wallets.first.id;
    }
    if (_toWalletId == null && wallets.length > 1) {
      _toWalletId = wallets[1].id;
    }

    final fromWallet = _fromWalletId != null ? provider.getWalletById(_fromWalletId!) : null;
    final toWallet = _toWalletId != null ? provider.getWalletById(_toWalletId!) : null;
    final enteredAmount = CurrencyFormatter.parse(_amountController.text);
    final isInsufficient = fromWallet != null && enteredAmount > 0 && fromWallet.balance < enteredAmount;

    const transferColor = AppColors.transfer;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Transfer Antar Dompet',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18.5),
        ),
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: transferColor.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_rounded,
                size: 20,
                color: transferColor,
              ),
            ),
            onPressed: _save,
            tooltip: 'Proses Transfer',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 8, 18, 30),
          children: [
            // 1. Interactive Source & Destination Card with Central Swap Button
            _buildSectionHeader(
              context: context,
              title: 'Aliran Dana',
              subtitle: '(Pilih dompet asal & tujuan)',
              icon: Icons.sync_alt_rounded,
            ),
            _buildCardContainer(
              context: context,
              padding: const EdgeInsets.all(16),
              children: [
                // Bagian Dompet Asal
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.expense.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_circle_up_rounded,
                        color: AppColors.expense,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'DARI DOMPET ASAL',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.expense,
                      ),
                    ),
                    const Spacer(),
                    if (fromWallet != null)
                      Text(
                        'Saldo: ${CurrencyFormatter.formatCompact(fromWallet.balance)}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  key: ValueKey('from_$_fromWalletId'),
                  initialValue: _fromWalletId,
                  isExpanded: true,
                  decoration: InputDecoration(
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
                      borderSide: const BorderSide(
                        color: transferColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                  items: wallets.map((w) {
                    return DropdownMenuItem<String>(
                      value: w.id,
                      child: Row(
                        children: [
                          CategoryIconWidget(icon: w.icon, color: w.color, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              w.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            CurrencyFormatter.formatCompact(w.balance),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _fromWalletId = val),
                ),
                const SizedBox(height: 12),

                // Interactive Swap Divider
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        thickness: 1,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: AnimatedPressable(
                        scaleDown: 0.9,
                        onTap: _swapWallets,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.cardDarkElevated : Colors.white,
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: transferColor.withValues(alpha: 0.4),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: transferColor.withValues(alpha: 0.2),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.swap_vert_rounded,
                            size: 20,
                            color: transferColor,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        color: isDark ? AppColors.borderDark : AppColors.borderLight,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Bagian Dompet Tujuan
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        color: AppColors.income.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.arrow_circle_down_rounded,
                        color: AppColors.income,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text(
                      'KE DOMPET TUJUAN',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: AppColors.income,
                      ),
                    ),
                    const Spacer(),
                    if (toWallet != null)
                      Text(
                        'Saldo: ${CurrencyFormatter.formatCompact(toWallet.balance)}',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  key: ValueKey('to_$_toWalletId'),
                  initialValue: _toWalletId,
                  isExpanded: true,
                  decoration: InputDecoration(
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
                      borderSide: const BorderSide(
                        color: transferColor,
                        width: 1.5,
                      ),
                    ),
                  ),
                  items: wallets.map((w) {
                    return DropdownMenuItem<String>(
                      value: w.id,
                      child: Row(
                        children: [
                          CategoryIconWidget(icon: w.icon, color: w.color, size: 28),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              w.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13.5),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            CurrencyFormatter.formatCompact(w.balance),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.textSecondaryDark : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (val) => setState(() => _toWalletId = val),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // 2. Hero Nominal Card & Quick Add Chips
            _buildSectionHeader(
              context: context,
              title: 'Nominal Transfer',
              icon: Icons.payments_outlined,
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : AppColors.cardLight,
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isInsufficient
                      ? AppColors.expense.withValues(alpha: 0.4)
                      : (isDark ? AppColors.borderDark : AppColors.borderLight),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isInsufficient
                        ? AppColors.expense.withValues(alpha: 0.1)
                        : (isDark
                            ? Colors.black.withValues(alpha: 0.25)
                            : AppColors.softBlue.withValues(alpha: 0.08)),
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
                          color: transferColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.swap_horiz_rounded,
                              size: 13,
                              color: transferColor,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'NOMINAL PINDAH BUKU',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                                color: transferColor,
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
                      const Text(
                        'Rp',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: transferColor,
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
                              return 'Masukkan nominal transfer';
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
                  if (isInsufficient) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.expense),
                        const SizedBox(width: 4),
                        Text(
                          'Saldo asal tidak mencukupi (${CurrencyFormatter.format(fromWallet.balance)})',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.expense,
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 14),
                  // Quick Amount Chips
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        if (fromWallet != null && fromWallet.balance > 0) ...[
                          _buildQuickAmountChip(
                            label: 'Semua Saldo',
                            isHighlight: true,
                            onTap: () => _setExactAmount(fromWallet.balance),
                            isDark: isDark,
                          ),
                          const SizedBox(width: 8),
                        ],
                        _buildQuickAmountChip(
                          label: '+50 Rb',
                          onTap: () => _addQuickAmount(50000),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildQuickAmountChip(
                          label: '+100 Rb',
                          onTap: () => _addQuickAmount(100000),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildQuickAmountChip(
                          label: '+200 Rb',
                          onTap: () => _addQuickAmount(200000),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildQuickAmountChip(
                          label: '+500 Rb',
                          onTap: () => _addQuickAmount(500000),
                          isDark: isDark,
                        ),
                        const SizedBox(width: 8),
                        _buildQuickAmountChip(
                          label: '+1 Jt',
                          onTap: () => _addQuickAmount(1000000),
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),

            // 3. Detail & Tanggal Card
            _buildSectionHeader(
              context: context,
              title: 'Detail & Catatan',
              icon: Icons.receipt_long_rounded,
            ),
            _buildCardContainer(
              context: context,
              padding: const EdgeInsets.all(16),
              children: [
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
                            color: transferColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.calendar_today_rounded,
                            size: 18,
                            color: transferColor,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Waktu Transfer',
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
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: transferColor,
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

                // Catatan Transfer
                Row(
                  children: [
                    Icon(
                      Icons.notes_rounded,
                      size: 20,
                      color: isDark ? AppColors.softBlue : AppColors.twilightIndigo,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Catatan Transfer',
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
                    hintText: 'Misal: Tarik tunai dari ATM, Top-up e-wallet, Tabungan...',
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
                      borderSide: const BorderSide(
                        color: transferColor,
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
      // Sticky Action Button at the Bottom
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
              gradient: const LinearGradient(
                colors: [Color(0xFF4361EE), Color(0xFF3F37C9)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: transferColor.withValues(alpha: 0.35),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.sync_alt_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Proses Transfer Dana',
                    style: TextStyle(
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

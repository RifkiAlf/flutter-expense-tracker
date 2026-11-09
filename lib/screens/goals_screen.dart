import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/goal.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/app_colors.dart';
import '../widgets/goal_card.dart';
import '../widgets/category_icon_widget.dart';
import '../widgets/animated_pressable.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  static Widget _buildQuickChip({
    required String label,
    required VoidCallback onTap,
    required Color color,
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
              ? color.withValues(alpha: isDark ? 0.25 : 0.15)
              : (isDark ? AppColors.cardDarkElevated : Colors.white),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isHighlight ? color : (isDark ? AppColors.borderDark : AppColors.borderLight),
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
            color: isHighlight ? color : (isDark ? AppColors.textSecondaryDark : AppColors.deepNavy),
          ),
        ),
      ),
    );
  }

  void _showAddEditGoalDialog(BuildContext context, [FinancialGoal? goalToEdit]) {
    final provider = context.read<ExpenseProvider>();
    final titleController = TextEditingController(text: goalToEdit?.title ?? '');
    final targetController = TextEditingController(
      text: goalToEdit != null ? goalToEdit.targetAmount.toInt().toString() : '',
    );
    final currentController = TextEditingController(
      text: goalToEdit != null ? goalToEdit.currentAmount.toInt().toString() : '0',
    );
    final notesController = TextEditingController(text: goalToEdit?.notes ?? '');

    DateTime targetDate = goalToEdit?.targetDate ?? DateTime.now().add(const Duration(days: 90));

    final availableColors = [
      0xFF10B981, // Emerald
      0xFFF59E0B, // Amber
      0xFF6366F1, // Indigo
      0xFFEC4899, // Pink
      0xFF06B6D4, // Cyan
    ];
    int selectedColor = goalToEdit?.colorValue ?? availableColors.first;
    String? dialogError;

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
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan Expanded untuk mencegah overflow teks
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            goalToEdit != null ? 'Ubah Target Tabungan' : 'Buat Target Impian Baru',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                          tooltip: 'Tutup',
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Nama Target / Impian', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Liburan ke Bali, Beli Motor, Dana Darurat',
                      ),
                      onChanged: (_) {
                        if (dialogError != null) {
                          setModalState(() => dialogError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text('Target Nominal', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: targetController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixText: 'Rp ',
                        hintText: '10.000.000',
                      ),
                      onChanged: (_) {
                        if (dialogError != null) {
                          setModalState(() => dialogError = null);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text('Sudah Terkumpul Saat Ini', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: currentController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixText: 'Rp ',
                        hintText: '0',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Target Tercapai Sebelum', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      leading: const Icon(Icons.calendar_month_rounded),
                      title: Text(
                        '${targetDate.day}/${targetDate.month}/${targetDate.year}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      trailing: const Text('Ubah Tanggal', style: TextStyle(color: AppColors.steelBlue, fontWeight: FontWeight.w600)),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: targetDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2040),
                        );
                        if (picked != null) {
                          setModalState(() => targetDate = picked);
                        }
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text('Warna Tema Target', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 8),
                    Row(
                      children: availableColors.map((c) {
                        final isSelected = selectedColor == c;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedColor = c),
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: Color(c),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.white : Colors.transparent,
                                width: 2.5,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Color(c).withValues(alpha: 0.5),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, color: Colors.white, size: 18)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 14),
                    const Text('Catatan (Opsional)', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(hintText: 'Tujuan khusus atau motivasi...'),
                    ),
                    if (dialogError != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.expense.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.expense.withValues(alpha: 0.35),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.expense,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                dialogError!,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.expense,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    AnimatedPressable(
                      scaleDown: 0.98,
                      onTap: () {
                        final title = titleController.text.trim();
                        if (title.isEmpty) {
                          setModalState(() {
                            dialogError = 'Nama impian tidak boleh kosong';
                          });
                          return;
                        }
                        final target = CurrencyFormatter.parse(targetController.text);
                        final current = CurrencyFormatter.parse(currentController.text);

                        if (target <= 0) {
                          setModalState(() {
                            dialogError = 'Target nominal harus lebih dari 0';
                          });
                          return;
                        }

                        if (goalToEdit != null) {
                          final updated = goalToEdit.copyWith(
                            title: title,
                            targetAmount: target,
                            currentAmount: current,
                            targetDate: targetDate,
                            colorValue: selectedColor,
                            notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                          );
                          provider.updateGoal(updated);
                        } else {
                          final newGoal = FinancialGoal(
                            id: const Uuid().v4(),
                            title: title,
                            targetAmount: target,
                            currentAmount: current,
                            targetDate: targetDate,
                            iconCodePoint: Icons.savings.codePoint,
                            colorValue: selectedColor,
                            notes: notesController.text.trim().isEmpty ? null : notesController.text.trim(),
                          );
                          provider.addGoal(newGoal);
                        }
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: Color(selectedColor),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Color(selectedColor).withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            goalToEdit != null ? 'Simpan Perubahan' : 'Buat Target Impian',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
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

  void _showContributeDialog(BuildContext context, FinancialGoal goal) {
    final provider = context.read<ExpenseProvider>();
    final amountController = TextEditingController();
    String? selectedWalletId = provider.wallets.isNotEmpty ? provider.wallets.first.id : null;
    final remainingAmount = (goal.targetAmount - goal.currentAmount).clamp(0.0, double.infinity);
    String? errorMessage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            final isDark = Theme.of(context).brightness == Brightness.dark;
            final selectedWallet = selectedWalletId != null ? provider.getWalletById(selectedWalletId!) : null;
            final enteredAmount = CurrencyFormatter.parse(amountController.text);
            final isOverBalance = selectedWallet != null && enteredAmount > 0 && selectedWallet.balance < enteredAmount;

            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
                left: 20,
                right: 20,
                top: 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header dengan Expanded untuk mencegah right overflowed
                    Row(
                      children: [
                        CategoryIconWidget(
                          icon: goal.icon,
                          color: goal.color,
                          size: 38,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Nabung ke Target',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                goal.title,
                                style: const TextStyle(
                                  fontSize: 16.5,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(ctx),
                          tooltip: 'Tutup',
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Card Progress Target
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: goal.color.withValues(alpha: isDark ? 0.18 : 0.08),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: goal.color.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Terkumpul: ${CurrencyFormatter.format(goal.currentAmount)}',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Sisa Target: ${CurrencyFormatter.format(remainingAmount)}',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                            decoration: BoxDecoration(
                              color: goal.color,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${(goal.progress * 100).clamp(0, 100).toStringAsFixed(0)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Pilih Dompet Sumber Dana
                    const Text('Pilih Dompet Sumber Dana', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      isExpanded: true,
                      initialValue: selectedWalletId,
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
                          borderSide: BorderSide(
                            color: goal.color,
                            width: 1.5,
                          ),
                        ),
                      ),
                      items: provider.wallets.map((w) {
                        return DropdownMenuItem<String>(
                          value: w.id,
                          child: Row(
                            children: [
                              CategoryIconWidget(icon: w.icon, color: w.color, size: 26),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  w.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
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
                      onChanged: (val) {
                        setModalState(() {
                          selectedWalletId = val;
                          errorMessage = null;
                        });
                      },
                    ),
                    const SizedBox(height: 14),

                    // Nominal Tabungan Input
                    const Text('Nominal yang Ditabung', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        prefixText: 'Rp ',
                        prefixStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: goal.color),
                        hintText: '0',
                        filled: true,
                        fillColor: isDark
                            ? AppColors.cardDarkElevated.withValues(alpha: 0.5)
                            : AppColors.scaffoldLight.withValues(alpha: 0.7),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isOverBalance
                                ? AppColors.expense
                                : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isOverBalance
                                ? AppColors.expense
                                : (isDark ? AppColors.borderDark : AppColors.borderLight),
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isOverBalance ? AppColors.expense : goal.color,
                            width: 1.5,
                          ),
                        ),
                        suffixIcon: amountController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear_rounded, size: 20),
                                onPressed: () {
                                  setModalState(() {
                                    amountController.clear();
                                    errorMessage = null;
                                  });
                                },
                              )
                            : null,
                      ),
                      onChanged: (_) {
                        setModalState(() {
                          errorMessage = null;
                        });
                      },
                    ),
                    if (isOverBalance) ...[
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          const Icon(Icons.warning_amber_rounded, size: 14, color: AppColors.expense),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              'Saldo ${selectedWallet.name} tidak mencukupi (${CurrencyFormatter.format(selectedWallet.balance)})',
                              style: const TextStyle(
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: AppColors.expense,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 10),

                    // Quick Shortcut Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          if (remainingAmount > 0) ...[
                            _buildQuickChip(
                              label: 'Sisa Target',
                              isHighlight: true,
                              color: goal.color,
                              isDark: isDark,
                              onTap: () {
                                setModalState(() {
                                  amountController.text = remainingAmount.toInt().toString();
                                  errorMessage = null;
                                });
                              },
                            ),
                            const SizedBox(width: 8),
                          ],
                          _buildQuickChip(
                            label: '+50 Rb',
                            color: goal.color,
                            isDark: isDark,
                            onTap: () {
                              final current = CurrencyFormatter.parse(amountController.text);
                              setModalState(() {
                                amountController.text = (current + 50000).toInt().toString();
                                errorMessage = null;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildQuickChip(
                            label: '+100 Rb',
                            color: goal.color,
                            isDark: isDark,
                            onTap: () {
                              final current = CurrencyFormatter.parse(amountController.text);
                              setModalState(() {
                                amountController.text = (current + 100000).toInt().toString();
                                errorMessage = null;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildQuickChip(
                            label: '+200 Rb',
                            color: goal.color,
                            isDark: isDark,
                            onTap: () {
                              final current = CurrencyFormatter.parse(amountController.text);
                              setModalState(() {
                                amountController.text = (current + 200000).toInt().toString();
                                errorMessage = null;
                              });
                            },
                          ),
                          const SizedBox(width: 8),
                          _buildQuickChip(
                            label: '+500 Rb',
                            color: goal.color,
                            isDark: isDark,
                            onTap: () {
                              final current = CurrencyFormatter.parse(amountController.text);
                              setModalState(() {
                                amountController.text = (current + 500000).toInt().toString();
                                errorMessage = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    if (errorMessage != null) ...[
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.expense.withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.expense.withValues(alpha: 0.4),
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline_rounded,
                              color: AppColors.expense,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                errorMessage!,
                                style: const TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.expense,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 22),

                    // Tombol Konfirmasi Menabung
                    AnimatedPressable(
                      scaleDown: 0.98,
                      onTap: () {
                        final amount = CurrencyFormatter.parse(amountController.text);
                        if (amount <= 0) {
                          setModalState(() {
                            errorMessage = 'Masukkan nominal tabungan lebih dari 0';
                          });
                          return;
                        }
                        if (selectedWalletId == null || selectedWallet == null) {
                          setModalState(() {
                            errorMessage = 'Silakan pilih dompet sumber dana';
                          });
                          return;
                        }
                        if (selectedWallet.balance < amount) {
                          setModalState(() {
                            errorMessage = 'Saldo ${selectedWallet.name} tidak mencukupi (${CurrencyFormatter.format(selectedWallet.balance)})';
                          });
                          return;
                        }

                        provider.contributeToGoal(
                          goalId: goal.id,
                          amount: amount,
                          walletId: selectedWalletId!,
                        );
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Berhasil menambahkan ${CurrencyFormatter.format(amount)} ke "${goal.title}"',
                            ),
                            backgroundColor: const Color(0xFF10B981),
                          ),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 50,
                        decoration: BoxDecoration(
                          color: goal.color,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: goal.color.withValues(alpha: 0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: const Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.savings_rounded, color: Colors.white, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'Konfirmasi Menabung',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                ),
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
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final goals = provider.goals;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Target Menabung'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Tambah Target',
            onPressed: () => _showAddEditGoalDialog(context),
          ),
        ],
      ),
      body: goals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.savings_outlined, size: 64, color: Colors.grey.shade400),
                  const SizedBox(height: 12),
                  const Text(
                    'Belum ada target impian',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text('Tentukan impian finansial Anda dan mulai menabung!'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddEditGoalDialog(context),
                    child: const Text('Buat Target Pertama'),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              itemCount: goals.length,
              itemBuilder: (context, index) {
                final goal = goals[index];
                return GoalCard(
                  goal: goal,
                  onContribute: () => _showContributeDialog(context, goal),
                  onEdit: () => _showAddEditGoalDialog(context, goal),
                  onDelete: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Hapus Target?'),
                        content: Text('Yakin ingin menghapus target "${goal.title}"?'),
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
                      provider.deleteGoal(goal.id);
                    }
                  },
                );
              },
            ),
    );
  }
}

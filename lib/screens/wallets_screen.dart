import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/wallet.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/app_colors.dart';
import '../widgets/category_icon_widget.dart';
import '../widgets/animated_pressable.dart';
import '../widgets/smooth_entrance.dart';
import 'transfer_screen.dart';

class WalletsScreen extends StatelessWidget {
  const WalletsScreen({super.key});

  void _showAddEditWalletDialog(BuildContext context, [Wallet? walletToEdit]) {
    final provider = context.read<ExpenseProvider>();
    final nameController = TextEditingController(text: walletToEdit?.name ?? '');
    final balanceController = TextEditingController(
      text: walletToEdit != null ? walletToEdit.balance.toInt().toString() : '',
    );
    final accountController = TextEditingController(text: walletToEdit?.accountNumber ?? '');
    WalletType selectedType = walletToEdit?.type ?? WalletType.cash;

    final availableColors = [
      0xFF052659, // Deep Navy
      0xFF5483B3, // Steel Blue
      0xFF7DA0CA, // Soft Glacier
      0xFF021024, // Midnight Abyss
      0xFF10B981, // Emerald
      0xFFD97706, // Amber
      0xFF8B5CF6, // Purple
      0xFFEC4899, // Pink
    ];
    int selectedColor = walletToEdit?.colorValue ?? availableColors.first;

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
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          walletToEdit != null ? 'Ubah Dompet' : 'Tambah Dompet Baru',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Nama Dompet / Rekening', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        hintText: 'Contoh: Bank Jago, Dompet Saku, OVO...',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Tipe Akun', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<WalletType>(
                      initialValue: selectedType,
                      items: const [
                        DropdownMenuItem(value: WalletType.cash, child: Text('Uang Tunai (Cash)')),
                        DropdownMenuItem(value: WalletType.bank, child: Text('Rekening Bank')),
                        DropdownMenuItem(value: WalletType.ewallet, child: Text('E-Wallet / Dompet Digital')),
                        DropdownMenuItem(value: WalletType.savings, child: Text('Tabungan Khusus')),
                        DropdownMenuItem(value: WalletType.other, child: Text('Lainnya')),
                      ],
                      onChanged: (val) {
                        if (val != null) setModalState(() => selectedType = val);
                      },
                    ),
                    const SizedBox(height: 14),
                    const Text('Saldo Akun', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: balanceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        prefixText: 'Rp ',
                        hintText: '0',
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text('Nomor Rekening / Keterangan (Opsional)', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 6),
                    TextField(
                      controller: accountController,
                      decoration: const InputDecoration(
                        hintText: 'Misal: **** 1234',
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text('Pilih Warna Tema', style: TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(
                      children: availableColors.map((colorVal) {
                        final isSelected = selectedColor == colorVal;
                        return GestureDetector(
                          onTap: () => setModalState(() => selectedColor = colorVal),
                          child: Container(
                            margin: const EdgeInsets.only(right: 10),
                            width: 32,
                            height: 32,
                            decoration: BoxDecoration(
                              color: Color(colorVal),
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(color: Colors.white, width: 3)
                                  : null,
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Color(colorVal).withValues(alpha: 0.6),
                                        blurRadius: 6,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: isSelected
                                ? const Icon(Icons.check, size: 18, color: Colors.white)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          final name = nameController.text.trim();
                          if (name.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Nama dompet tidak boleh kosong')),
                            );
                            return;
                          }
                          final balance = CurrencyFormatter.parse(balanceController.text);

                          IconData icon = Icons.account_balance_wallet;
                          if (selectedType == WalletType.cash) icon = Icons.payments;
                          if (selectedType == WalletType.bank) icon = Icons.account_balance;
                          if (selectedType == WalletType.ewallet) icon = Icons.phone_android;

                          if (walletToEdit != null) {
                            final updated = walletToEdit.copyWith(
                              name: name,
                              type: selectedType,
                              balance: balance,
                              colorValue: selectedColor,
                              accountNumber: accountController.text.trim().isEmpty
                                  ? null
                                  : accountController.text.trim(),
                            );
                            provider.updateWallet(updated);
                          } else {
                            final newWallet = Wallet(
                              id: const Uuid().v4(),
                              name: name,
                              type: selectedType,
                              balance: balance,
                              iconCodePoint: icon.codePoint,
                              colorValue: selectedColor,
                              accountNumber: accountController.text.trim().isEmpty
                                  ? null
                                  : accountController.text.trim(),
                            );
                            provider.addWallet(newWallet);
                          }
                          Navigator.pop(ctx);
                        },
                        child: Text(walletToEdit != null ? 'Simpan Perubahan' : 'Buat Dompet'),
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
    final wallets = provider.wallets;
    final totalBalance = provider.totalBalance;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dompet & Rekening'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Tambah Dompet',
            onPressed: () => _showAddEditWalletDialog(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Total Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: AppColors.heroGradient,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: const Color(0xFF1B3D6B), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: AppColors.abyss.withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Kekayaan Bersih',
                      style: TextStyle(
                        color: AppColors.iceBlue.withValues(alpha: 0.85),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      CurrencyFormatter.format(totalBalance),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                AnimatedPressable(
                  scaleDown: 0.93,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (ctx) => const TransferScreen()),
                    );
                  },
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (ctx) => const TransferScreen()),
                      );
                    },
                    icon: const Icon(Icons.swap_horiz, size: 18),
                    label: const Text('Transfer'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.steelBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          const Text(
            'Daftar Dompet Tersedia',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 10),

          ...wallets.asMap().entries.map((entry) {
            final index = entry.key;
            final wallet = entry.value;
            final isDark = Theme.of(context).brightness == Brightness.dark;
            return SmoothEntrance(
              delay: Duration(milliseconds: index * 50),
              child: AnimatedPressable(
                scaleDown: 0.98,
                onTap: () => _showAddEditWalletDialog(context, wallet),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.cardDarkGlass.withValues(alpha: 0.8)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isDark
                          ? AppColors.borderDarkGlass.withValues(alpha: 0.38)
                          : AppColors.borderLight,
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
                        icon: wallet.icon,
                        color: wallet.color,
                        size: 46,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              wallet.name,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: isDark ? Colors.white : AppColors.textPrimaryLight,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              wallet.accountNumber != null && wallet.accountNumber!.isNotEmpty
                                  ? wallet.accountNumber!
                                  : wallet.type.name.toUpperCase(),
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.textSecondaryDark : Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            CurrencyFormatter.format(wallet.balance),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                              color: wallet.balance < 0
                                  ? AppColors.coral
                                  : (isDark ? Colors.white : AppColors.textPrimaryLight),
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, size: 18),
                                visualDensity: VisualDensity.compact,
                                tooltip: 'Edit Dompet',
                                onPressed: () => _showAddEditWalletDialog(context, wallet),
                              ),
                              if (wallets.length > 1)
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, size: 18, color: AppColors.coral),
                                  visualDensity: VisualDensity.compact,
                                  tooltip: 'Hapus',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                      title: const Text('Hapus Dompet?'),
                                      content: Text('Yakin ingin menghapus ${wallet.name}?'),
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
                                    provider.deleteWallet(wallet.id);
                                  }
                                },
                              ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
        ],
      ),
    );
  }
}

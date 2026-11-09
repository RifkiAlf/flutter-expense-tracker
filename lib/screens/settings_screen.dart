import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/theme_provider.dart';
import 'wallets_screen.dart';
import 'goals_screen.dart';
import '../utils/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showExportDialog(BuildContext context, String jsonContent) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: const [
            Icon(Icons.file_download_outlined, color: Color(0xFF10B981)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'Export Data (JSON)',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Data berikut berisi seluruh riwayat transaksi, dompet, anggaran, dan target impian dalam format JSON:',
                style: TextStyle(fontSize: 13),
              ),
              const SizedBox(height: 12),
              Container(
                height: 160,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    jsonContent,
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Tutup')),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF10B981),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Salin ke Clipboard'),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: jsonContent));
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Data JSON berhasil disalin ke clipboard!'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  void _showImportDialog(BuildContext context, ExpenseProvider expenseProvider) {
    final controller = TextEditingController();
    String? errorMessage;
    bool isProcessing = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: const [
              Icon(Icons.file_upload_outlined, color: AppColors.steelBlue),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Import Data (JSON)',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Tempelkan (paste) teks JSON cadangan Anda untuk memulihkan seluruh catatan transaksi, dompet, dan target:',
                    style: TextStyle(fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        icon: const Icon(Icons.content_paste_rounded, size: 16),
                        label: const Text('Tempel Clipboard'),
                        onPressed: isProcessing
                            ? null
                            : () async {
                                final data = await Clipboard.getData(Clipboard.kTextPlain);
                                if (data != null && data.text != null && data.text!.trim().isNotEmpty) {
                                  setDialogState(() {
                                    controller.text = data.text!;
                                    errorMessage = null;
                                  });
                                } else {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Clipboard kosong atau tidak berisi teks.'),
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  }
                                }
                              },
                      ),
                      const SizedBox(width: 8),
                      if (controller.text.isNotEmpty)
                        TextButton.icon(
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey,
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                            textStyle: const TextStyle(fontSize: 12),
                          ),
                          icon: const Icon(Icons.clear, size: 14),
                          label: const Text('Hapus'),
                          onPressed: isProcessing
                              ? null
                              : () {
                                  setDialogState(() {
                                    controller.clear();
                                    errorMessage = null;
                                  });
                                },
                        ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: controller,
                    maxLines: 7,
                    enabled: !isProcessing,
                    onChanged: (_) {
                      if (errorMessage != null) {
                        setDialogState(() => errorMessage = null);
                      }
                    },
                    style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                    decoration: InputDecoration(
                      hintText: '{\n  "transactions": [...],\n  "wallets": [...]\n}',
                      hintStyle: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey.withValues(alpha: 0.08),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide(color: Colors.grey.withValues(alpha: 0.3)),
                      ),
                      contentPadding: const EdgeInsets.all(12),
                    ),
                  ),
                  if (errorMessage != null) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.error_outline, size: 16, color: Colors.red),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(color: Colors.red, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.amber.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Icon(Icons.warning_amber_rounded, size: 16, color: Colors.amber),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Perhatian: Pemulihan data ini akan memperbarui dan menyelaraskan transaksi & dompet sesuai berkas JSON yang diimpor.',
                            style: TextStyle(fontSize: 11.5, color: Colors.amber),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isProcessing ? null : () => Navigator.pop(ctx),
              child: const Text('Batal'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.steelBlue,
                foregroundColor: Colors.white,
              ),
              icon: isProcessing
                  ? const SizedBox(
                      width: 14,
                      height: 14,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.check_circle_outline, size: 16),
              label: Text(isProcessing ? 'Memproses...' : 'Pulihkan Data'),
              onPressed: isProcessing
                  ? null
                  : () async {
                      final text = controller.text.trim();
                      if (text.isEmpty) {
                        setDialogState(() => errorMessage = 'Silakan masukkan teks JSON terlebih dahulu.');
                        return;
                      }

                      setDialogState(() {
                        isProcessing = true;
                        errorMessage = null;
                      });

                      final result = await expenseProvider.importDataFromJson(text);

                      if (result.success) {
                        if (ctx.mounted) Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: const Color(0xFF10B981),
                              behavior: SnackBarBehavior.floating,
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle, color: Colors.white),
                                  const SizedBox(width: 8),
                                  Expanded(child: Text(result.message)),
                                ],
                              ),
                            ),
                          );
                        }
                      } else {
                        setDialogState(() {
                          isProcessing = false;
                          errorMessage = result.message;
                        });
                      }
                    },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon, bool isDark) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 18, 4, 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 15,
            color: isDark ? AppColors.softBlue : AppColors.steelBlue,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.9,
              color: isDark ? AppColors.softBlue : AppColors.steelBlue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardGroup({
    required BuildContext context,
    required List<Widget> children,
    bool isDanger = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardBg = isDark
        ? (isDanger
            ? Colors.red.withValues(alpha: 0.08)
            : AppColors.cardDarkGlass.withValues(alpha: 0.85))
        : (isDanger
            ? const Color(0xFFFEF2F2)
            : Colors.white.withValues(alpha: 0.90));
    final borderCol = isDark
        ? (isDanger
            ? Colors.red.withValues(alpha: 0.3)
            : AppColors.borderDarkGlass.withValues(alpha: 0.35))
        : (isDanger
            ? const Color(0xFFFECACA)
            : Colors.white.withValues(alpha: 0.85));

    return Container(
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: borderCol, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x30000000) : const Color(0x0A1C2E52),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Column(
          children: children,
        ),
      ),
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
    bool isDanger = false,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: isDark ? 0.20 : 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: iconColor, size: 21),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: isDanger
                          ? Colors.red
                          : (isDark ? Colors.white : AppColors.textPrimaryLight),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDanger
                          ? Colors.red.shade400
                          : (isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight),
                    ),
                  ),
                ],
              ),
            ),
            ?trailing,
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: isDark ? 0.20 : 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Switch.adaptive(
            value: value,
            activeTrackColor: AppColors.coral.withValues(alpha: 0.5),
            activeThumbColor: AppColors.coral,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Divider(
      height: 1,
      thickness: 1,
      indent: 70,
      endIndent: 16,
      color: isDark ? Colors.white.withValues(alpha: 0.08) : Colors.black.withValues(alpha: 0.05),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();
    final expenseProvider = context.watch<ExpenseProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Pengaturan & Fitur'),
      ),
      body: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
        children: [
          // 1. Tampilan & Privasi
          _buildSectionHeader('TAMPILAN & PRIVASI', Icons.palette_outlined, isDark),
          _buildCardGroup(
            context: context,
            children: [
              _buildSwitchTile(
                context: context,
                icon: themeProvider.isDarkMode ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                iconColor: const Color(0xFF818CF8),
                title: 'Mode Gelap (Dark Mode)',
                subtitle: 'Tema gelap nyaman di mata & hemat daya baterai',
                value: themeProvider.isDarkMode,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
              _buildDivider(isDark),
              _buildSwitchTile(
                context: context,
                icon: Icons.visibility_off_rounded,
                iconColor: AppColors.coral,
                title: 'Sembunyikan Saldo',
                subtitle: 'Samarkan nominal saldo untuk privasi di tempat umum',
                value: expenseProvider.hideBalance,
                onChanged: (_) => expenseProvider.toggleHideBalance(),
              ),
            ],
          ),

          // 2. Manajemen Keuangan
          _buildSectionHeader('MANAJEMEN KEUANGAN', Icons.account_balance_outlined, isDark),
          _buildCardGroup(
            context: context,
            children: [
              _buildActionTile(
                context: context,
                icon: Icons.account_balance_wallet_rounded,
                iconColor: AppColors.steelBlue,
                title: 'Kelola Dompet & Rekening',
                subtitle: 'Atur dompet tunai, rekening bank, & e-wallet',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: AppColors.steelBlue.withValues(alpha: isDark ? 0.22 : 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${expenseProvider.wallets.length} Akun',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: isDark ? AppColors.softBlue : AppColors.steelBlue,
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const WalletsScreen()),
                  );
                },
              ),
              _buildDivider(isDark),
              _buildActionTile(
                context: context,
                icon: Icons.flag_rounded,
                iconColor: const Color(0xFFF59E0B),
                title: 'Target Tabungan Impian',
                subtitle: 'Pantau kemajuan tabungan impian Anda',
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3.5),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF59E0B).withValues(alpha: isDark ? 0.22 : 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '${expenseProvider.goals.length} Target',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF59E0B),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (ctx) => const GoalsScreen()),
                  );
                },
              ),
            ],
          ),

          // 3. Data & Cadangan
          _buildSectionHeader('DATA & CADANGAN', Icons.backup_outlined, isDark),
          _buildCardGroup(
            context: context,
            children: [
              _buildActionTile(
                context: context,
                icon: Icons.file_download_outlined,
                iconColor: const Color(0xFF10B981),
                title: 'Export Data (JSON)',
                subtitle: 'Salin atau cadangkan seluruh riwayat ke teks JSON',
                trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
                onTap: () {
                  final json = expenseProvider.exportDataAsJson();
                  _showExportDialog(context, json);
                },
              ),
              _buildDivider(isDark),
              _buildActionTile(
                context: context,
                icon: Icons.file_upload_outlined,
                iconColor: const Color(0xFF06B6D4),
                title: 'Import Data (JSON)',
                subtitle: 'Pulihkan data transaksi & dompet dari backup JSON',
                trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
                onTap: () {
                  _showImportDialog(context, expenseProvider);
                },
              ),
              _buildDivider(isDark),
              _buildActionTile(
                context: context,
                icon: Icons.auto_stories_outlined,
                iconColor: const Color(0xFF6366F1),
                title: 'Muat Data Contoh (Demo)',
                subtitle: 'Isi aplikasi dengan contoh transaksi & kategori siap coba',
                trailing: Icon(Icons.chevron_right_rounded, color: Colors.grey.shade400, size: 20),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      title: const Text('Muat Data Demo?'),
                      content: const Text(
                        'Ini akan mengisi data transaksi sampel agar Anda dapat mencoba semua fitur visual grafik dan anggaran.',
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Muat Demo'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await expenseProvider.loadDemoData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Data demo berhasil dimuat!'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),

          // 4. Zona Tindakan / Reset
          _buildSectionHeader('ZONA TINDAKAN', Icons.warning_amber_rounded, isDark),
          _buildCardGroup(
            context: context,
            isDanger: true,
            children: [
              _buildActionTile(
                context: context,
                icon: Icons.delete_forever_rounded,
                iconColor: Colors.red,
                title: 'Reset Seluruh Data',
                subtitle: 'Hapus seluruh transaksi, anggaran, & mulai dari awal',
                isDanger: true,
                trailing: Icon(Icons.chevron_right_rounded, color: Colors.red.shade300, size: 20),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                      title: const Text('Reset Seluruh Data?'),
                      content: const Text(
                        'Tindakan ini tidak dapat dibatalkan. Semua transaksi, anggaran, dan target impian akan dihapus permanen.',
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Batal')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                          onPressed: () => Navigator.pop(ctx, true),
                          child: const Text('Hapus Semua'),
                        ),
                      ],
                    ),
                  );
                  if (confirm == true) {
                    await expenseProvider.resetAllData();
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Seluruh data berhasil dibersihkan'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 5. Informasi & Branding Aplikasi
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark
                  ? AppColors.cardDarkGlass.withValues(alpha: 0.6)
                  : Colors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: isDark
                    ? AppColors.borderDarkGlass.withValues(alpha: 0.25)
                    : Colors.white.withValues(alpha: 0.6),
                width: 1,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    gradient: AppColors.coralPillGradient,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.coral.withValues(alpha: 0.35),
                        blurRadius: 14,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.account_balance_wallet_rounded,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Smart Money Tracker',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.5,
                    color: isDark ? Colors.white : AppColors.textPrimaryLight,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.1)
                        : AppColors.deepNavy.withValues(alpha: 0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    'Versi 1.0.0',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Pencatatan pengeluaran, pemasukan, anggaran cerdas, mutasi antar dompet & target impian.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11.5,
                    color: isDark ? Colors.white54 : Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

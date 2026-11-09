import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../utils/currency_formatter.dart';
import '../utils/app_date_utils.dart';
import '../utils/app_colors.dart';
import 'animated_pressable.dart';
import 'smooth_entrance.dart';

/// Kartu Hero Vektor Bergaya "Mountain Sunset Financial Journey"
/// Terinspirasi dari mockup visual pemandangan gunung dengan kurva trajectory node finansial
class MountainHeroCard extends StatelessWidget {
  const MountainHeroCard({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ExpenseProvider>();
    final isHidden = provider.hideBalance;
    final totalBalance = provider.totalBalance;
    final monthIncome = provider.getCurrentMonthIncome();
    final monthExpense = provider.getCurrentMonthExpense();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SmoothEntrance(
      duration: const Duration(milliseconds: 320),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        height: 260,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? const Color(0x60050A1A)
                  : const Color(0x241C2E5C),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // 1. Lukisan Lanskap Vektor (diisolasi dengan RepaintBoundary agar dirender 1x ke GPU cache)
              RepaintBoundary(
                child: CustomPaint(
                  painter: _MountainLandscapePainter(isDark: isDark),
                ),
              ),

              // 2. Lapisan Gradient Tint agar teks di atasnya tetap terbaca sempurna
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: isDark ? 0.35 : 0.15),
                        Colors.transparent,
                        Colors.black.withValues(alpha: isDark ? 0.65 : 0.40),
                      ],
                      stops: const [0.0, 0.45, 1.0],
                    ),
                  ),
                ),
              ),

              // 3. Konten Teks & Metrik Finansial
              Padding(
                padding: const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Bar: Tanggal Pill & Tombol Privasi Saldo
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Pill Tanggal Hari Ini
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.85),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.3),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 13,
                                color: isDark ? AppColors.iceBlue : AppColors.deepNavy,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                AppDateUtils.formatShortDate(DateTime.now()),
                                style: TextStyle(
                                  color: isDark ? Colors.white : AppColors.deepNavy,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Tombol Mata Privasi Saldo
                        AnimatedPressable(
                          scaleDown: 0.88,
                          onTap: () => provider.toggleHideBalance(),
                          child: Container(
                            padding: const EdgeInsets.all(7),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: isDark ? 0.18 : 0.85),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withValues(alpha: 0.3),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.08),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              switchInCurve: Curves.easeOutBack,
                              switchOutCurve: Curves.easeInBack,
                              transitionBuilder: (child, animation) {
                                return ScaleTransition(
                                  scale: Tween<double>(begin: 0.75, end: 1.0).animate(
                                    CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
                                  ),
                                  child: FadeTransition(
                                    opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
                                    child: child,
                                  ),
                                );
                              },
                              child: Icon(
                                isHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                key: ValueKey<bool>(isHidden),
                                color: isDark ? Colors.white : AppColors.deepNavy,
                                size: 17,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    // Area Bawah: Total Saldo & Pill Pemasukan/Pengeluaran
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Angka Saldo Utama
                        _buildSmoothValueSwitcher(
                          value: isHidden ? '••••••••' : CurrencyFormatter.format(totalBalance),
                          keyPrefix: 'total_$isHidden',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 27,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.6,
                            shadows: [
                              Shadow(
                                color: Color(0x80000000),
                                blurRadius: 8,
                                offset: Offset(0, 2),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12),

                        // Pill Bar: Pemasukan & Pengeluaran Bulan Ini
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: (isDark ? const Color(0xFF0F1735) : const Color(0xFF131F46))
                                .withValues(alpha: 0.72),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.16),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            children: [
                              // Pemasukan
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.income.withValues(alpha: 0.25),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_upward_rounded,
                                        size: 13,
                                        color: AppColors.income,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Masuk',
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.7),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          _buildSmoothValueSwitcher(
                                            value: isHidden ? '••••' : CurrencyFormatter.formatCompact(monthIncome),
                                            keyPrefix: 'income_$isHidden',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              Container(
                                width: 1,
                                height: 24,
                                color: Colors.white.withValues(alpha: 0.2),
                              ),
                              const SizedBox(width: 12),

                              // Pengeluaran
                              Expanded(
                                child: Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: AppColors.coral.withValues(alpha: 0.25),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.arrow_downward_rounded,
                                        size: 13,
                                        color: AppColors.coral,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Keluar',
                                            style: TextStyle(
                                              color: Colors.white.withValues(alpha: 0.7),
                                              fontSize: 10,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                          _buildSmoothValueSwitcher(
                                            value: isHidden ? '••••' : CurrencyFormatter.formatCompact(monthExpense),
                                            keyPrefix: 'expense_$isHidden',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 12.5,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmoothValueSwitcher({
    required String value,
    required TextStyle style,
    String? keyPrefix,
    TextOverflow? overflow,
  }) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      alignment: Alignment.centerLeft,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        layoutBuilder: (Widget? currentChild, List<Widget> previousChildren) {
          return Stack(
            alignment: Alignment.centerLeft,
            children: <Widget>[
              ...previousChildren,
              ?currentChild,
            ],
          );
        },
        transitionBuilder: (Widget child, Animation<double> animation) {
          final curved = CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          );
          return FadeTransition(
            opacity: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.94, end: 1.0).animate(curved),
              alignment: Alignment.centerLeft,
              child: child,
            ),
          );
        },
        child: Text(
          value,
          key: ValueKey<String>('${keyPrefix ?? ""}_$value'),
          style: style,
          overflow: overflow,
        ),
      ),
    );
  }
}

/// CustomPainter untuk menggambar pemandangan gunung & rute grafik finansial
class _MountainLandscapePainter extends CustomPainter {
  final bool isDark;

  const _MountainLandscapePainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // 1. Langit Sunset
    final skyPaint = Paint()
      ..shader = (isDark ? AppColors.mountainSkyDark : AppColors.mountainSkyLight).createShader(
        Rect.fromLTWH(0, 0, w, h),
      );
    canvas.drawRect(Rect.fromLTWH(0, 0, w, h), skyPaint);

    // Matahari lembut / Sunset glow di horizon
    final sunGlowPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          (isDark ? const Color(0xFFFF9E8A) : const Color(0xFFFFC5B5)).withValues(alpha: 0.55),
          Colors.transparent,
        ],
      ).createShader(Rect.fromCircle(center: Offset(w * 0.45, h * 0.35), radius: w * 0.45));
    canvas.drawCircle(Offset(w * 0.45, h * 0.35), w * 0.45, sunGlowPaint);

    // 2. Lapisan Gunung 1 (Paling Jauh / Hazy Ridges)
    final ridgeFarPaint = Paint()
      ..color = (isDark ? const Color(0xFF5D6DA6) : const Color(0xFFBAC7ED)).withValues(alpha: 0.7);
    final ridgeFarPath = Path()
      ..moveTo(0, h * 0.55)
      ..lineTo(w * 0.18, h * 0.40)
      ..lineTo(w * 0.35, h * 0.48)
      ..lineTo(w * 0.52, h * 0.36)
      ..lineTo(w * 0.72, h * 0.47)
      ..lineTo(w * 0.88, h * 0.34)
      ..lineTo(w, h * 0.44)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(ridgeFarPath, ridgeFarPaint);

    // 3. Lapisan Gunung 2 (Mid Mountain Ridge)
    final ridgeMidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: isDark
            ? [const Color(0xFF3B4E8C), const Color(0xFF223063)]
            : [const Color(0xFF7E9CE2), const Color(0xFF5171C2)],
      ).createShader(Rect.fromLTWH(0, h * 0.35, w, h * 0.65));

    final ridgeMidPath = Path()
      ..moveTo(0, h * 0.50)
      ..lineTo(w * 0.14, h * 0.36)
      ..lineTo(w * 0.32, h * 0.54)
      ..lineTo(w * 0.60, h * 0.38)
      ..lineTo(w * 0.82, h * 0.52)
      ..lineTo(w, h * 0.37)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(ridgeMidPath, ridgeMidPaint);

    // 4. Lapisan Gunung Dekat (Foreground Rugged Slopes)
    // Sisi Kiri
    final ridgeLeftPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: isDark
            ? [const Color(0xFF2A3D78), const Color(0xFF131E44)]
            : [const Color(0xFF4769BA), const Color(0xFF29468E)],
      ).createShader(Rect.fromLTWH(0, h * 0.45, w * 0.55, h * 0.55));

    final ridgeLeftPath = Path()
      ..moveTo(0, h * 0.38)
      ..lineTo(w * 0.28, h * 0.62)
      ..lineTo(w * 0.40, h * 0.75)
      ..lineTo(w * 0.30, h)
      ..lineTo(0, h)
      ..close();
    canvas.drawPath(ridgeLeftPath, ridgeLeftPaint);

    // Sisi Kanan (Puncak Tinggi)
    final ridgeRightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topRight,
        end: Alignment.bottomLeft,
        colors: isDark
            ? [const Color(0xFF2E4382), const Color(0xFF141F48)]
            : [const Color(0xFF4C70C4), const Color(0xFF27438B)],
      ).createShader(Rect.fromLTWH(w * 0.45, h * 0.35, w * 0.55, h * 0.65));

    final ridgeRightPath = Path()
      ..moveTo(w, h * 0.30)
      ..lineTo(w * 0.78, h * 0.48)
      ..lineTo(w * 0.65, h * 0.68)
      ..lineTo(w * 0.52, h * 0.82)
      ..lineTo(w * 0.70, h)
      ..lineTo(w, h)
      ..close();
    canvas.drawPath(ridgeRightPath, ridgeRightPaint);

    // 5. Sungai / Lembah Air (Winding River di tengah)
    final riverPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          (isDark ? const Color(0xFF88D2EC) : const Color(0xFFB3E7F8)).withValues(alpha: 0.6),
          isDark ? const Color(0xFF4791B3) : const Color(0xFF67B7D8),
        ],
      ).createShader(Rect.fromLTWH(w * 0.32, h * 0.68, w * 0.35, h * 0.32));

    final riverPath = Path()
      ..moveTo(w * 0.44, h * 0.72)
      ..quadraticBezierTo(w * 0.42, h * 0.78, w * 0.46, h * 0.83)
      ..quadraticBezierTo(w * 0.52, h * 0.88, w * 0.40, h)
      ..lineTo(w * 0.62, h)
      ..quadraticBezierTo(w * 0.60, h * 0.86, w * 0.54, h * 0.81)
      ..quadraticBezierTo(w * 0.48, h * 0.76, w * 0.48, h * 0.72)
      ..close();
    canvas.drawPath(riverPath, riverPaint);

    // 6. Siluet Hutan Pinus di Kaki Gunung
    _drawPineForest(canvas, Offset(w * 0.08, h * 0.65), 18, isDark);
    _drawPineForest(canvas, Offset(w * 0.15, h * 0.70), 16, isDark);
    _drawPineForest(canvas, Offset(w * 0.22, h * 0.74), 14, isDark);
    _drawPineForest(canvas, Offset(w * 0.72, h * 0.75), 18, isDark);
    _drawPineForest(canvas, Offset(w * 0.80, h * 0.71), 22, isDark);
    _drawPineForest(canvas, Offset(w * 0.88, h * 0.66), 26, isDark);

    // 7. Garis Grafik Rute Finansial (Financial Trajectory Node Graph)
    // Tepat seperti di gambar: garis coral dengan node-node bulat (S, 3, 4, 5)
    final trajectoryPoints = [
      Offset(w * 0.14, h * 0.24), // Node 1: Start (S)
      Offset(w * 0.24, h * 0.32),
      Offset(w * 0.40, h * 0.42), // Node 2: Milestone 3
      Offset(w * 0.55, h * 0.36),
      Offset(w * 0.74, h * 0.28),
      Offset(w * 0.86, h * 0.35), // Node 3: Target (5)
    ];

    // Gambar Garis Sambungan Melengkung Halus
    final linePath = Path()..moveTo(trajectoryPoints[0].dx, trajectoryPoints[0].dy);
    for (int i = 0; i < trajectoryPoints.length - 1; i++) {
      final p0 = trajectoryPoints[i];
      final p1 = trajectoryPoints[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      linePath.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }

    // Glow pada garis
    final lineGlowPaint = Paint()
      ..color = AppColors.coral.withValues(alpha: 0.35)
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, lineGlowPaint);

    final linePaint = Paint()
      ..color = AppColors.coral
      ..strokeWidth = 2.2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(linePath, linePaint);

    // Titik-titik node kecil di garis
    final dotPaint = Paint()..color = Colors.white;
    for (final pt in [trajectoryPoints[1], trajectoryPoints[3], trajectoryPoints[4]]) {
      canvas.drawCircle(pt, 3.5, dotPaint);
      canvas.drawCircle(pt, 2, Paint()..color = AppColors.coral);
    }

    // 8. Badge Node Utama (S, 3, 5) seperti di gambar
    _drawNodeBadge(canvas, trajectoryPoints[0], 'S', const Color(0xFF6A7CB5), Colors.white);
    _drawNodeBadge(canvas, trajectoryPoints[2], '3', AppColors.coral, Colors.white);
    _drawNodeBadge(canvas, trajectoryPoints[5], '5', AppColors.coral, Colors.white);
  }

  void _drawNodeBadge(Canvas canvas, Offset center, String text, Color bg, Color fg) {
    const radius = 11.5;
    // Shadow
    canvas.drawCircle(
      center.translate(0, 2),
      radius,
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );
    // Outer circle
    canvas.drawCircle(center, radius, Paint()..color = bg);
    // Inner border
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Text
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: fg,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(canvas, center.translate(-tp.width / 2, -tp.height / 2));
  }

  void _drawPineForest(Canvas canvas, Offset base, double height, bool isDark) {
    final pinePaint = Paint()
      ..color = (isDark ? const Color(0xFF102738) : const Color(0xFF1B404E)).withValues(alpha: 0.85);

    final w = height * 0.48;
    final path = Path()
      ..moveTo(base.dx, base.dy - height)
      ..lineTo(base.dx + w * 0.5, base.dy - height * 0.55)
      ..lineTo(base.dx + w * 0.35, base.dy - height * 0.55)
      ..lineTo(base.dx + w * 0.7, base.dy)
      ..lineTo(base.dx - w * 0.7, base.dy)
      ..lineTo(base.dx - w * 0.35, base.dy - height * 0.55)
      ..lineTo(base.dx - w * 0.5, base.dy - height * 0.55)
      ..close();

    canvas.drawPath(path, pinePaint);
  }

  @override
  bool shouldRepaint(covariant _MountainLandscapePainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}

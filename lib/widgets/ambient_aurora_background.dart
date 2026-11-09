import 'package:flutter/material.dart';

/// Widget latar belakang dinamis bertema "Aurora Ambient Mesh Glow"
/// Menghadirkan pendaran cahaya orbs warna-warni (sunset coral, aqua cyan, lavender violet, dan rose)
/// yang membuat latar belakang kaya nuansa, artistik, dan tidak polos.
class AmbientAuroraBackground extends StatelessWidget {
  final Widget child;
  final bool isDark;

  const AmbientAuroraBackground({
    super.key,
    required this.child,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // 1. Lapisan Kanvas Aurora Mesh (diisolasi dengan RepaintBoundary agar GPU tidak re-paint saat scroll)
        Positioned.fill(
          child: RepaintBoundary(
            child: CustomPaint(
              painter: _AuroraMeshPainter(isDark: isDark),
            ),
          ),
        ),

        // 2. Konten aplikasi
        child,
      ],
    );
  }
}

class _AuroraMeshPainter extends CustomPainter {
  final bool isDark;

  _AuroraMeshPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;

    if (isDark) {
      _paintDarkAurora(canvas, size, rect);
    } else {
      _paintLightAurora(canvas, size, rect);
    }
  }

  void _paintLightAurora(Canvas canvas, Size size, Rect rect) {
    // A. Base gradient lembut
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFFFFF2EB), // Sunset warm peach di atas
          Color(0xFFF4F6FC), // Netral sejuk di tengah
          Color(0xFFE9F0FA), // Nordic ice di bawah
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    // B. Orb 1: Sunset Coral & Peach Glow di kanan atas (sekitar Hero Card & AppBar)
    _drawGlowOrb(
      canvas: canvas,
      center: Offset(size.width * 0.88, size.height * 0.08),
      radius: size.width * 0.65,
      colors: [
        const Color(0xFFFF7A59).withValues(alpha: 0.36),
        const Color(0xFFFFB099).withValues(alpha: 0.18),
        Colors.transparent,
      ],
    );

    // C. Orb 2: Warm Sunrise Amber di kiri atas
    _drawGlowOrb(
      canvas: canvas,
      center: Offset(size.width * 0.05, size.height * 0.18),
      radius: size.width * 0.50,
      colors: [
        const Color(0xFFFFC107).withValues(alpha: 0.22),
        const Color(0xFFFFE082).withValues(alpha: 0.08),
        Colors.transparent,
      ],
    );

    // D. Orb 3: Ocean Aqua / Cyan Glow di tengah kiri (di balik tombol aksi cepat & transaksi)
    _drawGlowOrb(
      canvas: canvas,
      center: Offset(size.width * 0.08, size.height * 0.48),
      radius: size.width * 0.70,
      colors: [
        const Color(0xFF00B4D8).withValues(alpha: 0.28),
        const Color(0xFF90E0EF).withValues(alpha: 0.14),
        Colors.transparent,
      ],
    );

    // E. Orb 4: Twilight Lavender / Violet Glow di tengah kanan
    _drawGlowOrb(
      canvas: canvas,
      center: Offset(size.width * 0.95, size.height * 0.64),
      radius: size.width * 0.72,
      colors: [
        const Color(0xFF8B5CF6).withValues(alpha: 0.26),
        const Color(0xFFC4B5FD).withValues(alpha: 0.12),
        Colors.transparent,
      ],
    );

    // F. Orb 5: Rose & Coral Glow di kiri bawah (di sekitar floating navbar)
    _drawGlowOrb(
      canvas: canvas,
      center: Offset(size.width * 0.25, size.height * 0.92),
      radius: size.width * 0.60,
      colors: [
        const Color(0xFFEC4899).withValues(alpha: 0.20),
        const Color(0xFFFBCFE8).withValues(alpha: 0.08),
        Colors.transparent,
      ],
    );
  }

  void _paintDarkAurora(Canvas canvas, Size size, Rect rect) {
    // A. Base dark navy pekat
    final basePaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color(0xFF0E1530),
          Color(0xFF080D20),
          Color(0xFF040714),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, basePaint);

    // B. Orb 1: Deep Sunset Coral di kanan atas
    _drawGlowOrb(
      canvas: canvas,
      center: Offset(size.width * 0.85, size.height * 0.08),
      radius: size.width * 0.70,
      colors: [
        const Color(0xFFFF5722).withValues(alpha: 0.30),
        const Color(0xFFE64A19).withValues(alpha: 0.12),
        Colors.transparent,
      ],
    );

    // C. Orb 2: Deep Indigo di tengah kiri
    _drawGlowOrb(
      canvas: canvas,
      center: Offset(size.width * 0.10, size.height * 0.44),
      radius: size.width * 0.75,
      colors: [
        const Color(0xFF4F46E5).withValues(alpha: 0.32),
        const Color(0xFF3730A3).withValues(alpha: 0.14),
        Colors.transparent,
      ],
    );

    // D. Orb 3: Electric Violet di kanan bawah
    _drawGlowOrb(
      canvas: canvas,
      center: Offset(size.width * 0.90, size.height * 0.68),
      radius: size.width * 0.70,
      colors: [
        const Color(0xFF7C3AED).withValues(alpha: 0.28),
        const Color(0xFF5B21B6).withValues(alpha: 0.12),
        Colors.transparent,
      ],
    );

    // E. Orb 4: Twilight Cyan di kiri bawah
    _drawGlowOrb(
      canvas: canvas,
      center: Offset(size.width * 0.20, size.height * 0.92),
      radius: size.width * 0.65,
      colors: [
        const Color(0xFF06B6D4).withValues(alpha: 0.24),
        Colors.transparent,
      ],
    );
  }

  void _drawGlowOrb({
    required Canvas canvas,
    required Offset center,
    required double radius,
    required List<Color> colors,
  }) {
    final orbRect = Rect.fromCircle(center: center, radius: radius);
    final paint = Paint()
      ..shader = RadialGradient(
        colors: colors,
        stops: colors.length == 3 ? const [0.0, 0.48, 1.0] : const [0.0, 1.0],
      ).createShader(orbRect);

    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant _AuroraMeshPainter oldDelegate) {
    return oldDelegate.isDark != isDark;
  }
}

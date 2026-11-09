import 'package:flutter/material.dart';

/// Palet warna & gradien estetis terinspirasi dari desain Mountain Sunset & Twilight Glassmorphism
class AppColors {
  // Palet Utama & Gradien Alam
  static const Color abyss = Color(0xFF090F24);
  static const Color deepNavy = Color(0xFF0E1A42);
  static const Color twilightIndigo = Color(0xFF162354);
  static const Color twilightSurface = Color(0xFF1F2E64);
  static const Color steelBlue = Color(0xFF5483B3);
  static const Color softBlue = Color(0xFF7DA0CA);
  static const Color iceBlue = Color(0xFFC1E8FF);

  // Aksen Sunset & Coral (dari node grafik & badge di gambar)
  static const Color coral = Color(0xFFFF6F59);
  static const Color coralLight = Color(0xFFFF907E);
  static const Color coralGlow = Color(0x40FF6F59);
  static const Color peachSunset = Color(0xFFFFCEBA);
  static const Color sunWarmth = Color(0xFFFFE0D4);

  // Lapisan Gunung & Alam (untuk lukisan lanskap vektor)
  static const Color skyPeach = Color(0xFFFFD4C8);
  static const Color skyLavender = Color(0xFFDECBDF);
  static const Color mountainRidgeFar = Color(0xFFA1B4EB);
  static const Color mountainRidgeMid = Color(0xFF6785D4);
  static const Color mountainRidgeNear = Color(0xFF3B5CA8);
  static const Color river = Color(0xFF68B6D6);
  static const Color pineForest = Color(0xFF153B4B);

  // Varian Terang (Light Mode - Fresh Morning Mountain Glow)
  static const Color scaffoldLight = Color(0xFFF0F4FA); // Soft Nordic Ice
  static const Color cardLight = Colors.white;
  static const Color cardLightSoft = Color(0xFFFAFCFF);
  static const Color borderLight = Color(0xFFE4EDF7);
  static const Color textPrimaryLight = Color(0xFF101C42);
  static const Color textSecondaryLight = Color(0xFF64789F);

  // Varian Gelap (Dark Mode - Twilight Mountain Glassmorphism)
  static const Color scaffoldDark = Color(0xFF0D142E);
  static const Color cardDark = Color(0xFF1A2652);
  static const Color cardDarkGlass = Color(0xFF1D2A5A);
  static const Color cardDarkElevated = Color(0xFF24336B);
  static const Color borderDark = Color(0xFF354884);
  static const Color borderDarkGlass = Color(0xFF4C63AA);
  static const Color textPrimaryDark = Colors.white;
  static const Color textSecondaryDark = Color(0xFF9BB1DC);

  // Warna Semantik Finansial
  static const Color income = Color(0xFF10B981);   // Emerald Green
  static const Color expense = Color(0xFFFF6F59);  // Sunset Coral Red
  static const Color warning = Color(0xFFF59E0B);  // Amber
  static const Color transfer = Color(0xFF5B7ED9); // Indigo Blue

  // Gradien Estetis
  static const LinearGradient twilightSkyGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [
      Color(0xFFFFB39F), // Sunset Glow di kanan atas
      Color(0xFF869AD6),
      Color(0xFF223168),
      Color(0xFF0D142E),
    ],
    stops: [0.0, 0.28, 0.65, 1.0],
  );

  static const LinearGradient mountainSkyLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFE1D6),
      Color(0xFFF9D2C8),
      Color(0xFFDCE4F8),
      Color(0xFFABC0F0),
    ],
  );

  static const LinearGradient mountainSkyDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFAC99),
      Color(0xFF8F93CA),
      Color(0xFF43589B),
      Color(0xFF1C2856),
    ],
  );

  static const LinearGradient cardGlassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF2E3F78),
      Color(0xFF1E2B57),
    ],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF1F2F68),
      Color(0xFF121C42),
      Color(0xFF090E26),
    ],
  );

  static const LinearGradient coralPillGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFFF8975),
      Color(0xFFFF5D43),
    ],
  );

  static const LinearGradient icePillGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFFE6F3FD),
      Color(0xFFC4E6FC),
    ],
  );

  // Subtle Twilight Mesh Gradient (Semburat Peach Hangat di atas ke Nordic Ice Sejuk di bawah)
  static const LinearGradient twilightMeshLight = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFFFFEDE6), // Sunset warm peach blush di bagian atas
      Color(0xFFF7F4F7), // Transisi lembut netral
      Color(0xFFEFF4FB), // Nordic ice sejuk di bagian bawah
    ],
    stops: [0.0, 0.32, 1.0],
  );

  static const LinearGradient twilightMeshDark = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF192246), // Deep twilight indigo
      Color(0xFF111936),
      Color(0xFF090E22), // Deep midnight abyss
    ],
    stops: [0.0, 0.40, 1.0],
  );
}

// config/theme_config.dart - COULEURS SOMBRES ET ÉLÉGANTES 🎨
import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 VOS COULEURS EXACTES (plus sombres et élégantes)
  static const Color zaffre = Color(0xFF2C1DA6);        // Bleu foncé
  static const Color mauveine = Color(0xFF8D369F);      // Violet/rose
  static const Color tekhelet1 = Color(0xFF5528A4);     // Violet foncé
  static const Color tekhelet2 = Color(0xFF4A24A7);     // Violet foncé
  static const Color zaffreDark = Color(0xFF3D22A7);    // Bleu violet foncé
  
  // Couleurs neutres élégantes
  static const Color darkBackground = Color(0xFF1A1A2E);
  static const Color cardBackground = Color(0xFFF8F9FA);
  static const Color textDark = Color(0xFF2D3436);
  static const Color textLight = Color(0xFF636E72);
  static const Color textGray = Color(0xFFB2BEC3);
  
  // 🌙 GRADIENTS SOMBRES ET ÉLÉGANTS
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [zaffre, mauveine],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF8F9FA)],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tekhelet1, zaffreDark],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tekhelet2, mauveine],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [zaffreDark, tekhelet1],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mauveine, tekhelet2],
    stops: [0.0, 1.0],
  );
  
  // 📱 STYLES DE TEXTE ÉLÉGANTS
  static const TextStyle heading1 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w700,
    color: textDark,
  );
  
  static const TextStyle heading2 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textDark,
  );
  
  static const TextStyle heading3 = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textDark,
  );
  
  static const TextStyle bodyText = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textLight,
  );
  
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  // 🎭 OMBRES SUBTILES
  static List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];
  
  static List<BoxShadow> buttonShadow = [
    BoxShadow(
      color: zaffre.withOpacity(0.25),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  // 📦 DÉCORATION DE CONTENEUR ÉLÉGANTE
  static BoxDecoration get cardDecoration => BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(16),
    boxShadow: cardShadow,
  );
  
  static BoxDecoration get primaryButtonDecoration => BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(14),
    boxShadow: buttonShadow,
  );
}
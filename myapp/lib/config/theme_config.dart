// config/theme_config.dart - STYLE INCROYABLE & MODERNE 🚀✨
import 'package:flutter/material.dart';

class AppTheme {
  // 🎨 COULEURS PRINCIPALES (vos couleurs + améliorations)
  static const Color zaffre = Color(0xFF2C1DA6);        // Bleu foncé principal
  static const Color mauveine = Color(0xFF8D369F);      // Violet/rose accent
  static const Color tekhelet1 = Color(0xFF5528A4);     // Violet foncé
  static const Color tekhelet2 = Color(0xFF4A24A7);     // Violet profond
  static const Color zaffreDark = Color(0xFF3D22A7);    // Bleu violet foncé
  
  // 🌟 NOUVELLES COULEURS COMPLÉMENTAIRES
  static const Color neonBlue = Color(0xFF00D2FF);      // Bleu néon moderne
  static const Color electricPurple = Color(0xFF6C5CE7); // Violet électrique
  static const Color deepSpace = Color(0xFF0D1117);     // Noir spatial
  static const Color cosmicGray = Color(0xFF21262D);    // Gris cosmique
  static const Color starDust = Color(0xFF8B949E);      // Poussière d'étoile
  
  // 🎭 COULEURS NEUTRES SOPHISTIQUÉES
  static const Color darkBackground = Color(0xFF0A0A0F);
  static const Color cardBackground = Color(0xFFFBFCFD);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF161B22);
  static const Color textPrimary = Color(0xFF0D1117);
  static const Color textSecondary = Color(0xFF656D76);
  static const Color textTertiary = Color(0xFF8B949E);
  static const Color accent = Color(0xFFFF6B6B);        // Rouge accent
  static const Color success = Color(0xFF00B894);       // Vert succès
  static const Color warning = Color(0xFFFFCB47);       // Jaune warning
  
  // 🌌 GRADIENTS SPECTACULAIRES
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [zaffre, mauveine, tekhelet1],
    stops: [0.0, 0.6, 1.0],
  );
  
  static const LinearGradient neonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [neonBlue, electricPurple, mauveine],
    stops: [0.0, 0.5, 1.0],
  );
  
  static const LinearGradient cosmicGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [deepSpace, cosmicGray, Color(0xFF30363D)],
    stops: [0.0, 0.3, 1.0],
  );
  
  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFFFFFF), Color(0xFFF6F8FA)],
    stops: [0.0, 1.0],
  );
  
  static const LinearGradient glassGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0x20FFFFFF),
      Color(0x10FFFFFF),
    ],
  );
  
  // 🎨 GRADIENTS COLORÉS DYNAMIQUES
  static const LinearGradient blueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
  );
  
  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [tekhelet2, mauveine],
  );
  
  static const LinearGradient darkGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [deepSpace, cosmicGray],
  );
  
  static const LinearGradient lightGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFa8edea), Color(0xFFfed6e3)],
  );
  
  static const LinearGradient sunsetGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF9A9E), Color(0xFFFAD0C4)],
  );
  
  static const LinearGradient oceanGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF667eea), Color(0xFF764ba2)],
  );
  
  // ✨ STYLES DE TEXTE MODERNES
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w800,
    color: textPrimary,
    letterSpacing: -0.5,
    height: 1.2,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.3,
    height: 1.3,
  );
  
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w700,
    color: textPrimary,
    letterSpacing: -0.2,
    height: 1.3,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: -0.1,
    height: 1.4,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.6,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.6,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    height: 1.5,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    letterSpacing: 0.1,
  );
  
  static const TextStyle buttonTextLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: Colors.white,
    letterSpacing: 0.2,
  );
  
  static const TextStyle buttonTextMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.white,
    letterSpacing: 0.1,
  );
  
  // 🎭 OMBRES SOPHISTIQUÉES
  static List<BoxShadow> get elevationLow => [
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get elevationMedium => [
    BoxShadow(
      color: Colors.black.withOpacity(0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> get elevationHigh => [
    BoxShadow(
      color: Colors.black.withOpacity(0.12),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: Colors.black.withOpacity(0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get glowShadow => [
    BoxShadow(
      color: zaffre.withOpacity(0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: mauveine.withOpacity(0.2),
      blurRadius: 40,
      offset: const Offset(0, 16),
    ),
  ];
  
  static List<BoxShadow> get neonShadow => [
    BoxShadow(
      color: neonBlue.withOpacity(0.4),
      blurRadius: 16,
      offset: const Offset(0, 0),
    ),
    BoxShadow(
      color: electricPurple.withOpacity(0.3),
      blurRadius: 32,
      offset: const Offset(0, 8),
    ),
  ];
  
  // 📦 DÉCORATIONS MODERNES
  static BoxDecoration get glassMorphism => BoxDecoration(
    gradient: glassGradient,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.white.withOpacity(0.2),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.1),
        blurRadius: 20,
        offset: const Offset(0, 8),
      ),
    ],
  );
  
  static BoxDecoration get neuMorphism => BoxDecoration(
    color: const Color(0xFFF0F0F3),
    borderRadius: BorderRadius.circular(20),
    boxShadow: [
      const BoxShadow(
        color: Color(0xFFFFFFFF),
        offset: Offset(-8, -8),
        blurRadius: 15,
      ),
      BoxShadow(
        color: const Color(0xFFD1D9E6).withOpacity(0.6),
        offset: const Offset(8, 8),
        blurRadius: 15,
      ),
    ],
  );
  
  static BoxDecoration get cardModern => BoxDecoration(
    gradient: cardGradient,
    borderRadius: BorderRadius.circular(20),
    border: Border.all(
      color: Colors.grey.withOpacity(0.1),
      width: 1,
    ),
    boxShadow: elevationMedium,
  );
  
  static BoxDecoration get buttonPrimary => BoxDecoration(
    gradient: primaryGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: glowShadow,
  );
  
  static BoxDecoration get buttonNeon => BoxDecoration(
    gradient: neonGradient,
    borderRadius: BorderRadius.circular(16),
    boxShadow: neonShadow,
  );
  
  static BoxDecoration get cardProduct => BoxDecoration(
    color: surfaceLight,
    borderRadius: BorderRadius.circular(16),
    border: Border.all(
      color: Colors.grey.withOpacity(0.1),
      width: 1,
    ),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withOpacity(0.06),
        blurRadius: 12,
        offset: const Offset(0, 4),
      ),
    ],
  );
  
  // 🎯 RAYON DE BORDURE
  static const double radiusSmall = 8.0;
  static const double radiusMedium = 12.0;
  static const double radiusLarge = 16.0;
  static const double radiusXLarge = 20.0;
  static const double radiusXXLarge = 24.0;
  
  // 📐 ESPACEMENT
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;
  
  // 🎪 ANIMATIONS
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
  
  static const Curve animationCurve = Curves.easeInOutCubic;
  static const Curve animationBouncyCurve = Curves.elasticOut;
  
  // 🌈 COULEURS ÉTATS
  static const Color stateHover = Color(0x08000000);
  static const Color statePressed = Color(0x12000000);
  static const Color stateFocus = Color(0x1F000000);
  static const Color stateDisabled = Color(0x38000000);
  
  // 📱 BREAKPOINTS RESPONSIVE
  static const double mobileBreakpoint = 600;
  static const double tabletBreakpoint = 1024;
  static const double desktopBreakpoint = 1440;
  
  // 🎨 MÉTHODES UTILITAIRES
  static Color withOpacity(Color color, double opacity) {
    return color.withOpacity(opacity);
  }
  
  static LinearGradient customGradient(List<Color> colors, {
    AlignmentGeometry begin = Alignment.topLeft,
    AlignmentGeometry end = Alignment.bottomRight,
    List<double>? stops,
  }) {
    return LinearGradient(
      begin: begin,
      end: end,
      colors: colors,
      stops: stops,
    );
  }
  
  static BoxDecoration customCard({
    Color? color,
    LinearGradient? gradient,
    double radius = radiusLarge,
    List<BoxShadow>? shadows,
    Border? border,
  }) {
    return BoxDecoration(
      color: color,
      gradient: gradient ?? cardGradient,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: shadows ?? elevationMedium,
      border: border,
    );
  }
  
  // 🎭 THÈME SOMBRE/CLAIR
  static bool _isDarkMode = false;
  
  static bool get isDarkMode => _isDarkMode;
  
  static void toggleTheme() {
    _isDarkMode = !_isDarkMode;
  }
  
  static Color get adaptiveBackground => 
    _isDarkMode ? darkBackground : surfaceLight;
  
  static Color get adaptiveText => 
    _isDarkMode ? Colors.white : textPrimary;
  
  static Color get adaptiveCard => 
    _isDarkMode ? surfaceDark : surfaceLight;
}
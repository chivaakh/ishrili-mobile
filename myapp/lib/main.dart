// main.dart - VERSION DIRECTE DASHBOARD 🌙
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'screens/splash_screen.dart';
import 'config/theme_config.dart';
import 'providers/product_provider.dart';
import 'providers/vendor_provider.dart';
import 'providers/category_provider.dart';
import 'providers/order_provider.dart';
import 'providers/auth_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/vendor/vendor_main_screen.dart';

// Services
import 'services/api_client.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ApiClient.init(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Configuration de la barre de statut élégante
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        systemNavigationBarColor: Colors.white,
        systemNavigationBarIconBrightness: Brightness.dark,
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkLogin()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'Ishrili Vendeur',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          // 🎨 Thème élégant avec vos couleurs
          primarySwatch: _createMaterialColor(AppTheme.zaffre),
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppTheme.zaffre,
            brightness: Brightness.light,
          ),
          
          // 📱 Configuration générale
          useMaterial3: true,
          fontFamily: 'SF Pro Display',
          
          // 🎭 AppBar Theme élégant
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            elevation: 0,
            systemOverlayStyle: SystemUiOverlayStyle.dark,
            titleTextStyle: TextStyle(
              color: AppTheme.textPrimary,  // ✅ Corrigé: textDark → textPrimary
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            iconTheme: IconThemeData(
              color: AppTheme.textPrimary,  // ✅ Corrigé: textDark → textPrimary
              size: 22,
            ),
          ),
          
          // 🔘 Button Themes élégants
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.zaffre,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          
          // 📄 Card Theme élégant
          cardTheme: CardTheme(
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            color: Colors.white,
            shadowColor: Colors.black.withOpacity(0.06),
          ),
          
          // ✏️ Input Decoration Theme élégant
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(color: Colors.grey[200]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.zaffre, width: 1.5),
            ),
            contentPadding: const EdgeInsets.all(18),
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          ),
          
          // 📊 Bottom Navigation Theme élégant
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Colors.white,
            selectedItemColor: AppTheme.zaffre,
            unselectedItemColor: AppTheme.textSecondary,  // ✅ Corrigé: textLight → textSecondary
            elevation: 0,
            type: BottomNavigationBarType.fixed,
          ),
          
          // 🎨 SnackBar Theme élégant
          snackBarTheme: SnackBarThemeData(
            backgroundColor: AppTheme.zaffre,
            contentTextStyle: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            behavior: SnackBarBehavior.floating,
          ),
        ),
        
        // ✅ NAVIGATION DIRECTE VERS LE DASHBOARD
        // Cette modification affiche directement le VendorMainScreen
        // qui contient votre dashboard vendeur
        home: const VendorMainScreen(),
        
        // ✅ Routes pour navigation future
        routes: {
          '/login': (context) => LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/forgot-password': (context) => ForgotPasswordScreen(),
          '/reset-password': (context) {
            final token = ModalRoute.of(context)!.settings.arguments as String;
            return ResetPasswordScreen(token: token);
          },
          '/vendor': (context) => const VendorMainScreen(),
          '/splash': (context) => const SplashScreen(),
        },
      ),
    );
  }
  
  // Fonction helper pour créer MaterialColor
  MaterialColor _createMaterialColor(Color color) {
    List strengths = <double>[.05];
    Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    
    return MaterialColor(color.value, swatch);
  }
}
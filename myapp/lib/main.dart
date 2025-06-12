// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Initialise ton client HTTP et cookie persistence
import 'services/api_client.dart';

// Providers
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'config/api_config.dart';
import 'providers/product_provider.dart';
import 'providers/vendor_provider.dart';
import 'providers/auth_provider.dart';

// Screens
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/auth/forgot_password_screen.dart';
import 'screens/auth/reset_password_screen.dart';
import 'screens/vendor/vendor_main_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Si tu utilises PersistCookieJar, appelle ton init ici :
  await ApiClient.init(); 
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..checkLogin()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
      ],
      child: Consumer<AuthProvider>(
        builder: (ctx, auth, _) => MaterialApp(
          title: 'Ishrili Vendeur',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E90FF)),
            useMaterial3: true,
            fontFamily: 'Poppins',
          ),
          debugShowCheckedModeBanner: false,
          
          // Selon l’état de connexion, on choisit l’écran de départ
          initialRoute: auth.loggedIn ? '/vendor' : '/login',
          
          routes: {
            '/login': (c) => LoginScreen(),
            '/signup': (c) => SignupScreen(),
            '/forgot-password': (c) => ForgotPasswordScreen(),
            '/reset-password': (c) {
              final token = ModalRoute.of(c)!.settings.arguments as String;
              return ResetPasswordScreen(token: token);
            },
            '/vendor': (c) => const VendorMainScreen(),
          },
        ),
      ),
    );
  }
}

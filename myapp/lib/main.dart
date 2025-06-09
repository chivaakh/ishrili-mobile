// main.dart - Remplacez votre main.dart par ceci
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/api_config.dart';
import 'screens/vendor/vendor_main_screen.dart';
import 'providers/product_provider.dart';
import 'providers/vendor_provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => VendorProvider()),
      ],
      child: MaterialApp(
        title: 'Ishrili Vendeur',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1E90FF)),
          useMaterial3: true,
          fontFamily: 'Poppins',
        ),
        home: const VendorMainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

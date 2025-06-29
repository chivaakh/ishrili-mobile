// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext ctx) {
    return Scaffold(
      appBar: AppBar(title: Text('Accueil')),
      body: Center(child: Text('Bienvenue !')),
      drawer: Drawer(
        child: ListView(
          children: [
            ListTile(
              title: Text('Déconnexion'),
              onTap: () {
                AuthService().logout().then((_) {
                  Navigator.pushReplacementNamed(ctx, '/login');
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

// screens/vendor/dashboard_screen.dart - Créez ce fichier
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vendor_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Dashboard Vendeur',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1E90FF),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Consumer<VendorProvider>(
        builder: (context, vendor, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Salutation
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 30,
                          backgroundColor: Color(0xFF1E90FF),
                          child: Icon(Icons.store, color: Colors.white, size: 30),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Bonjour ! 👋',
                                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                'Voici votre activité du ${vendor.todayDate}',
                                style: TextStyle(color: Colors.grey[600]),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 20),
                
                // Statistiques principales
                const Text(
                  'Statistiques',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  children: [
                    _buildStatCard(
                      'Produits',
                      vendor.totalProducts.toString(),
                      Icons.inventory,
                      const Color(0xFF4CAF50),
                    ),
                    _buildStatCard(
                      'Commandes',
                      vendor.totalOrders.toString(),
                      Icons.shopping_cart,
                      const Color(0xFF2196F3),
                    ),
                    _buildStatCard(
                      'Chiffre d\'affaires',
                      '${vendor.totalRevenue.toStringAsFixed(0)} MRU',
                      Icons.attach_money,
                      const Color(0xFFFF9800),
                    ),
                    _buildStatCard(
                      'En attente',
                      vendor.pendingOrders.toString(),
                      Icons.pending_actions,
                      const Color(0xFFF44336),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Actions rapides
                const Text(
                  'Actions rapides',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Expanded(
                      child: _buildActionButton(
                        'Ajouter Produit',
                        Icons.add_box,
                        const Color(0xFF4CAF50),
                        () {
                          // TODO: Navigation vers ajout produit
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fonction à implémenter')),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildActionButton(
                        'Voir Commandes',
                        Icons.list_alt,
                        const Color(0xFF2196F3),
                        () {
                          // TODO: Navigation vers commandes
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Fonction à implémenter')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Activité récente
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Activité récente',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        _buildActivityItem(
                          'Nouvelle commande #CMD001',
                          'Il y a 2 heures',
                          Icons.shopping_cart,
                          const Color(0xFF4CAF50),
                        ),
                        _buildActivityItem(
                          'Produit iPhone 16 mis à jour',
                          'Il y a 5 heures',
                          Icons.edit,
                          const Color(0xFF2196F3),
                        ),
                        _buildActivityItem(
                          'Stock faible: Apple Product',
                          'Il y a 1 jour',
                          Icons.warning,
                          const Color(0xFFFF9800),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Text(
              title,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(String title, IconData icon, Color color, VoidCallback onTap) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 24),
          const SizedBox(height: 4),
          Text(title, textAlign: TextAlign.center),
        ],
      ),
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: color.withOpacity(0.2),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
                Text(time, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

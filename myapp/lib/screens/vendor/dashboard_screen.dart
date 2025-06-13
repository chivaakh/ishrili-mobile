// screens/vendor/dashboard_screen.dart - DESIGN SOMBRE ET ÉLÉGANT 🌙
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/vendor_provider.dart';
import '../../config/theme_config.dart';
import 'add_product_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8F9FA),
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Consumer<VendorProvider>(
            builder: (context, vendor, child) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 👋 Header élégant
                    _buildElegantHeader(),
                    
                    const SizedBox(height: 28),
                    
                    // 📊 Statistiques élégantes
                    _buildElegantStats(vendor),
                    
                    const SizedBox(height: 32),
                    
                    // ⚡ Actions rapides
                    _buildElegantActions(context),
                    
                    const SizedBox(height: 32),
                    
                    // 📈 Activité récente
                    _buildElegantActivity(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildElegantHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.zaffre.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bonjour ! 👋',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Voici votre activité d\'aujourd\'hui',
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.white.withOpacity(0.9),
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.notifications_outlined,
              color: Colors.white,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantStats(VendorProvider vendor) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aperçu rapide',
          style: AppTheme.heading2,
        ),
        const SizedBox(height: 18),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 14,
          mainAxisSpacing: 14,
          childAspectRatio: 1.15,
          children: [
            _buildElegantStatCard(
              'Produits',
              vendor.totalProducts.toString(),
              Icons.inventory_2_rounded,
              AppTheme.blueGradient,
            ),
            _buildElegantStatCard(
              'Commandes',
              vendor.totalOrders.toString(),
              Icons.shopping_bag_rounded,
              AppTheme.purpleGradient,
            ),
            _buildElegantStatCard(
              'Revenus',
              '${vendor.totalRevenue.toStringAsFixed(0)} MRU',
              Icons.trending_up_rounded,
              AppTheme.darkGradient,
            ),
            _buildElegantStatCard(
              'En attente',
              vendor.pendingOrders.toString(),
              Icons.pending_rounded,
              AppTheme.lightGradient,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildElegantStatCard(String title, String value, IconData icon, LinearGradient gradient) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: gradient.colors.first.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: Colors.white),
          ),
          const Spacer(),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildElegantActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Actions rapides',
          style: AppTheme.heading2,
        ),
        const SizedBox(height: 18),
        Row(
          children: [
            Expanded(
              child: _buildElegantActionButton(
                'Ajouter Produit',
                Icons.add_box_rounded,
                AppTheme.primaryGradient,
                () => _navigateToAddProduct(context),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: _buildElegantActionButton(
                'Voir Commandes',
                Icons.list_alt_rounded,
                AppTheme.blueGradient,
                () => _navigateToOrders(context),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildElegantActionButton(String title, IconData icon, LinearGradient gradient, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: gradient.colors.first.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, size: 24, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildElegantActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Activité récente',
          style: AppTheme.heading2,
        ),
        const SizedBox(height: 18),
        Container(
          decoration: AppTheme.cardDecoration,
          child: Column(
            children: [
              _buildActivityItem(
                'Nouvelle commande #CMD001',
                'Il y a 2 heures',
                Icons.shopping_cart_rounded,
                AppTheme.purpleGradient,
              ),
              _buildDivider(),
              _buildActivityItem(
                'Produit iPhone 16 mis à jour',
                'Il y a 5 heures',
                Icons.edit_rounded,
                AppTheme.blueGradient,
              ),
              _buildDivider(),
              _buildActivityItem(
                'Stock faible: Apple Product',
                'Il y a 1 jour',
                Icons.warning_rounded,
                AppTheme.darkGradient,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(String title, String time, IconData icon, LinearGradient gradient) {
    return Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Colors.grey[300],
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 18),
      height: 1,
      color: Colors.grey[100],
    );
  }

  void _navigateToAddProduct(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddProductScreen()),
    );
  }

  void _navigateToOrders(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Redirection vers les commandes'),
        backgroundColor: AppTheme.zaffre,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
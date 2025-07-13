// screens/vendor/todays_orders_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import 'order_detail_screen.dart';
import 'order_history_screen.dart';

class TodaysOrdersScreen extends StatefulWidget {
  const TodaysOrdersScreen({super.key});

  @override
  State<TodaysOrdersScreen> createState() => _TodaysOrdersScreenState();
}

class _TodaysOrdersScreenState extends State<TodaysOrdersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTodaysOrders();
    });
  }

  Future<void> _loadTodaysOrders() async {
    final orderProvider = context.read<OrderProvider>();
    await orderProvider.loadTodaysOrders();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black87, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Commandes d\'aujourd\'hui',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              _formatTodayDate(),
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadTodaysOrders,
          ),
        ],
      ),
      body: Consumer<OrderProvider>(
        builder: (context, orderProvider, child) {
          return Column(
            children: [
              // Statistiques du jour
              _buildTodayStats(orderProvider),
              
              // Liste des commandes
              Expanded(
                child: _buildOrdersList(orderProvider),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTodayStats(OrderProvider orderProvider) {
    final todaysOrders = orderProvider.todaysOrders;
    final totalRevenue = todaysOrders.fold(0.0, (sum, order) => sum + order.montantTotal);
    final pendingCount = todaysOrders.where((o) => o.statut == 'en_attente').length;
    final confirmedCount = todaysOrders.where((o) => o.statut == 'confirmee').length;
    final completedCount = todaysOrders.where((o) => o.statut == 'livree').length;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.blue[100]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.today, color: Colors.blue[600], size: 24),
              const SizedBox(width: 8),
              const Text(
                'Résumé d\'aujourd\'hui',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  todaysOrders.length.toString(),
                  'commandes',
                  Colors.blue[600]!,
                  Icons.shopping_bag,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'En attente',
                  pendingCount.toString(),
                  'nouvelles',
                  Colors.orange[600]!,
                  Icons.schedule,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Confirmées',
                  confirmedCount.toString(),
                  'en cours',
                  Colors.green[600]!,
                  Icons.check_circle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'CA du jour',
                  '${totalRevenue.toStringAsFixed(0)}',
                  'MRU',
                  Colors.purple[600]!,
                  Icons.attach_money,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, String subtitle, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrdersList(OrderProvider orderProvider) {
    if (orderProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
        ),
      );
    }

    if (orderProvider.errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              'Erreur: ${orderProvider.errorMessage}',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadTodaysOrders,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    final todaysOrders = orderProvider.todaysOrders;

    if (todaysOrders.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Aucune commande aujourd\'hui',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Les nouvelles commandes apparaîtront ici',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadTodaysOrders,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: todaysOrders.length,
        itemBuilder: (context, index) {
          final order = todaysOrders[index];
          return _buildTodayOrderCard(order);
        },
      ),
    );
  }

  Widget _buildTodayOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToOrderDetail(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec statut et heure
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'Commande #${order.id}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      _buildStatusChip(order.statut),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Text(
                        _formatOrderTime(order.dateCommande),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Informations client et montant
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Icon(Icons.person_outline, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          order.clientNom ?? 'Client #${order.clientId}',
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '${order.montantTotal.toStringAsFixed(0)} MRU',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Barre de progression du statut
              _buildStatusProgress(order.statut),
              
              const SizedBox(height: 12),
              
              // Actions rapides
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _navigateToOrderHistory(order),
                      icon: const Icon(Icons.history, size: 16),
                      label: const Text('Historique'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.blue,
                        side: const BorderSide(color: Colors.blue),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (order.statut == 'en_attente') ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _updateOrderStatus(order, 'confirmee'),
                        icon: const Icon(Icons.check, size: 16),
                        label: const Text('Confirmer'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ] else ...[
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _navigateToOrderDetail(order),
                        icon: const Icon(Icons.visibility, size: 16),
                        label: const Text('Voir détails'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color backgroundColor;
    Color textColor;
    String label;

    switch (status) {
      case 'en_attente':
        backgroundColor = Colors.orange[100]!;
        textColor = Colors.orange[800]!;
        label = 'En attente';
        break;
      case 'confirmee':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        label = 'Confirmée';
        break;
      case 'expediee':
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        label = 'Expédiée';
        break;
      case 'livree':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        label = 'Livrée';
        break;
      case 'annulee':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[800]!;
        label = 'Annulée';
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[800]!;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildStatusProgress(String currentStatus) {
    final statuses = ['en_attente', 'confirmee', 'expediee', 'livree'];
    final currentIndex = statuses.indexOf(currentStatus);
    
    if (currentStatus == 'annulee') {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red[200]!),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cancel, color: Colors.red[600], size: 16),
            const SizedBox(width: 8),
            Text(
              'Commande annulée',
              style: TextStyle(
                color: Colors.red[700],
                fontWeight: FontWeight.w500,
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final isCompleted = index <= currentIndex;
        final isCurrent = index == currentIndex;
        
        return Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 4,
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              if (index < statuses.length - 1)
                Container(
                  width: 8,
                  height: 8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  decoration: BoxDecoration(
                    color: isCompleted ? Colors.green : Colors.grey[300],
                    shape: BoxShape.circle,
                    border: isCurrent ? Border.all(color: Colors.green, width: 2) : null,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  String _formatTodayDate() {
    final now = DateTime.now();
    final months = [
      'janvier', 'février', 'mars', 'avril', 'mai', 'juin',
      'juillet', 'août', 'septembre', 'octobre', 'novembre', 'décembre'
    ];
    return '${now.day} ${months[now.month - 1]} ${now.year}';
  }

  String _formatOrderTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _updateOrderStatus(Order order, String newStatus) async {
    final orderProvider = context.read<OrderProvider>();
    final success = await orderProvider.updateOrderStatus(order.id, newStatus);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success 
                ? 'Statut mis à jour avec succès' 
                : 'Erreur: ${orderProvider.errorMessage}'
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
      
      if (success) {
        _loadTodaysOrders(); // Recharger la liste
      }
    }
  }

  void _navigateToOrderDetail(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderDetailScreen(order: order),
      ),
    );
  }

  void _navigateToOrderHistory(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderHistoryScreen(order: order),
      ),
    );
  }
}
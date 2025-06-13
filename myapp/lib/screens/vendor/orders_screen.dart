// screens/vendor/orders_screen.dart - INTERFACE COMPLÈTE
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import 'order_detail_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  final List<String> _statusFilters = [
    'Toutes',
    'en_attente',
    'confirme', 
    'expedie',
    'livre',
    'annule'
  ];

  final Map<String, String> _statusLabels = {
    'Toutes': 'Toutes',
    'en_attente': 'En attente',
    'confirme': 'Confirmées',
    'expedie': 'Expédiées',
    'livre': 'Livrées',
    'annule': 'Annulées',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFilters.length, vsync: this);
    
    // Charger les commandes au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = context.read<OrderProvider>();
      orderProvider.loadOrders(refresh: true);
      orderProvider.loadOrderStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Commandes',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: Colors.black87,
          unselectedLabelColor: Colors.grey,
          labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
          indicatorColor: Colors.black87,
          tabs: _statusFilters.map((status) => Tab(
            text: _statusLabels[status],
          )).toList(),
          onTap: (index) {
            final status = _statusFilters[index] == 'Toutes' ? null : _statusFilters[index];
            context.read<OrderProvider>().loadOrders(status: status, refresh: true);
          },
        ),
      ),
      body: Column(
        children: [
          // Statistiques rapides
          _buildStatsRow(),
          
          // Liste des commandes
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
                    ),
                  );
                }

                if (orderProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur: ${orderProvider.errorMessage}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => orderProvider.loadOrders(refresh: true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black87,
                            foregroundColor: Colors.white,
                          ),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    ),
                  );
                }

                if (orderProvider.orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.shopping_bag_outlined, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        const Text(
                          'Aucune commande',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _getCurrentStatusLabel(),
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                return RefreshIndicator(
                  onRefresh: () => orderProvider.refreshOrders(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: orderProvider.orders.length,
                    itemBuilder: (context, index) {
                      final order = orderProvider.orders[index];
                      return _buildOrderCard(order);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(
              bottom: BorderSide(color: Colors.grey[200]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Total',
                  orderProvider.totalOrders.toString(),
                  Colors.blue[600]!,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'En attente',
                  orderProvider.pendingOrders.toString(),
                  Colors.orange[600]!,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Confirmées',
                  orderProvider.confirmedOrders.toString(),
                  Colors.green[600]!,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'CA Total',
                  '${orderProvider.totalRevenue.toStringAsFixed(0)} MRU',
                  Colors.purple[600]!,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderCard(Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _navigateToOrderDetail(order),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de la commande
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Commande #${order.id}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  _buildStatusChip(order.statut),
                ],
              ),
              
              const SizedBox(height: 8),
              
              // Informations client
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Text(
                    'Client #${order.clientId}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
              
              const SizedBox(height: 4),
              
              // Date et montant
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.access_time, size: 16, color: Colors.grey),
                      const SizedBox(width: 8),
                      Text(
                        _formatDate(order.dateCommande),
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  Text(
                    '${order.montantTotal.toStringAsFixed(0)} MRU',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Actions rapides
              if (order.statut == 'en_attente')
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateOrderStatus(order, 'annule'),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.red),
                          foregroundColor: Colors.red,
                        ),
                        child: const Text('Refuser'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: () => _updateOrderStatus(order, 'confirme'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Confirmer'),
                      ),
                    ),
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
      case 'confirme':
        backgroundColor = Colors.blue[100]!;
        textColor = Colors.blue[800]!;
        label = 'Confirmée';
        break;
      case 'expedie':
        backgroundColor = Colors.purple[100]!;
        textColor = Colors.purple[800]!;
        label = 'Expédiée';
        break;
      case 'livre':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[800]!;
        label = 'Livrée';
        break;
      case 'annule':
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
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _getCurrentStatusLabel() {
    final currentIndex = _tabController.index;
    final status = _statusFilters[currentIndex];
    
    if (status == 'Toutes') {
      return 'Aucune commande trouvée';
    } else {
      return 'Aucune commande ${_statusLabels[status]?.toLowerCase()}';
    }
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
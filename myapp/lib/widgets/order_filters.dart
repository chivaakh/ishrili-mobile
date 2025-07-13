// ✅ FILE: screens/vendor/orders_screen.dart - FIXED STATUS FILTERS
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

  // ✅ FIXED: match database statuts (with 'e')
  final List<String> _statusFilters = [
    'Toutes',
    'en_attente',
    'confirmee',
    'expediee',
    'livree',
    'annulee'
  ];

  final Map<String, String> _statusLabels = {
    'Toutes': 'Toutes',
    'en_attente': 'En attente',
    'confirmee': 'Confirmées',
    'expediee': 'Expédiées',
    'livree': 'Livrées',
    'annulee': 'Annulées',
  };

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusFilters.length, vsync: this);

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
          _buildStatsRow(),
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
              _buildStatItem('Total', orderProvider.totalOrders.toString(), Colors.blue[600]!),
              _buildStatItem('En attente', orderProvider.pendingOrders.toString(), Colors.orange[600]!),
              _buildStatItem('Confirmées', orderProvider.confirmedOrders.toString(), Colors.green[600]!),
              _buildStatItem('CA Total', '${orderProvider.totalRevenue.toStringAsFixed(0)} MRU', Colors.purple[600]!),
            ].map((e) => Expanded(child: e)).toList(),
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildOrderCard(Order order) {
    // unchanged
    return Container(); // Replace this with your actual _buildOrderCard implementation
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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}

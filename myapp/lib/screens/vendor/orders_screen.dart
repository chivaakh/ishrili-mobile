// screens/vendor/orders_screen.dart - VERSION COMPLÈTE AVEC IMAGES
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../widgets/image_widget.dart';
import 'order_detail_screen.dart';
import 'order_history_screen.dart';
import 'todays_orders_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  
  // ✅ Statuts EXACTS de votre API
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
    
    // Charger les commandes au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = context.read<OrderProvider>();
      print('🚀 CHARGEMENT INITIAL DES COMMANDES...');
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
        // 🔥 BOUTON COMMANDES D'AUJOURD'HUI
        actions: [
          IconButton(
            icon: const Icon(Icons.today, color: Colors.blue),
            tooltip: 'Commandes d\'aujourd\'hui',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TodaysOrdersScreen(),
                ),
              );
            },
          ),
        ],
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
            print('🎯 TAB CLICKED: Index=$index, Status="$status"');
            
            // Afficher un indicateur de chargement
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Chargement des commandes ${_statusLabels[_statusFilters[index]]?.toLowerCase() ?? 'toutes'}...'),
                duration: const Duration(seconds: 1),
                backgroundColor: Colors.blue,
              ),
            );
            
            context.read<OrderProvider>().loadOrders(status: status, refresh: true);
          },
        ),
      ),
      body: Column(
        children: [
          // Indicateur de nombre total de commandes
          _buildOrderCountBanner(),
          
          // Statistiques rapides
          _buildStatsRow(),
          
          // Liste des commandes
          Expanded(
            child: Consumer<OrderProvider>(
              builder: (context, orderProvider, child) {
                print('🎯 RENDER - Provider orders: ${orderProvider.orders.length}');
                
                if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Récupération de toutes les commandes...',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  );
                }

                if (orderProvider.errorMessage != null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline, size: 48, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          'Erreur: ${orderProvider.errorMessage}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => orderProvider.loadOrders(refresh: true),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
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
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => orderProvider.loadOrders(refresh: true),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Actualiser'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                          ),
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
                      return _buildOrderCard(order, index);
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

  // 🔥 NOUVEAU : Bannière avec le nombre de commandes
  Widget _buildOrderCountBanner() {
    return Consumer<OrderProvider>(
      builder: (context, orderProvider, child) {
        if (orderProvider.orders.isEmpty && !orderProvider.isLoading) {
          return const SizedBox();
        }
        
        final currentStatus = _statusFilters[_tabController.index];
        final statusLabel = _statusLabels[currentStatus] ?? currentStatus;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border(
              bottom: BorderSide(color: Colors.blue[200]!, width: 1),
            ),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, size: 16, color: Colors.blue[600]),
              const SizedBox(width: 8),
              Text(
                orderProvider.isLoading 
                    ? 'Chargement...'
                    : '${orderProvider.orders.length} commandes ${statusLabel.toLowerCase()}',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontWeight: FontWeight.w500,
                  fontSize: 13,
                ),
              ),
              if (!orderProvider.isLoading) ...[
                const Spacer(),
                Text(
                  'Total: ${orderProvider.totalOrders}',
                  style: TextStyle(
                    color: Colors.blue[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        );
      },
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

Widget _buildOrderCard(Order order, int index) {
    // 🔥 RÉCUPÉRATION DE L'IMAGE DU PREMIER PRODUIT - VERSION CORRIGÉE
   // ✅ NOUVEAU CODE 
String? imageUrl;
if (order.details.isNotEmpty) {
  final firstDetail = order.details.first;
  // imagePrincipale retourne directement une String (URL complète)
  imageUrl = firstDetail.imagePrincipale;
}

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
              // En-tête de la commande
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
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${order.details.length} produit${order.details.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Colors.grey,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      _buildStatusChip(order.statut),
                      const SizedBox(width: 8),
                      // 🔥 BOUTON HISTORIQUE
                      InkWell(
                        onTap: () => _navigateToOrderHistory(order),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Icon(
                            Icons.history,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // 🔥 SECTION PRODUIT AVEC IMAGE
              if (order.details.isNotEmpty) ...[
                Row(
                  children: [
                    // Image du premier produit
                    ImageWidget(
                      imageUrl: imageUrl,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    
                    const SizedBox(width: 12),
                    
                    // Informations du premier produit
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            order.details.first.specification.nom,
                            style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Qté: ${order.details.first.quantite}${order.details.length > 1 ? ' (+${order.details.length - 1} autres)' : ''}',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
              ],
              
              // Informations client et date
              Row(
                children: [
                  const Icon(Icons.person_outline, size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      order.clientNomComplet,
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ),
                  const Icon(Icons.access_time, size: 16, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(order.dateCommande),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Montant et actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${order.montantTotal.toStringAsFixed(0)} MRU',
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 18,
                      color: Colors.green,
                    ),
                  ),
                  
                  // Actions rapides selon le statut
                  if (order.statut == 'en_attente') ...[
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: () => _updateOrderStatus(order, 'annulee'),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.red),
                            foregroundColor: Colors.red,
                            minimumSize: const Size(60, 32),
                          ),
                          child: const Text('Refuser', style: TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _updateOrderStatus(order, 'confirmee'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            minimumSize: const Size(80, 32),
                          ),
                          child: const Text('Confirmer', style: TextStyle(fontSize: 12)),
                        ),
                      ],
                    ),
                  ] else ...[
                    ElevatedButton.icon(
                      onPressed: () => _navigateToOrderDetail(order),
                      icon: const Icon(Icons.visibility, size: 16),
                      label: const Text('Détails', style: TextStyle(fontSize: 12)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(100, 32),
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

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return '${date.day}/${date.month}';
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
    
    // Afficher un indicateur de chargement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mise à jour du statut...'),
        duration: Duration(seconds: 1),
        backgroundColor: Colors.blue,
      ),
    );
    
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

  void _navigateToOrderHistory(Order order) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrderHistoryScreen(order: order),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
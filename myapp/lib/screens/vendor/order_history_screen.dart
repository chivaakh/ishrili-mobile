// screens/vendor/order_history_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';
import '../../services/order_service.dart';

class OrderHistoryScreen extends StatefulWidget {
  final Order order;
  
  const OrderHistoryScreen({super.key, required this.order});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<OrderStatusHistory> _history = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrderHistory();
  }

  Future<void> _loadOrderHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Appeler l'endpoint de tracking de votre API
      final orderService = OrderService();
      final response = await orderService.getOrderTracking(widget.order.id);
      
      if (response['success'] == true) {
        final historyData = response['data'] as List;
        _history = historyData.map((item) => OrderStatusHistory.fromJson(item)).toList();
      } else {
        // Fallback: créer l'historique depuis les données de la commande
        _history = _generateHistoryFromOrder();
      }
    } catch (e) {
      print('❌ Erreur chargement historique: $e');
      _errorMessage = 'Erreur lors du chargement de l\'historique';
      // Fallback: créer l'historique depuis les données de la commande
      _history = _generateHistoryFromOrder();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  List<OrderStatusHistory> _generateHistoryFromOrder() {
    // Créer un historique basique depuis les données de la commande
    final List<OrderStatusHistory> history = [];
    
    // Commande créée
    history.add(OrderStatusHistory(
      id: 1,
      ancienStatut: null,
      nouveauStatut: 'en_attente',
      dateModification: widget.order.dateCommande,
      commentaire: 'Commande créée',
    ));

    // Ajouter les autres statuts selon le statut actuel
    final statuses = ['confirmee', 'expediee', 'livree'];
    final currentStatusIndex = statuses.indexOf(widget.order.statut);
    
    for (int i = 0; i <= currentStatusIndex; i++) {
      if (i < statuses.length) {
        history.add(OrderStatusHistory(
          id: i + 2,
          ancienStatut: i == 0 ? 'en_attente' : statuses[i - 1],
          nouveauStatut: statuses[i],
          dateModification: widget.order.dateCommande.add(Duration(hours: i + 1)),
          commentaire: _getStatusComment(statuses[i]),
        ));
      }
    }

    return history.reversed.toList(); // Plus récent en premier
  }

  String _getStatusComment(String status) {
    switch (status) {
      case 'confirmee':
        return 'Commande confirmée par le vendeur';
      case 'expediee':
        return 'Commande expédiée';
      case 'livree':
        return 'Commande livrée au client';
      case 'annulee':
        return 'Commande annulée';
      default:
        return 'Statut mis à jour';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
            Text(
              'Historique - Commande #${widget.order.id}',
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              'Client: ${widget.order.clientNom ?? 'Client #${widget.order.clientId}'}',
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
            onPressed: _loadOrderHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Résumé de la commande
          _buildOrderSummary(),
          
          // Historique
          Expanded(
            child: _buildHistoryContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, 2),
            blurRadius: 8,
            color: Colors.black.withOpacity(0.1),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Statut actuel',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusChip(widget.order.statut),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Montant',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${widget.order.montantTotal.toStringAsFixed(0)} MRU',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 12),
          
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 8),
              Text(
                'Commandé le ${_formatDate(widget.order.dateCommande)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Chargement de l\'historique...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadOrderHistory,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            const Text(
              'Aucun historique disponible',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'L\'historique des modifications apparaîtra ici',
              style: TextStyle(color: Colors.grey[600]),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final historyItem = _history[index];
        final isLast = index == _history.length - 1;
        
        return _buildHistoryItem(historyItem, isLast);
      },
    );
  }

  Widget _buildHistoryItem(OrderStatusHistory historyItem, bool isLast) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Column(
            children: [
              _buildTimelineIcon(historyItem.nouveauStatut),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(1),
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(width: 16),
          
          // Contenu
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    offset: const Offset(0, 1),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.05),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête avec statut et date
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildStatusChip(historyItem.nouveauStatut),
                      Text(
                        _formatDateTime(historyItem.dateModification),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 8),
                  
                  // Changement de statut
                  if (historyItem.ancienStatut != null) ...[
                    Row(
                      children: [
                        _buildMiniStatusChip(historyItem.ancienStatut!),
                        const SizedBox(width: 8),
                        Icon(Icons.arrow_forward, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        _buildMiniStatusChip(historyItem.nouveauStatut),
                      ],
                    ),
                    const SizedBox(height: 8),
                  ],
                  
                  // Commentaire
                  if (historyItem.commentaire != null && historyItem.commentaire!.isNotEmpty)
                    Text(
                      historyItem.commentaire!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        height: 1.3,
                      ),
                    ),
                  
                  // Durée depuis le changement précédent
                  if (historyItem.ancienStatut != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _getTimeSinceChange(historyItem.dateModification),
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineIcon(String status) {
    IconData icon;
    Color color;

    switch (status) {
      case 'en_attente':
        icon = Icons.schedule;
        color = Colors.orange;
        break;
      case 'confirmee':
        icon = Icons.check_circle;
        color = Colors.blue;
        break;
      case 'expediee':
        icon = Icons.local_shipping;
        color = Colors.purple;
        break;
      case 'livree':
        icon = Icons.done_all;
        color = Colors.green;
        break;
      case 'annulee':
        icon = Icons.cancel;
        color = Colors.red;
        break;
      default:
        icon = Icons.circle;
        color = Colors.grey;
    }

    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
      ),
      child: Icon(
        icon,
        size: 16,
        color: color,
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
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

  Widget _buildMiniStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'en_attente':
        color = Colors.orange;
        label = 'En attente';
        break;
      case 'confirmee':
        color = Colors.blue;
        label = 'Confirmée';
        break;
      case 'expediee':
        color = Colors.purple;
        label = 'Expédiée';
        break;
      case 'livree':
        color = Colors.green;
        label = 'Livrée';
        break;
      case 'annulee':
        color = Colors.red;
        label = 'Annulée';
        break;
      default:
        color = Colors.grey;
        label = status;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatDateTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Aujourd\'hui ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Hier ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jours';
    } else {
      return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    }
  }

  String _getTimeSinceChange(DateTime changeDate) {
    final now = DateTime.now();
    final difference = now.difference(changeDate);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} minutes';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours} heures';
    } else {
      return 'Il y a ${difference.inDays} jours';
    }
  }
}

// Modèle pour l'historique des statuts
class OrderStatusHistory {
  final int id;
  final String? ancienStatut;
  final String nouveauStatut;
  final DateTime dateModification;
  final String? commentaire;

  OrderStatusHistory({
    required this.id,
    this.ancienStatut,
    required this.nouveauStatut,
    required this.dateModification,
    this.commentaire,
  });

  factory OrderStatusHistory.fromJson(Map<String, dynamic> json) {
    return OrderStatusHistory(
      id: json['id'] ?? 0,
      ancienStatut: json['ancien_statut'],
      nouveauStatut: json['nouveau_statut'] ?? '',
      dateModification: DateTime.parse(json['date_modification']),
      commentaire: json['commentaire'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ancien_statut': ancienStatut,
      'nouveau_statut': nouveauStatut,
      'date_modification': dateModification.toIso8601String(),
      'commentaire': commentaire,
    };
  }
}

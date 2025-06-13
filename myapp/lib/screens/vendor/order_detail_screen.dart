// screens/vendor/order_detail_screen.dart - NOUVEAU FICHIER
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/order_model.dart';
import '../../providers/order_provider.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;
  
  const OrderDetailScreen({super.key, required this.order});

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
        title: Text(
          'Commande #${order.id}',
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Statut et montant
            _buildOrderHeader(),
            
            const SizedBox(height: 24),
            
            // Informations client
            _buildSectionTitle('Informations client'),
            _buildClientInfo(),
            
            const SizedBox(height: 24),
            
            // Détails des produits
            _buildSectionTitle('Produits commandés'),
            _buildProductsList(),
            
            const SizedBox(height: 24),
            
            // Récapitulatif
            _buildSectionTitle('Récapitulatif'),
            _buildOrderSummary(),
            
            const SizedBox(height: 32),
            
            // Actions
            _buildActionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOrderHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
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
                    'Statut',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  _buildStatusChip(order.statut),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Montant total',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${order.montantTotal.toStringAsFixed(0)} MRU',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Commandé le ${_formatDate(order.dateCommande)}',
                style: const TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClientInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildInfoRow(Icons.person_outline, 'Client', 'Client #${order.clientId}'),
          const SizedBox(height: 12),
          _buildInfoRow(Icons.location_on_outlined, 'Adresse', 'Adresse de livraison'), // TODO: Vraie adresse
          const SizedBox(height: 12),
          _buildInfoRow(Icons.phone_outlined, 'Téléphone', '+222 XX XX XX XX'), // TODO: Vrai téléphone
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductsList() {
    if (order.details.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[200]!),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Text(
          'Aucun détail produit disponible',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    return Column(
      children: order.details.map((detail) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[200]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              // Image produit placeholder
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(width: 16),
              
              // Informations produit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Produit #${detail.specification.produitId}', // TODO: Nom du produit
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      detail.specification.nom,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Qté: ${detail.quantite}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        Text(
                          '${detail.prixUnitaire.toStringAsFixed(0)} MRU',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOrderSummary() {
    final totalItems = order.details.fold(0, (sum, detail) => sum + detail.quantite);
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          _buildSummaryRow('Nombre d\'articles', '$totalItems'),
          const SizedBox(height: 8),
          _buildSummaryRow('Sous-total', '${order.montantTotal.toStringAsFixed(0)} MRU'),
          const SizedBox(height: 8),
          _buildSummaryRow('Livraison', '0 MRU'), // TODO: Frais de livraison
          const Divider(),
          _buildSummaryRow(
            'Total',
            '${order.montantTotal.toStringAsFixed(0)} MRU',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w600 : FontWeight.w400,
            color: isTotal ? Colors.black87 : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.w700 : FontWeight.w600,
            color: isTotal ? Colors.green : Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    if (order.statut == 'livre' || order.statut == 'annule') {
      return const SizedBox(); // Pas d'actions pour les commandes terminées
    }

    return Column(
      children: [
        if (order.statut == 'en_attente') ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _updateOrderStatus(context, 'annule'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    foregroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Refuser la commande'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: () => _updateOrderStatus(context, 'confirme'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: const Text('Confirmer la commande'),
                ),
              ),
            ],
          ),
        ],
        
        if (order.statut == 'confirme') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _updateOrderStatus(context, 'expedie'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Marquer comme expédiée'),
            ),
          ),
        ],
        
        if (order.statut == 'expedie') ...[
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => _updateOrderStatus(context, 'livre'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Marquer comme livrée'),
            ),
          ),
        ],
      ],
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _updateOrderStatus(BuildContext context, String newStatus) async {
    final orderProvider = context.read<OrderProvider>();
    final success = await orderProvider.updateOrderStatus(order.id, newStatus);
    
    if (context.mounted) {
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
        Navigator.pop(context); // Retour à la liste des commandes
      }
    }
  }
}
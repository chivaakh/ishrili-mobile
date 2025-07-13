// widgets/order_card.dart - VERSION ADAPTÉE À VOS MODÈLES
import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../config/theme_config.dart';
import 'package:intl/intl.dart';

class OrderCard extends StatelessWidget {
  final ExtendedOrder order;
  final VoidCallback? onTap;
  final Function(OrderStatus)? onStatusChanged;

  const OrderCard({
    Key? key,
    required this.order,
    this.onTap,
    this.onStatusChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: AppTheme.cardProduct,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 12),
                _buildContent(),
                const SizedBox(height: 12),
                _buildFooter(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            gradient: AppTheme.primaryGradient,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.receipt_long,
            color: Colors.white,
            size: 16,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                order.numeroCommande,
                style: AppTheme.titleMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                DateFormat('dd/MM/yyyy à HH:mm').format(order.dateCommande),
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: order.statutColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: order.statutColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        order.statutLabel,
        style: AppTheme.bodySmall.copyWith(
          color: order.statutColor,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Informations client
        Row(
          children: [
            Icon(
              Icons.person,
              size: 16,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              'Client #${order.clientId}',
              style: AppTheme.bodyMedium,
            ),
          ],
        ),
        
        const SizedBox(height: 6),
        
        Row(
          children: [
            Icon(
              Icons.location_on,
              size: 16,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                order.adresseLivraison,
                style: AppTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        
        const SizedBox(height: 8),
        
        // Informations produits
        Row(
          children: [
            Icon(
              Icons.shopping_bag,
              size: 16,
              color: AppTheme.textTertiary,
            ),
            const SizedBox(width: 6),
            Text(
              '${order.nombreItems} article${order.nombreItems > 1 ? 's' : ''}',
              style: AppTheme.bodyMedium,
            ),
            const Spacer(),
            Text(
              '${order.montantTotal.toStringAsFixed(2)} €',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.zaffre,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        
        // Affichage des produits principaux
        if (order.details.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildProductsPreview(),
        ],
        
        // Numéro de suivi si disponible
        if (order.numeroSuivi != null) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(
                Icons.local_shipping,
                size: 16,
                color: AppTheme.textTertiary,
              ),
              const SizedBox(width: 6),
              Text(
                'Suivi: ${order.numeroSuivi}',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.zaffre,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildProductsPreview() {
    // Afficher les 2 premiers produits
    final previewItems = order.details.take(2).toList();
    final remainingCount = order.details.length - previewItems.length;

    return Column(
      children: [
        ...previewItems.map((detail) => Container(
          margin: const EdgeInsets.only(bottom: 4),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textTertiary,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${detail.nomProduit} (x${detail.quantite})',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${detail.total.toStringAsFixed(2)} €',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        )),
        if (remainingCount > 0)
          Container(
            margin: const EdgeInsets.only(top: 4),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.textTertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '+$remainingCount autre${remainingCount > 1 ? 's' : ''} produit${remainingCount > 1 ? 's' : ''}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textTertiary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Row(
      children: [
        // Indicateur de progression
        Expanded(
          child: _buildProgressIndicator(),
        ),
        const SizedBox(width: 12),
        
        // Actions rapides
        if (onStatusChanged != null) _buildQuickActions(context),
      ],
    );
  }

  Widget _buildProgressIndicator() {
    final statuses = [
      OrderStatus.pending,
      OrderStatus.confirmed,
      OrderStatus.shipped,
      OrderStatus.delivered,
    ];
    
    final currentIndex = statuses.indexOf(order.statutEnum);
    final isCancelled = order.statutEnum == OrderStatus.cancelled;
    
    return Row(
      children: statuses.asMap().entries.map((entry) {
        final index = entry.key;
        final isActive = index <= currentIndex && !isCancelled;
        final isCompleted = index < currentIndex && !isCancelled;
        
        return Expanded(
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isCancelled 
                      ? Colors.red.shade300
                      : isActive 
                          ? order.statutColor 
                          : Colors.grey.shade300,
                  shape: BoxShape.circle,
                ),
              ),
              if (index < statuses.length - 1)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCancelled 
                        ? Colors.red.shade200
                        : isCompleted 
                            ? order.statutColor 
                            : Colors.grey.shade200,
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    if (order.statutEnum == OrderStatus.delivered || 
        order.statutEnum == OrderStatus.cancelled) {
      return const SizedBox.shrink();
    }

    return PopupMenuButton<OrderStatus>(
      icon: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: AppTheme.zaffre.withOpacity(0.1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(
          Icons.more_vert,
          color: AppTheme.zaffre,
          size: 16,
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      itemBuilder: (context) {
        final List<PopupMenuEntry<OrderStatus>> items = [];
        
        // Actions possibles selon le statut actuel
        switch (order.statutEnum) {
          case OrderStatus.pending:
            items.addAll([
              PopupMenuItem(
                value: OrderStatus.confirmed,
                child: _buildMenuItem(
                  Icons.check_circle,
                  'Confirmer',
                  Colors.blue,
                ),
              ),
              PopupMenuItem(
                value: OrderStatus.cancelled,
                child: _buildMenuItem(
                  Icons.cancel,
                  'Annuler',
                  Colors.red,
                ),
              ),
            ]);
            break;
            
          case OrderStatus.confirmed:
            items.addAll([
              PopupMenuItem(
                value: OrderStatus.shipped,
                child: _buildMenuItem(
                  Icons.local_shipping,
                  'Expédier',
                  Colors.purple,
                ),
              ),
              PopupMenuItem(
                value: OrderStatus.cancelled,
                child: _buildMenuItem(
                  Icons.cancel,
                  'Annuler',
                  Colors.red,
                ),
              ),
            ]);
            break;
            
          case OrderStatus.shipped:
            items.add(
              PopupMenuItem(
                value: OrderStatus.delivered,
                child: _buildMenuItem(
                  Icons.done_all,
                  'Marquer comme livré',
                  Colors.green,
                ),
              ),
            );
            break;
            
          default:
            break;
        }
        
        return items;
      },
      onSelected: (status) {
        _showStatusConfirmDialog(context, status);
      },
    );
  }

  Widget _buildMenuItem(IconData icon, String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 8),
        Text(text),
      ],
    );
  }

  void _showStatusConfirmDialog(BuildContext context, OrderStatus newStatus) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Changer le statut'),
        content: Text(
          'Voulez-vous vraiment changer le statut de cette commande vers "${newStatus.label}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              onStatusChanged?.call(newStatus);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: newStatus.value == 'cancelled' 
                  ? Colors.red 
                  : AppTheme.zaffre,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Confirmer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
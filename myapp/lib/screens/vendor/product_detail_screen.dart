// screens/vendor/product_detail_screen.dart - CORRECTIONS DE TAILLE SEULEMENT 🔧
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/product_model.dart';
import '../../config/theme_config.dart';
import '../../providers/product_provider.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  
  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  PageController _imagePageController = PageController();
  int _currentImageIndex = 0;
  int _selectedSpecificationIndex = 0;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: AppTheme.animationMedium,
      vsync: this,
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: AppTheme.animationCurve),
    );
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animationController, curve: AppTheme.animationCurve));

    // Sélectionner la spécification par défaut
    if (widget.product.specifications.isNotEmpty) {
      final defaultSpecs = widget.product.specifications
          .where((spec) => spec.estDefaut)
          .toList();
      if (defaultSpecs.isNotEmpty) {
        _selectedSpecificationIndex = widget.product.specifications.indexOf(defaultSpecs.first);
      }
    }

    _animationController.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.adaptiveBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFFFFFFF),
            ],
          ),
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // 🎨 App Bar personnalisé avec image
                _buildSpectacularAppBar(),
                
                // 📸 Galerie d'images
                SliverToBoxAdapter(child: _buildImageGallery()),
                
                // 📋 Informations produit
                SliverToBoxAdapter(child: _buildProductInfo()),
                
                // 🎯 Spécifications
                SliverToBoxAdapter(child: _buildSpecifications()),
                
                // 📝 Description
                SliverToBoxAdapter(child: _buildDescription()),
                
                // 🛒 Section d'achat (pour les clients)
                SliverToBoxAdapter(child: _buildPurchaseSection()),
                
                // Espacement final RÉDUIT
                const SliverToBoxAdapter(
                  child: SizedBox(height: 60), // ⚡ Réduit de 100 à 60
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSpectacularAppBar() {
    return SliverAppBar(
      expandedHeight: 70, // ⚡ Réduit de 80 à 70
      floating: false,
      pinned: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient.colors.first.withOpacity(0.95) != null
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryGradient.colors.first.withOpacity(0.95),
                    AppTheme.primaryGradient.colors.last.withOpacity(0.85),
                  ],
                )
              : AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16), // ⚡ Réduit de spacingL à 16
            child: Row(
              children: [
                // Bouton retour
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    padding: const EdgeInsets.all(10), // ⚡ Réduit de 12 à 10
                    decoration: AppTheme.glassMorphism,
                    child: const Icon(
                      Icons.arrow_back_ios_rounded,
                      color: Colors.white,
                      size: 18, // ⚡ Réduit de 20 à 18
                    ),
                  ),
                ),
                
                const SizedBox(width: 12), // ⚡ Réduit de spacingM à 12
                
                // Titre
                Expanded(
                  child: Text(
                    widget.product.nom,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16, // ⚡ Réduit de 18 à 16
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                
                // Actions
                Row(
                  children: [
                    _buildActionButton(
                      Icons.share_rounded,
                      () => _shareProduct(),
                    ),
                    const SizedBox(width: 8), // ⚡ Réduit de spacingS à 8
                    _buildActionButton(
                      Icons.favorite_border_rounded,
                      () => _toggleFavorite(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8), // ⚡ Réduit de 10 à 8
        decoration: AppTheme.glassMorphism,
        child: Icon(
          icon,
          color: Colors.white,
          size: 18, // ⚡ Réduit de 20 à 18
        ),
      ),
    );
  }

  Widget _buildImageGallery() {
    final images = widget.product.allImageUrls;
    
    if (images.isEmpty) {
      return Container(
        height: 250, // ⚡ Réduit de 300 à 250
        margin: const EdgeInsets.all(16), // ⚡ Réduit de spacingL à 16
        decoration: BoxDecoration(
          gradient: AppTheme.customGradient([
            Colors.grey[200]!,
            Colors.grey[100]!,
          ]),
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.image_outlined,
              size: 56, // ⚡ Réduit de 64 à 56
              color: AppTheme.textTertiary,
            ),
            SizedBox(height: 12), // ⚡ Réduit de 16 à 12
            Text(
              'Aucune image disponible',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 14, // ⚡ Réduit de 16 à 14
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Galerie principale
        Container(
          height: 250, // ⚡ Réduit de 300 à 250
          margin: const EdgeInsets.symmetric(horizontal: 16), // ⚡ Réduit de spacingL à 16
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            boxShadow: AppTheme.elevationMedium,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
            child: PageView.builder(
              controller: _imagePageController,
              onPageChanged: (index) {
                setState(() {
                  _currentImageIndex = index;
                });
              },
              itemCount: images.length,
              itemBuilder: (context, index) {
                return Image.network(
                  images[index],
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.lightGradient,
                      ),
                      child: Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2, // ⚡ Réduit de 3 à 2
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.zaffre),
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                              : null,
                        ),
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: AppTheme.customGradient([
                          AppTheme.accent.withOpacity(0.1),
                          AppTheme.accent.withOpacity(0.05),
                        ]),
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.broken_image_outlined,
                            size: 56, // ⚡ Réduit de 64 à 56
                            color: AppTheme.accent,
                          ),
                          SizedBox(height: 12), // ⚡ Réduit de 16 à 12
                          Text(
                            'Image non disponible',
                            style: TextStyle(
                              color: AppTheme.accent,
                              fontSize: 14, // ⚡ Réduit de 16 à 14
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
        
        const SizedBox(height: 16), // ⚡ Réduit de spacingL à 16
        
        // Indicateurs d'images
        if (images.length > 1)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: images.asMap().entries.map((entry) {
              final index = entry.key;
              final isActive = index == _currentImageIndex;
              
              return GestureDetector(
                onTap: () {
                  _imagePageController.animateToPage(
                    index,
                    duration: AppTheme.animationMedium,
                    curve: AppTheme.animationCurve,
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3), // ⚡ Réduit de 4 à 3
                  width: isActive ? 20 : 6, // ⚡ Réduit de 24 à 20, 8 à 6
                  height: 6, // ⚡ Réduit de 8 à 6
                  decoration: BoxDecoration(
                    gradient: isActive ? AppTheme.neonGradient : null,
                    color: isActive ? null : Colors.grey.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(3), // ⚡ Réduit de 4 à 3
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }

  Widget _buildProductInfo() {
    return Container(
      margin: const EdgeInsets.all(16), // ⚡ Réduit de spacingL à 16
      padding: const EdgeInsets.all(20), // ⚡ Réduit de spacingXL à 20
      decoration: AppTheme.cardModern,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nom et catégorie
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.nom,
                      style: const TextStyle(
                        fontSize: 20, // ⚡ Réduit de 24 à 20
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 6), // ⚡ Réduit de 8 à 6
                    if (widget.product.categorie != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // ⚡ Réduit les paddings
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16), // ⚡ Réduit de 20 à 16
                        ),
                        child: Text(
                          widget.product.categorie!.nom,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11, // ⚡ Réduit de 12 à 11
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              
              // Badge stock
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // ⚡ Réduit les paddings
                decoration: BoxDecoration(
                  gradient: widget.product.inStock 
                      ? AppTheme.customGradient([AppTheme.success, AppTheme.success.withOpacity(0.8)])
                      : AppTheme.customGradient([AppTheme.accent, AppTheme.accent.withOpacity(0.8)]),
                  borderRadius: BorderRadius.circular(14), // ⚡ Réduit de 16 à 14
                  boxShadow: [
                    BoxShadow(
                      color: (widget.product.inStock ? AppTheme.success : AppTheme.accent).withOpacity(0.3),
                      blurRadius: 6, // ⚡ Réduit de 8 à 6
                      offset: const Offset(0, 3), // ⚡ Réduit de 4 à 3
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      widget.product.inStock ? Icons.check_circle_rounded : Icons.error_rounded,
                      color: Colors.white,
                      size: 14, // ⚡ Réduit de 16 à 14
                    ),
                    const SizedBox(width: 4), // ⚡ Réduit de 6 à 4
                    Text(
                      widget.product.inStock ? 'En stock' : 'Épuisé',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11, // ⚡ Réduit de 12 à 11
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16), // ⚡ Réduit de spacingL à 16
          
          // Référence et stock
          Row(
            children: [
              Expanded(
                child: _buildInfoItem(
                  'Référence',
                  widget.product.reference ?? 'N/A',
                  Icons.qr_code_rounded,
                ),
              ),
              const SizedBox(width: 8), // ⚡ Ajout d'espacement entre les deux
              Expanded(
                child: _buildInfoItem(
                  'Stock Total',
                  '${widget.product.totalStock} unités',
                  Icons.inventory_rounded,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16), // ⚡ Réduit de spacingL à 16
          
          // Prix
          if (widget.product.specifications.isNotEmpty)
            _buildPriceSection(),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12), // ⚡ Réduit de spacingM à 12
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 14, color: AppTheme.zaffre), // ⚡ Réduit de 16 à 14
              const SizedBox(width: 4), // ⚡ Réduit de 6 à 4
              Expanded( // ⚡ Ajouté Expanded pour éviter les débordements
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11, // ⚡ Réduit de 12 à 11
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 3), // ⚡ Réduit de 4 à 3
          Text(
            value,
            style: const TextStyle(
              fontSize: 12, // ⚡ Réduit de 14 à 12
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 1, // ⚡ Limite à 1 ligne
            overflow: TextOverflow.ellipsis, // ⚡ Ajoute ellipsis si trop long
          ),
        ],
      ),
    );
  }

  Widget _buildPriceSection() {
    final selectedSpec = widget.product.specifications.isNotEmpty
        ? widget.product.specifications[_selectedSpecificationIndex]
        : null;
    
    if (selectedSpec == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(16), // ⚡ Réduit de spacingL à 16
      decoration: BoxDecoration(
        gradient: AppTheme.customGradient([
          AppTheme.success.withOpacity(0.05),
          AppTheme.success.withOpacity(0.02),
        ]),
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        border: Border.all(color: AppTheme.success.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.monetization_on_rounded,
            color: AppTheme.success,
            size: 20, // ⚡ Réduit de 24 à 20
          ),
          const SizedBox(width: 12), // ⚡ Réduit de spacingM à 12
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedSpec.hasPromo) ...[
                  Text(
                    '${selectedSpec.prix.toStringAsFixed(0)} MRU',
                    style: const TextStyle(
                      fontSize: 12, // ⚡ Réduit de 14 à 12
                      color: AppTheme.textTertiary,
                      decoration: TextDecoration.lineThrough,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 1), // ⚡ Réduit de 2 à 1
                ],
                Text(
                  '${selectedSpec.finalPrice.toStringAsFixed(0)} MRU',
                  style: TextStyle(
                    fontSize: 18, // ⚡ Réduit de 20 à 18
                    color: selectedSpec.hasPromo ? AppTheme.success : AppTheme.textPrimary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
          if (selectedSpec.hasPromo)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), // ⚡ Réduit les paddings
              decoration: BoxDecoration(
                gradient: AppTheme.sunsetGradient,
                borderRadius: BorderRadius.circular(16), // ⚡ Réduit de 20 à 16
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.warning.withOpacity(0.3),
                    blurRadius: 6, // ⚡ Réduit de 8 à 6
                    offset: const Offset(0, 1), // ⚡ Réduit de 2 à 1
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_fire_department_rounded, color: Colors.white, size: 12), // ⚡ Réduit de 14 à 12
                  const SizedBox(width: 3), // ⚡ Réduit de 4 à 3
                  Text(
                    'PROMO',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10, // ⚡ Réduit de 11 à 10
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSpecifications() {
    if (widget.product.specifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16), // ⚡ Réduit de spacingL à 16
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre de section
          Container(
            padding: const EdgeInsets.all(16), // ⚡ Réduit de spacingL à 16
            decoration: BoxDecoration(
              gradient: AppTheme.customGradient([
                AppTheme.zaffre.withOpacity(0.1),
                AppTheme.mauveine.withOpacity(0.05),
              ]),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLarge),
                topRight: Radius.circular(AppTheme.radiusLarge),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10), // ⚡ Réduit de 12 à 10
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(10), // ⚡ Réduit de 12 à 10
                    boxShadow: AppTheme.glowShadow,
                  ),
                  child: const Icon(Icons.tune_rounded, color: Colors.white, size: 18), // ⚡ Réduit de 20 à 18
                ),
                const SizedBox(width: 12), // ⚡ Réduit de spacingM à 12
                const Text(
                  'Variantes Disponibles',
                  style: TextStyle(
                    fontSize: 16, // ⚡ Réduit de 18 à 16
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          // Liste des spécifications
          Container(
            padding: const EdgeInsets.all(16), // ⚡ Réduit de spacingL à 16
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(AppTheme.radiusLarge),
                bottomRight: Radius.circular(AppTheme.radiusLarge),
              ),
              boxShadow: AppTheme.elevationMedium,
            ),
            child: Column(
              children: widget.product.specifications.asMap().entries.map((entry) {
                final index = entry.key;
                final spec = entry.value;
                final isSelected = index == _selectedSpecificationIndex;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSpecificationIndex = index;
                    });
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      bottom: index < widget.product.specifications.length - 1 ? 12 : 0, // ⚡ Réduit de spacingM à 12
                    ),
                    padding: const EdgeInsets.all(16), // ⚡ Réduit de spacingL à 16
                    decoration: BoxDecoration(
                      gradient: isSelected 
                          ? AppTheme.neonGradient
                          : AppTheme.customGradient([Colors.grey[50]!, Colors.grey[25]!]),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      border: Border.all(
                        color: isSelected 
                            ? Colors.transparent
                            : Colors.grey.withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: isSelected ? AppTheme.neonShadow : AppTheme.elevationLow,
                    ),
                    child: Row(
                      children: [
                        // Icône de sélection
                        Container(
                          padding: const EdgeInsets.all(6), // ⚡ Réduit de 8 à 6
                          decoration: BoxDecoration(
                            color: isSelected 
                                ? Colors.white.withOpacity(0.2)
                                : AppTheme.zaffre.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isSelected ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
                            color: isSelected ? Colors.white : AppTheme.zaffre,
                            size: 18, // ⚡ Réduit de 20 à 18
                          ),
                        ),
                        
                        const SizedBox(width: 12), // ⚡ Réduit de spacingM à 12
                        
                        // Informations
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      spec.nom,
                                      style: TextStyle(
                                        fontSize: 14, // ⚡ Réduit de 16 à 14
                                        fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.white : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ),
                                  if (spec.estDefaut)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1), // ⚡ Réduit paddings
                                      decoration: BoxDecoration(
                                        color: isSelected 
                                            ? Colors.white.withOpacity(0.2)
                                            : AppTheme.success.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(6), // ⚡ Réduit de 8 à 6
                                      ),
                                      child: Text(
                                        'Par défaut',
                                        style: TextStyle(
                                          color: isSelected ? Colors.white : AppTheme.success,
                                          fontSize: 9, // ⚡ Réduit de 10 à 9
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              
                              if (spec.description.isNotEmpty) ...[
                                const SizedBox(height: 3), // ⚡ Réduit de 4 à 3
                                Text(
                                  spec.description,
                                  style: TextStyle(
                                    fontSize: 11, // ⚡ Réduit de 12 à 11
                                    color: isSelected 
                                        ? Colors.white.withOpacity(0.8)
                                        : AppTheme.textSecondary,
                                  ),
                                  maxLines: 2, // ⚡ Limite le nombre de lignes
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              
                              const SizedBox(height: 6), // ⚡ Réduit de 8 à 6
                              
                              Row(
                                children: [
                                  // Prix
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), // ⚡ Réduit paddings
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? Colors.white.withOpacity(0.2)
                                          : AppTheme.success.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6), // ⚡ Réduit de 8 à 6
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (spec.hasPromo) ...[
                                          Text(
                                            '${spec.prix.toStringAsFixed(0)}',
                                            style: TextStyle(
                                              fontSize: 9, // ⚡ Réduit de 10 à 9
                                              color: isSelected 
                                                  ? Colors.white.withOpacity(0.7)
                                                  : AppTheme.textTertiary,
                                              decoration: TextDecoration.lineThrough,
                                            ),
                                          ),
                                          const SizedBox(width: 3), // ⚡ Réduit de 4 à 3
                                        ],
                                        Text(
                                          '${spec.finalPrice.toStringAsFixed(0)} MRU',
                                          style: TextStyle(
                                            fontSize: 11, // ⚡ Réduit de 12 à 11
                                            fontWeight: FontWeight.w700,
                                            color: isSelected 
                                                ? Colors.white
                                                : spec.hasPromo ? AppTheme.success : AppTheme.textPrimary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  const Spacer(),
                                  
                                  // Stock
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3), // ⚡ Réduit paddings
                                    decoration: BoxDecoration(
                                      color: isSelected 
                                          ? Colors.white.withOpacity(0.2)
                                          : (spec.inStock ? AppTheme.success : AppTheme.accent).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(6), // ⚡ Réduit de 8 à 6
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          spec.inStock ? Icons.check_circle_rounded : Icons.error_rounded,
                                          color: isSelected 
                                              ? Colors.white
                                              : (spec.inStock ? AppTheme.success : AppTheme.accent),
                                          size: 11, // ⚡ Réduit de 12 à 11
                                        ),
                                        const SizedBox(width: 3), // ⚡ Réduit de 4 à 3
                                        Text(
                                          '${spec.quantiteStock}',
                                          style: TextStyle(
                                            fontSize: 10, // ⚡ Réduit de 11 à 10
                                            fontWeight: FontWeight.w600,
                                            color: isSelected 
                                                ? Colors.white
                                                : (spec.inStock ? AppTheme.success : AppTheme.accent),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    if (widget.product.description.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.all(16), // ⚡ Réduit de spacingL à 16
      padding: const EdgeInsets.all(20), // ⚡ Réduit de spacingXL à 20
      decoration: AppTheme.cardModern,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10), // ⚡ Réduit de 12 à 10
                decoration: BoxDecoration(
                  gradient: AppTheme.purpleGradient,
                  borderRadius: BorderRadius.circular(10), // ⚡ Réduit de 12 à 10
                ),
                child: const Icon(Icons.description_rounded, color: Colors.white, size: 18), // ⚡ Réduit de 20 à 18
              ),
              const SizedBox(width: 12), // ⚡ Réduit de spacingM à 12
              const Text(
                'Description',
                style: TextStyle(
                  fontSize: 16, // ⚡ Réduit de 18 à 16
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16), // ⚡ Réduit de spacingL à 16
          
          // Contenu
          Text(
            widget.product.description,
            style: const TextStyle(
              fontSize: 14, // ⚡ Réduit de 16 à 14
              color: AppTheme.textSecondary,
              height: 1.5, // ⚡ Réduit de 1.6 à 1.5
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseSection() {
    final selectedSpec = widget.product.specifications.isNotEmpty
        ? widget.product.specifications[_selectedSpecificationIndex]
        : null;

    return Container(
      margin: const EdgeInsets.all(16), // ⚡ Réduit de spacingL à 16
      padding: const EdgeInsets.all(20), // ⚡ Réduit de spacingXL à 20
      decoration: BoxDecoration(
        gradient: AppTheme.customGradient([
          AppTheme.zaffre.withOpacity(0.05),
          AppTheme.mauveine.withOpacity(0.02),
        ]),
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        border: Border.all(color: AppTheme.zaffre.withOpacity(0.1)),
        boxShadow: AppTheme.elevationMedium,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10), // ⚡ Réduit de 12 à 10
                decoration: BoxDecoration(
                  gradient: AppTheme.neonGradient,
                  borderRadius: BorderRadius.circular(10), // ⚡ Réduit de 12 à 10
                  boxShadow: AppTheme.neonShadow,
                ),
                child: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 18), // ⚡ Réduit de 20 à 18
              ),
              const SizedBox(width: 12), // ⚡ Réduit de spacingM à 12
              const Text(
                'Commande',
                style: TextStyle(
                  fontSize: 16, // ⚡ Réduit de 18 à 16
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16), // ⚡ Réduit de spacingL à 16
          
          // Résumé sélection
          if (selectedSpec != null) ...[
            Container(
              padding: const EdgeInsets.all(16), // ⚡ Réduit de spacingL à 16
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sélection actuelle',
                          style: const TextStyle(
                            fontSize: 11, // ⚡ Réduit de 12 à 11
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 3), // ⚡ Réduit de 4 à 3
                        Text(
                          selectedSpec.nom,
                          style: const TextStyle(
                            fontSize: 14, // ⚡ Réduit de 16 à 14
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), // ⚡ Réduit paddings
                    decoration: BoxDecoration(
                      gradient: selectedSpec.hasPromo ? AppTheme.sunsetGradient : AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(10), // ⚡ Réduit de 12 à 10
                    ),
                    child: Text(
                      '${selectedSpec.finalPrice.toStringAsFixed(0)} MRU',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14, // ⚡ Réduit de 16 à 14
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16), // ⚡ Réduit de spacingL à 16
          ],
          
          // Boutons d'action
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 48, // ⚡ Réduit de 56 à 48
                  decoration: BoxDecoration(
                    border: Border.all(color: AppTheme.zaffre.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => _contactSeller(),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      child: const Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.message_rounded, color: AppTheme.zaffre, size: 18), // ⚡ Réduit de 20 à 18
                            SizedBox(width: 6), // ⚡ Réduit de 8 à 6
                            Text(
                              'Contacter',
                              style: TextStyle(
                                color: AppTheme.zaffre,
                                fontSize: 14, // ⚡ Réduit de 16 à 14
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 12), // ⚡ Réduit de spacingM à 12
              
              Expanded(
                flex: 2,
                child: Container(
                  height: 48, // ⚡ Réduit de 56 à 48
                  decoration: BoxDecoration(
                    gradient: selectedSpec?.inStock == true ? AppTheme.neonGradient : AppTheme.lightGradient,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    boxShadow: selectedSpec?.inStock == true ? AppTheme.neonShadow : null,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: selectedSpec?.inStock == true ? () => _addToCart() : null,
                      borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              selectedSpec?.inStock == true ? Icons.add_shopping_cart_rounded : Icons.error_rounded,
                              color: selectedSpec?.inStock == true ? Colors.white : AppTheme.textTertiary,
                              size: 18, // ⚡ Réduit de 20 à 18
                            ),
                            const SizedBox(width: 6), // ⚡ Réduit de 8 à 6
                            Flexible( // ⚡ Ajouté Flexible pour éviter les débordements
                              child: Text(
                                selectedSpec?.inStock == true ? 'Ajouter au Panier' : 'Non Disponible',
                                style: TextStyle(
                                  color: selectedSpec?.inStock == true ? Colors.white : AppTheme.textTertiary,
                                  fontSize: 14, // ⚡ Réduit de 16 à 14
                                  fontWeight: FontWeight.w600,
                                ),
                                overflow: TextOverflow.ellipsis, // ⚡ Protection contre débordement
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _shareProduct() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6), // ⚡ Réduit de 8 à 6
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.share_rounded, color: Colors.white, size: 14), // ⚡ Réduit de 16 à 14
            ),
            const SizedBox(width: 10), // ⚡ Réduit de 12 à 10
            const Text('Partage bientôt disponible ! 📱'),
          ],
        ),
        backgroundColor: AppTheme.zaffre,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // ⚡ Réduit de 12 à 10
        margin: const EdgeInsets.all(12), // ⚡ Réduit de 16 à 12
      ),
    );
  }

  void _toggleFavorite() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6), // ⚡ Réduit de 8 à 6
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.favorite_rounded, color: Colors.white, size: 14), // ⚡ Réduit de 16 à 14
            ),
            const SizedBox(width: 10), // ⚡ Réduit de 12 à 10
            const Text('Favoris bientôt disponibles ! ❤️'),
          ],
        ),
        backgroundColor: AppTheme.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // ⚡ Réduit de 12 à 10
        margin: const EdgeInsets.all(12), // ⚡ Réduit de 16 à 12
      ),
    );
  }

  void _contactSeller() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6), // ⚡ Réduit de 8 à 6
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.message_rounded, color: Colors.white, size: 14), // ⚡ Réduit de 16 à 14
            ),
            const SizedBox(width: 10), // ⚡ Réduit de 12 à 10
            const Text('Messagerie bientôt disponible ! 💬'),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // ⚡ Réduit de 12 à 10
        margin: const EdgeInsets.all(12), // ⚡ Réduit de 16 à 12
      ),
    );
  }

  void _addToCart() {
    final selectedSpec = widget.product.specifications[_selectedSpecificationIndex];
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6), // ⚡ Réduit de 8 à 6
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.shopping_cart_rounded, color: Colors.white, size: 14), // ⚡ Réduit de 16 à 14
            ),
            const SizedBox(width: 10), // ⚡ Réduit de 12 à 10
            Expanded(
              child: Text(
                '"${selectedSpec.nom}" ajouté au panier ! 🛒',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)), // ⚡ Réduit de 12 à 10
        margin: const EdgeInsets.all(12), // ⚡ Réduit de 16 à 12
        action: SnackBarAction(
          label: 'Voir Panier',
          textColor: Colors.white,
          onPressed: () {
            // TODO: Naviguer vers le panier
          },
        ),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _imagePageController.dispose();
    super.dispose();
  }
}
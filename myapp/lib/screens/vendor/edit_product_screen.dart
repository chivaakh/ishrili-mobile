// screens/vendor/edit_product_screen.dart - STYLE MODERNE IDENTIQUE 🚀✨
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/product_model.dart';
import '../../models/category_model.dart' as models;
import '../../config/theme_config.dart';

class EditProductScreen extends StatefulWidget {
  final Product product;
  
  const EditProductScreen({super.key, required this.product});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomController;
  late TextEditingController _descriptionController;
  late TextEditingController _referenceController;
  
  List<Map<String, dynamic>> _newUploadedImages = [];
  bool _isLoading = false;
  bool _isUploadingImage = false;
  models.Category? _selectedCategory;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialiser les contrôleurs avec les valeurs existantes
    _nomController = TextEditingController(text: widget.product.nom);
    _descriptionController = TextEditingController(text: widget.product.description);
    _referenceController = TextEditingController(text: widget.product.reference);
    _selectedCategory = widget.product.categorie;
    
    _animationController = AnimationController(
      duration: AppTheme.animationMedium,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: AppTheme.animationCurve),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
      _animationController.forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.adaptiveBackground,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8FAFC),
              Color(0xFFFFFFFF),
              Color(0xFFF1F5F9),
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🎨 Header Spectaculaire
              _buildSpectacularHeader(),
              
              // 📝 Contenu Principal
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildMainContent(),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpectacularHeader() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingL),
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: AppTheme.glowShadow,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: AppTheme.glassMorphism,
              child: const Icon(
                Icons.arrow_back_ios_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Modifier Produit',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Perfectionnez "${widget.product.nom}"',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          if (!_isLoading)
            GestureDetector(
              onTap: _updateProduct,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: AppTheme.glassMorphism,
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.save_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Sauver',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
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

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              gradient: AppTheme.neonGradient,
              shape: BoxShape.circle,
              boxShadow: AppTheme.neonShadow,
            ),
            child: const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Mise à jour en cours...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Votre produit se transforme ✨',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📸 Section Images Existantes
            _buildModernSection(
              'Photos Actuelles',
              Icons.photo_library_rounded,
              AppTheme.purpleGradient,
              [_buildExistingImages()],
            ),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // 📸 Section Nouvelles Images
            _buildModernSection(
              'Nouvelles Photos',
              Icons.add_photo_alternate_rounded,
              AppTheme.neonGradient,
              [
                if (_newUploadedImages.isNotEmpty) _buildNewImageGallery(),
                const SizedBox(height: AppTheme.spacingM),
                _buildImageUploadArea(),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // 📋 Informations de base
            _buildModernSection(
              'Informations Produit',
              Icons.info_rounded,
              AppTheme.blueGradient,
              [
                _buildModernTextField(
                  controller: _nomController,
                  label: 'Nom du produit',
                  hint: 'Ex: iPhone 16 Pro Max',
                  icon: Icons.label_rounded,
                ),
                _buildModernTextField(
                  controller: _referenceController,
                  label: 'Référence unique',
                  hint: 'Ex: REF-IP16-001',
                  icon: Icons.qr_code_rounded,
                ),
                _buildModernCategorySelector(),
                _buildModernTextField(
                  controller: _descriptionController,
                  label: 'Description',
                  hint: 'Décrivez les caractéristiques exceptionnelles...',
                  icon: Icons.description_rounded,
                  maxLines: 4,
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingXL),
            
            // 💰 Spécifications existantes
            _buildModernSection(
              'Spécifications Actuelles',
              Icons.settings_rounded,
              AppTheme.sunsetGradient,
              [_buildSpecificationsList()],
            ),
            
            const SizedBox(height: AppTheme.spacingXXL),
            
            // 🚀 Bouton de mise à jour
            _buildSpectacularUpdateButton(),
            
            const SizedBox(height: AppTheme.spacingXL),
          ],
        ),
      ),
    );
  }

  Widget _buildExistingImages() {
    if (widget.product.images.isEmpty) {
      return Container(
        height: 120,
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
              color: AppTheme.textTertiary,
              size: 40,
            ),
            SizedBox(height: 8),
            Text(
              'Aucune image actuelle',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: widget.product.images.length,
        itemBuilder: (context, index) {
          final image = widget.product.images[index];
          return Container(
            margin: const EdgeInsets.only(right: AppTheme.spacingM),
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: AppTheme.elevationMedium,
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  child: Image.network(
                    image.urlImage,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        ),
                        child: const Icon(Icons.error_rounded, color: Colors.grey),
                      );
                    },
                  ),
                ),
                
                // Badge principal
                if (image.estPrincipale)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        gradient: AppTheme.neonGradient,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: AppTheme.neonShadow,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.star_rounded, color: Colors.white, size: 12),
                          SizedBox(width: 4),
                          Text(
                            'Principal',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
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

  Widget _buildNewImageGallery() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _newUploadedImages.length,
        itemBuilder: (context, index) {
          final imageData = _newUploadedImages[index];
          return Container(
            margin: const EdgeInsets.only(right: AppTheme.spacingM),
            width: 120,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: AppTheme.elevationMedium,
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  child: Image.network(
                    imageData['url_image'],
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                        ),
                        child: const Icon(Icons.error_rounded, color: Colors.grey),
                      );
                    },
                  ),
                ),
                
                // Badge nouveau
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: AppTheme.customGradient([AppTheme.success, AppTheme.success.withOpacity(0.8)]),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.success.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.fiber_new_rounded, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'Nouveau',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Bouton supprimer
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => setState(() => _newUploadedImages.removeAt(index)),
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppTheme.accent,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accent.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                        size: 14,
                      ),
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

  Widget _buildImageUploadArea() {
    return GestureDetector(
      onTap: _isUploadingImage ? null : _pickAndUploadImages,
      child: Container(
        width: double.infinity,
        height: 140,
        decoration: BoxDecoration(
          gradient: _isUploadingImage 
              ? AppTheme.lightGradient
              : AppTheme.customGradient([
                  AppTheme.zaffre.withOpacity(0.05),
                  AppTheme.mauveine.withOpacity(0.05),
                ]),
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          border: Border.all(
            color: _isUploadingImage 
                ? AppTheme.zaffre.withOpacity(0.3)
                : AppTheme.zaffre.withOpacity(0.2),
            width: 2,
            style: BorderStyle.solid,
          ),
          boxShadow: _isUploadingImage ? AppTheme.elevationMedium : null,
        ),
        child: _isUploadingImage
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.neonGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.neonShadow,
                    ),
                    child: const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      strokeWidth: 3,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Upload magique en cours...',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Text(
                    'Nouvelles images en route ✨',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      shape: BoxShape.circle,
                      boxShadow: AppTheme.glowShadow,
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_rounded,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _newUploadedImages.isEmpty 
                        ? 'Ajoutez de nouvelles photos' 
                        : 'Ajoutez encore plus d\'images',
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Touchez pour sélectionner vos nouvelles images',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildSpecificationsList() {
    if (widget.product.specifications.isEmpty) {
      return Container(
        height: 100,
        decoration: BoxDecoration(
          gradient: AppTheme.customGradient([
            Colors.grey[100]!,
            Colors.grey[50]!,
          ]),
          borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
          border: Border.all(color: Colors.grey.withOpacity(0.2)),
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_outlined,
              color: AppTheme.textTertiary,
              size: 32,
            ),
            SizedBox(height: 8),
            Text(
              'Aucune spécification',
              style: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: widget.product.specifications.asMap().entries.map((entry) {
        final index = entry.key;
        final spec = entry.value;
        
        return Container(
          margin: EdgeInsets.only(bottom: index < widget.product.specifications.length - 1 ? AppTheme.spacingM : 0),
          padding: const EdgeInsets.all(AppTheme.spacingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
            border: Border.all(color: Colors.grey.withOpacity(0.1)),
            boxShadow: AppTheme.elevationLow,
          ),
          child: Row(
            children: [
              // Icône de spécification
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: spec.estDefaut ? AppTheme.neonGradient : AppTheme.lightGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  spec.estDefaut ? Icons.star_rounded : Icons.tune_rounded,
                  color: spec.estDefaut ? Colors.white : AppTheme.textSecondary,
                  size: 20,
                ),
              ),
              
              const SizedBox(width: AppTheme.spacingM),
              
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
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        if (spec.estDefaut)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              gradient: AppTheme.neonGradient,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Défaut',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          '${spec.finalPrice.toStringAsFixed(0)} MRU',
                          style: TextStyle(
                            color: spec.hasPromo ? AppTheme.success : AppTheme.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        if (spec.hasPromo) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${spec.prix.toStringAsFixed(0)} MRU',
                            style: const TextStyle(
                              color: AppTheme.textTertiary,
                              fontSize: 12,
                              decoration: TextDecoration.lineThrough,
                            ),
                          ),
                        ],
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: spec.inStock ? AppTheme.success.withOpacity(0.1) : AppTheme.accent.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Stock: ${spec.quantiteStock}',
                            style: TextStyle(
                              color: spec.inStock ? AppTheme.success : AppTheme.accent,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Bouton éditer
              IconButton(
                onPressed: () {
                  _showSuccessSnackBar('Édition de spécification - Bientôt disponible ! 🚀');
                },
                icon: const Icon(Icons.edit_outlined, size: 20),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.zaffre.withOpacity(0.1),
                  foregroundColor: AppTheme.zaffre,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModernSection(
    String title,
    IconData icon,
    LinearGradient gradient,
    List<Widget> children,
  ) {
    return Container(
      decoration: AppTheme.cardModern,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header de section
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            decoration: BoxDecoration(
              gradient: gradient.colors.first.withOpacity(0.1) != null
                  ? LinearGradient(
                      colors: [
                        gradient.colors.first.withOpacity(0.1),
                        gradient.colors.last.withOpacity(0.05),
                      ],
                    )
                  : null,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppTheme.radiusLarge),
                topRight: Radius.circular(AppTheme.radiusLarge),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: gradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: gradient.colors.first.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: AppTheme.spacingM),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          
          // Contenu
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, size: 16, color: Colors.white),
                ),
                const SizedBox(width: AppTheme.spacingS),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
              boxShadow: AppTheme.elevationLow,
            ),
            child: TextFormField(
              controller: controller,
              maxLines: maxLines,
              keyboardType: keyboardType,
              style: const TextStyle(
                fontSize: 16,
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(
                  color: AppTheme.textTertiary,
                  fontWeight: FontWeight.w400,
                ),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.2)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  borderSide: const BorderSide(color: AppTheme.zaffre, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  borderSide: const BorderSide(color: AppTheme.accent, width: 2),
                ),
                contentPadding: const EdgeInsets.all(20),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Ce champ est requis';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernCategorySelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingS),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: AppTheme.purpleGradient,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.category_rounded, size: 16, color: Colors.white),
                ),
                const SizedBox(width: AppTheme.spacingS),
                const Text(
                  'Catégorie (optionnel)',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Consumer<CategoryProvider>(
            builder: (context, categoryProvider, child) {
              if (categoryProvider.isLoading) {
                return Container(
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                    boxShadow: AppTheme.elevationLow,
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  boxShadow: AppTheme.elevationLow,
                ),
                child: DropdownButtonFormField<models.Category>(
                  value: _selectedCategory,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(20),
                    hintText: 'Aucune catégorie (optionnel)',
                    hintStyle: const TextStyle(
                      color: AppTheme.textTertiary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  dropdownColor: Colors.white,
                  items: [
                    // Option "Aucune catégorie"
                    const DropdownMenuItem<models.Category>(
                      value: null,
                      child: Text(
                        'Aucune catégorie',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w400,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                    // Catégories disponibles
                    ...categoryProvider.categories
                        .map((category) => DropdownMenuItem<models.Category>(
                              value: category,
                              child: Text(
                                category.nom,
                                style: const TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ))
                        .toList(),
                  ],
                  onChanged: (models.Category? newCategory) {
                    setState(() {
                      _selectedCategory = newCategory;
                    });
                  },
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSpectacularUpdateButton() {
    return Container(
      width: double.infinity,
      height: 60,
      decoration: BoxDecoration(
        gradient: _isLoading ? AppTheme.lightGradient : AppTheme.neonGradient,
        borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
        boxShadow: _isLoading ? AppTheme.elevationLow : AppTheme.neonShadow,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _isLoading ? null : _updateProduct,
          borderRadius: BorderRadius.circular(AppTheme.radiusXLarge),
          child: Center(
            child: _isLoading
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Mise à jour...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.save_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Mettre à Jour',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Future<void> _pickAndUploadImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    
    if (pickedFiles.isNotEmpty) {
      setState(() => _isUploadingImage = true);
      
      try {
        final productProvider = context.read<ProductProvider>();
        
        for (int i = 0; i < pickedFiles.length; i++) {
          debugPrint('📸 Upload nouvelle image ${i + 1}/${pickedFiles.length}');
          
          final file = File(pickedFiles[i].path);
          final imageUrl = await productProvider.uploadProductImage(file);
          
          if (imageUrl != null && imageUrl.isNotEmpty) {
            final imageData = {
              'url_image': imageUrl,
              'est_principale': false, // Les nouvelles images ne sont pas principales par défaut
              'ordre': widget.product.images.length + _newUploadedImages.length,
            };
            
            setState(() {
              _newUploadedImages.add(imageData);
            });
            
            debugPrint('✅ Nouvelle image ${i + 1} uploadée: $imageUrl');
          } else {
            debugPrint('❌ Échec upload nouvelle image ${i + 1}');
            if (mounted) {
              _showErrorSnackBar('Erreur upload image ${i + 1}');
            }
          }
        }
        
        if (mounted) {
          _showSuccessSnackBar('${pickedFiles.length} nouvelle(s) image(s) uploadée(s) avec succès');
        }
      } catch (e) {
        debugPrint('❌ Erreur upload nouvelles images: $e');
        if (mounted) {
          _showErrorSnackBar('Erreur upload: $e');
        }
      } finally {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  Future<void> _updateProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final productProvider = context.read<ProductProvider>();

      debugPrint('🔄 Mise à jour du produit...');
      
      // Mettre à jour les informations de base
      final success = await productProvider.updateProduct(
        productId: widget.product.id,
        nom: _nomController.text,
        description: _descriptionController.text,
        reference: _referenceController.text,
        categoryId: _selectedCategory?.id,
      );

      if (success) {
        // TODO: Ici on pourrait aussi ajouter les nouvelles images au produit
        // via l'API si nécessaire
        
        if (mounted) {
          debugPrint('✅ Produit mis à jour avec succès !');
          _showSuccessSnackBar('Produit mis à jour avec succès ! 🎉');
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          debugPrint('❌ Échec mise à jour produit: ${productProvider.errorMessage}');
          _showErrorSnackBar('Erreur: ${productProvider.errorMessage}');
        }
      }
    } catch (e) {
      debugPrint('❌ Exception lors de la mise à jour: $e');
      if (mounted) {
        _showErrorSnackBar('Erreur: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.white24,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.accent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nomController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    super.dispose();
  }
}
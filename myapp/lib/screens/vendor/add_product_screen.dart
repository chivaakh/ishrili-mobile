// screens/vendor/add_product_screen.dart - INTERFACE WEB EXACTE 🚀✨
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category_model.dart' as models;
import '../../config/theme_config.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  final _formKey = GlobalKey<FormState>();
  
  // Contrôleurs pour les informations de base
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();
  
  // Gestion des onglets
  int _currentTabIndex = 0;
  
  // Gestion des images
  List<Map<String, dynamic>> _uploadedImages = [];
  bool _isUploadingImage = false;
  
  // Gestion des spécifications
  List<Map<String, dynamic>> _specifications = [];
  int _currentSpecificationIndex = 0;
  
  // Contrôleurs pour les spécifications
  final _specNomController = TextEditingController();
  final _specDescController = TextEditingController();
  final _specReferenceController = TextEditingController();
  final _prixController = TextEditingController();
  final _prixPromoController = TextEditingController();
  final _stockController = TextEditingController();
  bool _isDefaultSpec = false;
  
  // États
  bool _isLoading = false;
  models.Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
    
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    });
    
    _animationController = AnimationController(
      duration: AppTheme.animationMedium,
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: AppTheme.animationCurve),
    );

    // Ajouter première spécification par défaut
    _addNewSpecificationTab();

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
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // 🎨 Header moderne
              _buildModernHeader(),
              
              // 📑 Onglets comme le web
              _buildWebStyleTabs(),
              
              // 📝 Contenu des onglets
              Expanded(
                child: _isLoading
                    ? _buildLoadingState()
                    : FadeTransition(
                        opacity: _fadeAnimation,
                        child: _buildTabContent(),
                      ),
              ),
              
              // 🚀 Boutons d'action
              _buildActionButtons(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernHeader() {
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
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ajouter un nouveau produit',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  'Créez votre produit étape par étape',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebStyleTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLarge),
        boxShadow: AppTheme.elevationLow,
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.white,
        unselectedLabelColor: AppTheme.textSecondary,
        indicator: BoxDecoration(
          gradient: AppTheme.primaryGradient,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        indicatorPadding: const EdgeInsets.all(4),
        dividerColor: Colors.transparent,
        isScrollable: true, // ✅ AJOUT: Permet le scroll horizontal
        tabAlignment: TabAlignment.start, // ✅ AJOUT: Alignement à gauche
        tabs: [
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.info_outline, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Infos', // ✅ RACCOURCI: Texte plus court
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.image_outlined, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Images (${_uploadedImages.length})',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
          Tab(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.tune_rounded, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Specs (${_specifications.length})', // ✅ RACCOURCI: Texte plus court
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildInformationsTab(),
        _buildImagesTab(),
        _buildSpecificationsTab(),
      ],
    );
  }

  Widget _buildInformationsTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildWebTextField(
              controller: _nomController,
              label: 'Nom du produit',
              hint: 'Saisissez le nom de votre produit',
              required: true,
            ),
            
            _buildWebTextField(
              controller: _descriptionController,
              label: 'Description',
              hint: 'Décrivez votre produit, ses caractéristiques et avantages',
              required: true,
              maxLines: 5,
            ),
            
            _buildWebTextField(
              controller: _referenceController,
              label: 'Référence',
              hint: 'Référence unique du produit',
              required: true,
            ),
            
            _buildCategorySelector(),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Images du produit',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: AppTheme.elevationLow,
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _isUploadingImage ? null : _pickAndUploadImages,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.add, color: Colors.white, size: 16),
                          const SizedBox(width: 8),
                          const Text(
                            'Ajouter une image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingXL),
          
          // Images grid
          if (_uploadedImages.isEmpty)
            _buildEmptyImagesState()
          else
            _buildImagesGrid(),
          
          const SizedBox(height: AppTheme.spacingL),
          
          // Upload area
          _buildImageUploadArea(),
        ],
      ),
    );
  }

  Widget _buildSpecificationsTab() {
    return Column(
      children: [
        // Spécifications header avec navigation
        if (_specifications.length > 1) _buildSpecificationNavigation(),
        
        // Contenu de la spécification courante
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppTheme.spacingL),
            child: _buildCurrentSpecificationForm(),
          ),
        ),
        
        // Bouton ajouter nouvelle spécification
        Container(
          padding: const EdgeInsets.all(AppTheme.spacingL),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _addNewSpecificationTab,
                  icon: const Icon(Icons.add),
                  label: const Text('Ajouter une spécification'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    side: BorderSide(color: AppTheme.zaffre.withOpacity(0.3)),
                    foregroundColor: AppTheme.zaffre,
                  ),
                ),
              ),
              if (_specifications.length > 1) ...[
                const SizedBox(width: AppTheme.spacingM),
                IconButton(
                  onPressed: _removeCurrentSpecification,
                  icon: const Icon(Icons.delete_outline),
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.accent.withOpacity(0.1),
                    foregroundColor: AppTheme.accent,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSpecificationNavigation() {
    return Container(
      height: 50,
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingL, vertical: AppTheme.spacingS),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _specifications.length,
        itemBuilder: (context, index) {
          final isSelected = index == _currentSpecificationIndex;
          final spec = _specifications[index];
          
          return GestureDetector(
            onTap: () => _switchToSpecification(index),
            child: Container(
              margin: const EdgeInsets.only(right: 8),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: isSelected ? AppTheme.primaryGradient : null,
                color: isSelected ? null : Colors.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                border: Border.all(
                  color: isSelected ? Colors.transparent : Colors.grey.withOpacity(0.3),
                ),
                boxShadow: isSelected ? AppTheme.elevationLow : null,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (spec['est_defaut'] == true)
                    Icon(
                      Icons.star,
                      size: 16,
                      color: isSelected ? Colors.white : AppTheme.warning,
                    ),
                  if (spec['est_defaut'] == true) const SizedBox(width: 4),
                  Text(
                    'Spécification ${index + 1}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrentSpecificationForm() {
    if (_specifications.isEmpty) return const SizedBox.shrink();
    
    final spec = _specifications[_currentSpecificationIndex];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header avec numéro
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${_currentSpecificationIndex + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingM),
            Text(
              'Spécification ${_currentSpecificationIndex + 1}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppTheme.textPrimary,
              ),
            ),
            const Spacer(),
            if (_specifications.length > 1)
              IconButton(
                onPressed: _removeCurrentSpecification,
                icon: const Icon(Icons.delete_outline),
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.accent.withOpacity(0.1),
                  foregroundColor: AppTheme.accent,
                ),
              ),
          ],
        ),
        
        const SizedBox(height: AppTheme.spacingXL),
        
        // Formulaire
        Row(
          children: [
            Expanded(
              child: _buildWebTextField(
                controller: TextEditingController(text: spec['nom'] ?? ''),
                label: 'Nom',
                hint: 'Nom de cette variante ou spécification',
                required: true,
                onChanged: (value) {
                  _specifications[_currentSpecificationIndex]['nom'] = value;
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacingL),
            Expanded(
              child: _buildWebTextField(
                controller: TextEditingController(text: spec['reference_specification'] ?? ''),
                label: 'Référence',
                hint: 'Référence de cette spécification',
                onChanged: (value) {
                  _specifications[_currentSpecificationIndex]['reference_specification'] = value;
                },
              ),
            ),
          ],
        ),
        
        Row(
          children: [
            Expanded(
              child: _buildWebTextField(
                controller: TextEditingController(text: spec['prix']?.toString() ?? ''),
                label: 'Prix (MRU)',
                hint: 'Prix en Ouguiya',
                required: true,
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _specifications[_currentSpecificationIndex]['prix'] = double.tryParse(value) ?? 0.0;
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacingL),
            Expanded(
              child: _buildWebTextField(
                controller: TextEditingController(text: spec['prix_promo']?.toString() ?? ''),
                label: 'Prix promo (MRU)',
                hint: 'Prix promotionnel (optionnel)',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _specifications[_currentSpecificationIndex]['prix_promo'] = 
                      value.isNotEmpty ? double.tryParse(value) : null;
                },
              ),
            ),
          ],
        ),
        
        Row(
          children: [
            Expanded(
              child: _buildWebTextField(
                controller: TextEditingController(text: spec['quantite_stock']?.toString() ?? ''),
                label: 'Stock',
                hint: '0',
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  _specifications[_currentSpecificationIndex]['quantite_stock'] = int.tryParse(value) ?? 0;
                },
              ),
            ),
            const SizedBox(width: AppTheme.spacingL),
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Row(
                  children: [
                    Checkbox(
                      value: spec['est_defaut'] ?? false,
                      onChanged: (value) {
                        setState(() {
                          // Retirer le défaut des autres
                          for (var s in _specifications) {
                            s['est_defaut'] = false;
                          }
                          // Mettre ce spec comme défaut
                          _specifications[_currentSpecificationIndex]['est_defaut'] = value ?? false;
                        });
                      },
                      activeColor: AppTheme.zaffre,
                    ),
                    const Text(
                      'Specs par défaut',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
        
        _buildWebTextField(
          controller: TextEditingController(text: spec['description'] ?? ''),
          label: 'Description',
          hint: 'Détails spécifiques à cette variante',
          maxLines: 3,
          onChanged: (value) {
            _specifications[_currentSpecificationIndex]['description'] = value;
          },
        ),
      ],
    );
  }

  Widget _buildWebTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = false,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppTheme.textPrimary,
              ),
              children: [
                if (required)
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(color: AppTheme.accent),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            onChanged: onChanged,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(
                color: AppTheme.textTertiary,
                fontSize: 14,
              ),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppTheme.zaffre, width: 1.5),
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
            validator: required ? (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est requis';
              }
              return null;
            } : null,
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catégorie',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Consumer<CategoryProvider>(
            builder: (context, categoryProvider, child) {
              return Container(
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: DropdownButtonFormField<models.Category>(
                  value: _selectedCategory,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(12),
                    hintText: 'Sélectionnez une catégorie',
                  ),
                  dropdownColor: Colors.white,
                  items: categoryProvider.categories
                      .map((category) => DropdownMenuItem<models.Category>(
                            value: category,
                            child: Text(category.nom),
                          ))
                      .toList(),
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

  Widget _buildEmptyImagesState() {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 48,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune image ajoutée',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagesGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _uploadedImages.length,
      itemBuilder: (context, index) {
        final imageData = _uploadedImages[index];
        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  imageData['url_image'],
                  width: double.infinity,
                  height: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              if (imageData['est_principale'] == true)
                Positioned(
                  top: 4,
                  left: 4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.success,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Principal',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => setState(() => _uploadedImages.removeAt(index)),
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildImageUploadArea() {
    return GestureDetector(
      onTap: _isUploadingImage ? null : _pickAndUploadImages,
      child: Container(
        width: double.infinity,
        height: 100,
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: Colors.grey[300]!,
            style: BorderStyle.solid,
          ),
        ),
        child: _isUploadingImage
            ? const Center(
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 32,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Ajouter la première image',
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingL),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                side: BorderSide(color: Colors.grey[400]!),
              ),
              child: const Text(
                'Annuler',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingM),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _isLoading ? null : _saveProduct,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Center(
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Créer',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                  ),
                ),
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
            'Création en cours...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  // ✅ MÉTHODES DE GESTION DES SPÉCIFICATIONS

  void _addNewSpecificationTab() {
    setState(() {
      _specifications.add({
        'nom': '',
        'description': '',
        'reference_specification': '${_referenceController.text}-${(_specifications.length + 1).toString().padLeft(3, '0')}',
        'prix': 0.0,
        'prix_promo': null,
        'quantite_stock': 0,
        'est_defaut': _specifications.isEmpty, // Premier = défaut
      });
      _currentSpecificationIndex = _specifications.length - 1;
    });
  }

  void _switchToSpecification(int index) {
    setState(() {
      _currentSpecificationIndex = index;
    });
  }

  void _removeCurrentSpecification() {
    if (_specifications.length <= 1) return;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer la spécification'),
        content: Text('Voulez-vous supprimer la spécification ${_currentSpecificationIndex + 1} ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _specifications.removeAt(_currentSpecificationIndex);
                
                // Ajuster l'index si nécessaire
                if (_currentSpecificationIndex >= _specifications.length) {
                  _currentSpecificationIndex = _specifications.length - 1;
                }
                
                // S'assurer qu'il y a toujours une spécification par défaut
                if (!_specifications.any((s) => s['est_defaut'] == true) && _specifications.isNotEmpty) {
                  _specifications[0]['est_defaut'] = true;
                }
              });
              Navigator.pop(context);
            },
            style: TextButton.styleFrom(foregroundColor: AppTheme.accent),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  // ✅ MÉTHODES DE GESTION DES IMAGES

  Future<void> _pickAndUploadImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    
    if (pickedFiles.isNotEmpty) {
      setState(() => _isUploadingImage = true);
      
      try {
        final productProvider = context.read<ProductProvider>();
        
        for (int i = 0; i < pickedFiles.length; i++) {
          debugPrint('📸 Upload image ${i + 1}/${pickedFiles.length}');
          
          final file = File(pickedFiles[i].path);
          final imageUrl = await productProvider.uploadProductImage(file);
          
          if (imageUrl != null && imageUrl.isNotEmpty) {
            final imageData = {
              'url_image': imageUrl,
              'est_principale': _uploadedImages.isEmpty, // Première = principale
              'ordre': _uploadedImages.length,
            };
            
            setState(() {
              _uploadedImages.add(imageData);
            });
            
            debugPrint('✅ Image ${i + 1} uploadée: $imageUrl');
          } else {
            debugPrint('❌ Échec upload image ${i + 1}');
            if (mounted) {
              _showErrorSnackBar('Erreur upload image ${i + 1}');
            }
          }
        }
        
        if (mounted) {
          _showSuccessSnackBar('${pickedFiles.length} image(s) uploadée(s) avec succès');
        }
      } catch (e) {
        debugPrint('❌ Erreur upload images: $e');
        if (mounted) {
          _showErrorSnackBar('Erreur upload: $e');
        }
      } finally {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  // ✅ SAUVEGARDE DU PRODUIT

  Future<void> _saveProduct() async {
    // Valider l'onglet informations de base
    if (!_formKey.currentState!.validate()) {
      setState(() {
        _tabController.index = 0; // Retourner à l'onglet informations
      });
      _showErrorSnackBar('Veuillez remplir tous les champs obligatoires dans les informations de base');
      return;
    }

    // Vérifier qu'il y a au moins une spécification
    if (_specifications.isEmpty) {
      setState(() {
        _tabController.index = 2; // Aller à l'onglet spécifications
      });
      _showErrorSnackBar('Veuillez ajouter au moins une spécification');
      return;
    }

    // Vérifier que les spécifications ont des données valides
    bool hasValidSpec = false;
    for (var spec in _specifications) {
      if ((spec['nom'] ?? '').isNotEmpty && (spec['prix'] ?? 0.0) > 0) {
        hasValidSpec = true;
        break;
      }
    }

    if (!hasValidSpec) {
      setState(() {
        _tabController.index = 2;
      });
      _showErrorSnackBar('Veuillez remplir au moins une spécification complète (nom et prix)');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final productProvider = context.read<ProductProvider>();
      
      // Nettoyer les spécifications vides
      final validSpecifications = _specifications.where((spec) {
        return (spec['nom'] ?? '').isNotEmpty && (spec['prix'] ?? 0.0) > 0;
      }).map((spec) {
        return {
          'nom': spec['nom'] ?? '',
          'description': spec['description'] ?? '',
          'prix': spec['prix'] ?? 0.0,
          'prix_promo': spec['prix_promo'],
          'quantite_stock': spec['quantite_stock'] ?? 0,
          'est_defaut': spec['est_defaut'] ?? false,
          'reference_specification': spec['reference_specification'] ?? '${_referenceController.text}-001',
        };
      }).toList();

      debugPrint('📋 Spécifications valides: ${validSpecifications.length}');
      debugPrint('📸 Images uploadées: ${_uploadedImages.length}');

      final success = await productProvider.createProduct(
        nom: _nomController.text,
        description: _descriptionController.text,
        reference: _referenceController.text,
        categoryId: _selectedCategory?.id,
        specifications: validSpecifications,
        images: _uploadedImages,
      );

      if (success) {
        if (mounted) {
          debugPrint('✅ Produit créé avec ${validSpecifications.length} spécifications !');
          _showSuccessSnackBar('Produit créé avec ${validSpecifications.length} variante(s) ! 🎉');
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          _showErrorSnackBar('Erreur: ${productProvider.errorMessage}');
        }
      }
    } catch (e) {
      debugPrint('❌ Exception lors de la création: $e');
      if (mounted) {
        _showErrorSnackBar('Erreur: $e');
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ✅ MÉTHODES D'AFFICHAGE DES MESSAGES

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
    _tabController.dispose();
    _animationController.dispose();
    _nomController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    _specNomController.dispose();
    _specDescController.dispose();
    _specReferenceController.dispose();
    _prixController.dispose();
    _prixPromoController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}
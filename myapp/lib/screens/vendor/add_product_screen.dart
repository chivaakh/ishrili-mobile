// screens/vendor/add_product_screen.dart - IMPORT CATEGORY CORRIGÉ
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category_model.dart' as models; // ← AJOUT du préfixe

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _referenceController = TextEditingController();
  
  // Spécification par défaut
  final _specNomController = TextEditingController();
  final _specDescController = TextEditingController();
  final _prixController = TextEditingController();
  final _stockController = TextEditingController();
  
  List<File> _selectedImages = [];
  bool _isLoading = false;
  models.Category? _selectedCategory; // ← Utilisation du préfixe

  @override
  void initState() {
    super.initState();
    // Charger les catégories au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CategoryProvider>().loadCategories();
    });
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
        title: const Text(
          'Ajouter Produit',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: false,
        actions: [
          if (!_isLoading)
            TextButton(
              onPressed: _saveProduct,
              child: const Text(
                'Publier',
                style: TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black87),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section Images
                    _buildSectionTitle('Photos du produit'),
                    _buildImageSection(),
                    
                    const SizedBox(height: 32),
                    
                    // Informations de base
                    _buildSectionTitle('Informations de base'),
                    _buildTextField(
                      controller: _nomController,
                      label: 'Nom du produit',
                      hint: 'Ex: iPhone 16 Pro',
                    ),
                    _buildTextField(
                      controller: _referenceController,
                      label: 'Référence',
                      hint: 'Ex: REF-001',
                    ),
                    
                    // ✅ AJOUT : Sélection de catégorie
                    _buildCategorySelector(),
                    
                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Décrivez votre produit...',
                      maxLines: 3,
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Spécification principale
                    _buildSectionTitle('Prix et stock'),
                    _buildTextField(
                      controller: _specNomController,
                      label: 'Variante',
                      hint: 'Ex: Couleur Noir',
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _prixController,
                            label: 'Prix (MRU)',
                            hint: '1000',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _stockController,
                            label: 'Stock',
                            hint: '10',
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 40),
                    
                    // Bouton de création
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _saveProduct,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
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
                                'Créer le produit',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // ✅ Widget de sélection de catégorie avec préfixe
  Widget _buildCategorySelector() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Catégorie',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Consumer<CategoryProvider>(
            builder: (context, categoryProvider, child) {
              if (categoryProvider.isLoading) {
                return Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }

              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<models.Category>( // ← Utilisation du préfixe
                    value: _selectedCategory,
                    isExpanded: true,
                    hint: Text(
                      'Sélectionnez une catégorie',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
                    items: categoryProvider.categories
                        .map((category) => DropdownMenuItem<models.Category>( // ← Utilisation du préfixe
                              value: category,
                              child: Text(category.nom),
                            ))
                        .toList(),
                    onChanged: (models.Category? newCategory) { // ← Utilisation du préfixe
                      setState(() {
                        _selectedCategory = newCategory;
                      });
                    },
                  ),
                ),
              );
            },
          ),
        ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey[400]),
              filled: true,
              fillColor: Colors.grey[50],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: Colors.grey[200]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Colors.black87),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Ce champ est obligatoire';
              }
              return null;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_selectedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _selectedImages.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.only(right: 12),
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImages[index],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
                        child: GestureDetector(
                          onTap: () => setState(() => _selectedImages.removeAt(index)),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
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
          ),
        
        const SizedBox(height: 16),
        
        GestureDetector(
          onTap: _pickImages,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.add_photo_alternate_outlined,
                  size: 32,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  _selectedImages.isEmpty 
                      ? 'Ajouter des photos' 
                      : 'Ajouter plus de photos',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickImages() async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage();
    
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _selectedImages.addAll(pickedFiles.map((xFile) => File(xFile.path)));
      });
    }
  }



Future<void> _saveProduct() async {
  if (!_formKey.currentState!.validate()) return;

  setState(() => _isLoading = true);

  try {
    final productProvider = context.read<ProductProvider>();
    
    // ✅ 1. Upload des images d'abord et DEBUG
    List<Map<String, dynamic>> imagesList = [];
    debugPrint('📸 Début upload de ${_selectedImages.length} images');
    
    for (int i = 0; i < _selectedImages.length; i++) {
      debugPrint('📸 Upload image ${i + 1}/${_selectedImages.length}');
      
      final imageUrl = await productProvider.uploadProductImage(_selectedImages[i]);
      debugPrint('🔗 URL reçue pour image ${i + 1}: $imageUrl');
      
      if (imageUrl != null && imageUrl.isNotEmpty) {
        final imageData = {
          'url_image': imageUrl,
          'est_principale': i == 0, // Première image = principale
          'ordre': i,
        };
        imagesList.add(imageData);
        debugPrint('✅ Image ${i + 1} ajoutée: $imageData');
      } else {
        debugPrint('❌ Échec upload image ${i + 1}');
      }
    }

    debugPrint('📸 Total images uploadées: ${imagesList.length}');

    // ✅ 2. Créer la spécification avec DEBUG
    List<Map<String, dynamic>> specifications = [];
    if (_specNomController.text.isNotEmpty && _prixController.text.isNotEmpty) {
      final specData = {
        'nom': _specNomController.text,
        'description': _specDescController.text,
        'prix': double.parse(_prixController.text),
        'quantite_stock': int.parse(_stockController.text.isEmpty ? '0' : _stockController.text),
        'est_defaut': true,
        'reference_specification': '${_referenceController.text}-001',
      };
      specifications.add(specData);
      debugPrint('📋 Spécification créée: $specData');
    }

    // ✅ 3. Créer le produit avec DEBUG
    debugPrint('🏗️ Création du produit...');
    debugPrint('📦 Nom: ${_nomController.text}');
    debugPrint('📦 Images: ${imagesList.length}');
    debugPrint('📦 Spécifications: ${specifications.length}');
    debugPrint('📦 Catégorie ID: ${_selectedCategory?.id}');

    final success = await productProvider.createProduct(
      nom: _nomController.text,
      description: _descriptionController.text,
      reference: _referenceController.text,
      categoryId: _selectedCategory?.id,
      specifications: specifications,
      images: imagesList, // ← IMPORTANT : Passer les images
    );

    if (success) {
      if (mounted) {
        debugPrint('✅ Produit créé avec succès !');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produit créé avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        debugPrint('❌ Échec création produit: ${productProvider.errorMessage}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${productProvider.errorMessage}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  } catch (e) {
    debugPrint('❌ Exception lors de la création: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

  @override
  void dispose() {
    _nomController.dispose();
    _descriptionController.dispose();
    _referenceController.dispose();
    _specNomController.dispose();
    _specDescController.dispose();
    _prixController.dispose();
    _stockController.dispose();
    super.dispose();
  }
}
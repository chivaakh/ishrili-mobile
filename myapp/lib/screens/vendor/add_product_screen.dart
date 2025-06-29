// screens/vendor/add_product_screen.dart - UPLOAD IMMÉDIAT DES IMAGES ✅
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/product_provider.dart';
import '../../providers/category_provider.dart';
import '../../models/category_model.dart' as models;

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
  
  // ✅ CHANGEMENT : Stocker les URLs au lieu des fichiers
  List<Map<String, dynamic>> _uploadedImages = [];
  bool _isLoading = false;
  bool _isUploadingImage = false; // ✅ NOUVEAU : État d'upload d'image
  models.Category? _selectedCategory;

  @override
  void initState() {
    super.initState();
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
                  child: DropdownButton<models.Category>(
                    value: _selectedCategory,
                    isExpanded: true,
                    hint: Text(
                      'Sélectionnez une catégorie',
                      style: TextStyle(color: Colors.grey[400]),
                    ),
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

  // ✅ SECTION IMAGES MODIFIÉE POUR AFFICHER LES IMAGES UPLOADÉES
  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_uploadedImages.isNotEmpty)
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _uploadedImages.length,
              itemBuilder: (context, index) {
                final imageData = _uploadedImages[index];
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
                        child: Image.network(
                          imageData['url_image'],
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[200],
                              child: const Icon(Icons.error),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                        loadingProgress.expectedTotalBytes!
                                    : null,
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 6,
                        right: 6,
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
                              size: 14,
                            ),
                          ),
                        ),
                      ),
                      // ✅ Badge pour indiquer l'image principale
                      if (imageData['est_principale'] == true)
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Principal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w500,
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
          onTap: _isUploadingImage ? null : _pickAndUploadImages,
          child: Container(
            width: double.infinity,
            height: 120,
            decoration: BoxDecoration(
              color: _isUploadingImage ? Colors.grey[100] : Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
                width: 1,
              ),
            ),
            child: _isUploadingImage
                ? const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text(
                        'Upload en cours...',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
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
                        _uploadedImages.isEmpty 
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

  // ✅ NOUVELLE MÉTHODE : Sélectionner ET uploader immédiatement les images
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
              'est_principale': _uploadedImages.isEmpty, // Première image = principale
              'ordre': _uploadedImages.length,
            };
            
            setState(() {
              _uploadedImages.add(imageData);
            });
            
            debugPrint('✅ Image ${i + 1} uploadée: $imageUrl');
          } else {
            debugPrint('❌ Échec upload image ${i + 1}');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Erreur upload image ${i + 1}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${pickedFiles.length} image(s) uploadée(s) avec succès'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        debugPrint('❌ Erreur upload images: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur upload: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        setState(() => _isUploadingImage = false);
      }
    }
  }

  // ✅ MÉTHODE DE SAUVEGARDE SIMPLIFIÉE (plus d'upload ici)
  Future<void> _saveProduct() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final productProvider = context.read<ProductProvider>();
      
      // ✅ Les images sont déjà uploadées, on les utilise directement
      debugPrint('📸 Images déjà uploadées: ${_uploadedImages.length}');
      for (var img in _uploadedImages) {
        debugPrint('🔗 Image: ${img['url_image']}');
      }

      // ✅ Créer la spécification
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

      // ✅ Créer le produit avec les images déjà uploadées
      debugPrint('🏗️ Création du produit...');
      final success = await productProvider.createProduct(
        nom: _nomController.text,
        description: _descriptionController.text,
        reference: _referenceController.text,
        categoryId: _selectedCategory?.id,
        specifications: specifications,
        images: _uploadedImages, // ✅ Images déjà uploadées avec URLs
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
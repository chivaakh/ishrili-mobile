import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../services/auth_service.dart';

class SignupScreen extends StatefulWidget {
  @override
  _SignupScreenState createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _prenom = TextEditingController();
  final _nom = TextEditingController();
  final _email = TextEditingController();
  final _tel = TextEditingController();
  final _pwd = TextEditingController();
  final _confirmPwd = TextEditingController();
  
  // Contrôleurs pour les détails client
  final _clientNom = TextEditingController();
  final _clientPrenom = TextEditingController();
  final _clientAdresse = TextEditingController();
  final _clientVille = TextEditingController();
  final _clientCodePostal = TextEditingController();
  final _clientPays = TextEditingController();
  
  // Contrôleurs pour les détails commerçant
  final _nomBoutique = TextEditingController();
  final _descriptionBoutique = TextEditingController();
  final _adresseCommerciale = TextEditingController();
  final _commercantVille = TextEditingController();
  final _commercantCodePostal = TextEditingController();
  final _commercantPays = TextEditingController();
  
  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;
  String? _selectedUserType; // 'client' ou 'commercant'
  
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _prenom.dispose();
    _nom.dispose();
    _email.dispose();
    _tel.dispose();
    _pwd.dispose();
    _confirmPwd.dispose();
    _clientNom.dispose();
    _clientPrenom.dispose();
    _clientAdresse.dispose();
    _clientVille.dispose();
    _clientCodePostal.dispose();
    _clientPays.dispose();
    _nomBoutique.dispose();
    _descriptionBoutique.dispose();
    _adresseCommerciale.dispose();
    _commercantVille.dispose();
    _commercantCodePostal.dispose();
    _commercantPays.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'L\'email est requis';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email invalide';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le mot de passe est requis';
    }
    if (value.length < 6) {
      return 'Le mot de passe doit contenir au moins 6 caractères';
    }
    return null;
  }

  String? _validateConfirmPassword(String? value) {
    if (value != _pwd.text) {
      return 'Les mots de passe ne correspondent pas';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Le téléphone est requis';
    }
    if (!RegExp(r'^\+?[0-9]{8,15}$').hasMatch(value.replaceAll(' ', ''))) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }

  String? _validateRequired(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName est requis';
    }
    return null;
  }

  void _showUserTypeModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            'Type de compte',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Choisissez le type de compte que vous souhaitez créer',
                style: TextStyle(color: Colors.grey.shade600),
              ),
              SizedBox(height: 20),
              _buildUserTypeOption(
                'Client',
                'Pour acheter des produits',
                Icons.shopping_bag_outlined,
                Colors.blue,
                () => _selectUserType('client'),
              ),
              SizedBox(height: 16),
              _buildUserTypeOption(
                'Vendeur',
                'Pour vendre vos produits',
                Icons.store_outlined,
                Colors.green,
                () => _selectUserType('commercant'),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildUserTypeOption(String title, String subtitle, IconData icon, 
      MaterialColor color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color.shade600, size: 28),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: color.shade400, size: 18),
          ],
        ),
      ),
    );
  }

  void _selectUserType(String userType) {
    Navigator.pop(context);
    setState(() {
      _selectedUserType = userType;
    });
    
    if (userType == 'client') {
      _showClientDetailsModal();
    } else {
      _showCommercantDetailsModal();
    }
  }

  void _showClientDetailsModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.person_outline, color: Colors.blue.shade600),
              SizedBox(width: 8),
              Text('Informations Client'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModalTextField(_clientNom, 'Nom', Icons.person_outline),
                SizedBox(height: 16),
                _buildModalTextField(_clientPrenom, 'Prénom', Icons.person_outline),
                SizedBox(height: 16),
                _buildModalTextField(_clientAdresse, 'Adresse', Icons.location_on_outlined, maxLines: 2),
                SizedBox(height: 16),
                _buildModalTextField(_clientVille, 'Ville', Icons.location_city_outlined),
                SizedBox(height: 16),
                _buildModalTextField(_clientCodePostal, 'Code postal', Icons.local_post_office_outlined),
                SizedBox(height: 16),
                _buildModalTextField(_clientPays, 'Pays', Icons.public_outlined),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearClientFields();
                setState(() => _selectedUserType = null);
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Confirmer', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showCommercantDetailsModal() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Icon(Icons.store_outlined, color: Colors.green.shade600),
              SizedBox(width: 8),
              Text('Informations Vendeur'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModalTextField(_nomBoutique, 'Nom de la boutique', Icons.store_outlined),
                SizedBox(height: 16),
                _buildModalTextField(_descriptionBoutique, 'Description', Icons.description_outlined, maxLines: 3),
                SizedBox(height: 16),
                _buildModalTextField(_adresseCommerciale, 'Adresse commerciale', Icons.location_on_outlined, maxLines: 2),
                SizedBox(height: 16),
                _buildModalTextField(_commercantVille, 'Ville', Icons.location_city_outlined),
                SizedBox(height: 16),
                _buildModalTextField(_commercantCodePostal, 'Code postal', Icons.local_post_office_outlined),
                SizedBox(height: 16),
                _buildModalTextField(_commercantPays, 'Pays', Icons.public_outlined),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                _clearCommercantFields();
                setState(() => _selectedUserType = null);
                Navigator.pop(context);
              },
              child: Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade600,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text('Confirmer', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildModalTextField(TextEditingController controller, String label, 
      IconData icon, {int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey.shade600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  void _clearClientFields() {
    _clientNom.clear();
    _clientPrenom.clear();
    _clientAdresse.clear();
    _clientVille.clear();
    _clientCodePostal.clear();
    _clientPays.clear();
  }

  void _clearCommercantFields() {
    _nomBoutique.clear();
    _descriptionBoutique.clear();
    _adresseCommerciale.clear();
    _commercantVille.clear();
    _commercantCodePostal.clear();
    _commercantPays.clear();
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUserType == null) {
      _showErrorSnackBar('Veuillez choisir un type de compte');
      return;
    }

    if (!_acceptTerms) {
      _showErrorSnackBar('Veuillez accepter les conditions d\'utilisation');
      return;
    }

    // Validation des champs spécifiques selon le type d'utilisateur
    if (_selectedUserType == 'client') {
      if (_clientNom.text.trim().isEmpty || _clientPrenom.text.trim().isEmpty) {
        _showErrorSnackBar('Veuillez remplir tous les champs client obligatoires');
        return;
      }
    } else if (_selectedUserType == 'commercant') {
      if (_nomBoutique.text.trim().isEmpty) {
        _showErrorSnackBar('Veuillez remplir le nom de la boutique');
        return;
      }
    }

    setState(() => _loading = true);
    try {
      Map<String, dynamic> userData = {
        'email': _email.text.trim(),
        'mot_de_passe': _pwd.text,
        'telephone': _tel.text.trim(),
        'role': _selectedUserType,
      };

      // Ajouter les détails spécifiques selon le type
      if (_selectedUserType == 'client') {
        userData['details_client'] = {
          'nom': _clientNom.text.trim(),
          'prenom': _clientPrenom.text.trim(),
          'adresse': _clientAdresse.text.trim(),
          'ville': _clientVille.text.trim(),
          'code_postal': _clientCodePostal.text.trim(),
          'pays': _clientPays.text.trim(),
        };
      } else {
        userData['details_commercant'] = {
          'nom_boutique': _nomBoutique.text.trim(),
          'description_boutique': _descriptionBoutique.text.trim(),
          'adresse_commerciale': _adresseCommerciale.text.trim(),
          'ville': _commercantVille.text.trim(),
          'code_postal': _commercantCodePostal.text.trim(),
          'pays': _commercantPays.text.trim(),
          'est_verifie': false,
          'note_moyenne': 0.0,
          'commission_rate': 5.0, // valeur par défaut
        };
      }

      await AuthService().signupWithDetails(userData);
      
      _showSuccessSnackBar('Inscription réussie ! Vous pouvez maintenant vous connecter.');
      Navigator.pop(context);
    } on DioException catch (e) {
      String errorMessage = 'Erreur lors de l\'inscription';
      
      if (e.response?.data != null) {
        final payload = e.response!.data;
        if (payload is Map<String, dynamic>) {
          List<String> errors = [];
          payload.forEach((key, value) {
            if (value is List) {
              errors.addAll(value.map((e) => e.toString()));
            } else {
              errors.add(value.toString());
            }
          });
          errorMessage = errors.join('\n');
        } else {
          errorMessage = payload.toString();
        }
      }
      _showErrorSnackBar(errorMessage);
    } catch (e) {
      _showErrorSnackBar(e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 4),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade400,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.blue.shade600),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Inscription',
          style: TextStyle(
            color: Colors.blue.shade600,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Form(
            key: _formKey,
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              children: [
                // En-tête
                Container(
                  margin: EdgeInsets.only(bottom: 30),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [Colors.green.shade400, Colors.blue.shade600],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.shade200,
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.person_add_outlined,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Créer un compte',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Rejoignez-nous en quelques étapes',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Indicateur du type de compte sélectionné
                if (_selectedUserType != null)
                  Container(
                    margin: EdgeInsets.only(bottom: 20),
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _selectedUserType == 'client' 
                          ? Colors.blue.shade50 
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _selectedUserType == 'client' 
                            ? Colors.blue.shade200 
                            : Colors.green.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          _selectedUserType == 'client' 
                              ? Icons.shopping_bag_outlined 
                              : Icons.store_outlined,
                          color: _selectedUserType == 'client' 
                              ? Colors.blue.shade600 
                              : Colors.green.shade600,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Compte ${_selectedUserType == 'client' ? 'Client' : 'Vendeur'}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() => _selectedUserType = null);
                            _showUserTypeModal();
                          },
                          child: Text(
                            'Changer',
                            style: TextStyle(
                              color: Colors.blue.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Champs du formulaire
                _buildCustomTextField(
                  controller: _email,
                  label: 'Email',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: _validateEmail,
                ),

                SizedBox(height: 20),

                _buildCustomTextField(
                  controller: _tel,
                  label: 'Téléphone',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: _validatePhone,
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s-]')),
                  ],
                ),

                SizedBox(height: 20),

                _buildCustomTextField(
                  controller: _pwd,
                  label: 'Mot de passe',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  validator: _validatePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),

                SizedBox(height: 20),

                _buildCustomTextField(
                  controller: _confirmPwd,
                  label: 'Confirmer le mot de passe',
                  icon: Icons.lock_outline,
                  obscureText: _obscureConfirmPassword,
                  validator: _validateConfirmPassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),

                SizedBox(height: 20),

                // Bouton de sélection du type de compte
                GestureDetector(
                  onTap: _showUserTypeModal,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.shade200,
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.account_circle_outlined, color: Colors.grey.shade600),
                        SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            _selectedUserType == null 
                                ? 'Choisir le type de compte'
                                : 'Type: ${_selectedUserType == 'client' ? 'Client' : 'Vendeur'}',
                            style: TextStyle(
                              fontSize: 16,
                              color: _selectedUserType == null 
                                  ? Colors.grey.shade600 
                                  : Colors.grey.shade800,
                              fontWeight: _selectedUserType == null 
                                  ? FontWeight.normal 
                                  : FontWeight.w500,
                            ),
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: 20),

                // Checkbox conditions d'utilisation
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                  padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Row(
                    children: [
                      Checkbox(
                        value: _acceptTerms,
                        onChanged: (value) {
                          setState(() {
                            _acceptTerms = value ?? false;
                          });
                        },
                        activeColor: Colors.blue.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      Expanded(
                        child: RichText(
                          text: TextSpan(
                            style: TextStyle(color: Colors.grey.shade700),
                            children: [
                              TextSpan(text: 'J\'accepte les '),
                              TextSpan(
                                text: 'conditions d\'utilisation',
                                style: TextStyle(
                                  color: Colors.blue.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(text: ' et la '),
                              TextSpan(
                                text: 'politique de confidentialité',
                                style: TextStyle(
                                  color: Colors.blue.shade600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(height: 30),

                // Bouton d'inscription
                _buildPrimaryButton(
                  onPressed: _loading ? null : _submit,
                  child: _loading
                      ? SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'S\'inscrire',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),

                SizedBox(height: 30),

                // Lien de connexion
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Déjà un compte ? ',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Text(
                        'Se connecter',
                        style: TextStyle(
                          color: Colors.blue.shade600,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
    String? Function(String?)? validator,
    TextCapitalization textCapitalization = TextCapitalization.none,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        inputFormatters: inputFormatters,
        validator: validator,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(icon, color: Colors.grey.shade600),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
          fillColor: Colors.white,
          filled: true,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback? onPressed,
    required Widget child,
  }) {
    return Container(
      height: 56,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: onPressed != null
              ? [Colors.green.shade400, Colors.blue.shade600]
              : [Colors.grey.shade300, Colors.grey.shade400],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: onPressed != null
            ? [
                BoxShadow(
                  color: Colors.blue.shade200,
                  blurRadius: 15,
                  offset: Offset(0, 8),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: child,
      ),
    );
  }
}
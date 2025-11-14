import 'package:eco_granel_app/login/inicio_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // NECESARIO PARA FIRESTORE
import 'package:eco_granel_app/main.dart';

const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF424242);
const Color _primaryOrange = Color.fromRGBO(184, 94, 44, 1);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Añadimos la referencia a Firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Función de registro de usuario
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Crear el usuario en Firebase Authentication (Email y Contraseña)
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      // 2. Obtener el usuario y el UID
      User? user = userCredential.user;
      if (user != null) {
        final uid = user.uid;
        final String fullName =
            '${_nameController.text.trim()} ${_lastNameController.text.trim()}';

        // 3. GUARDAR LOS DATOS DE PERFIL EN FIRESTORE (PASO AÑADIDO)
        await _firestore.collection('users').doc(uid).set({
          'fullName': fullName, // Nombre y Apellido
          'username': _usernameController.text.trim(), // Alias
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Opcional: Establecer el nombre completo en Firebase Auth (para fines de depuración/compatibilidad)
        await user.updateDisplayName(_usernameController.text.trim());
      }

      // 4. Navegar a la pantalla principal
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const EcoGranel()),
          (Route<dynamic> route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'weak-password') {
        message = 'La contraseña es demasiado débil.';
      } else if (e.code == 'email-already-in-use') {
        message = 'El correo ya está registrado.';
      } else if (e.code == 'invalid-email') {
        message = 'El formato del correo es inválido.';
      } else {
        message = 'Error de registro. Por favor, inténtalo de nuevo.';
      }

      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocurrió un error inesperado: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Widget para crear los campos de texto estandarizados (sin cambios)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    String? Function(String?)? validator,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hintText,
        border: const OutlineInputBorder(
          borderRadius: BorderRadius.all(Radius.circular(12.0)),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: const Color(0xFFF5F5F5),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16.0,
          horizontal: 12.0,
        ),
        suffixIcon: suffixIcon,
      ),
      validator: validator,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Regístrate',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            fontFamily: "roboto",
            color: _unselectedDarkColor,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
            color: _unselectedDarkColor,
          ),
          onPressed: () => Navigator.of(context).pop(InicioScreen),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const SizedBox(height: 10),
              Center(
                child: SizedBox(
                  width: 220,
                  height: 50,
                  child: Image.asset(
                    'assets/images/logo_ecogranel.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              const SizedBox(height: 40),

              // Campo Nombre
              _buildTextField(
                controller: _nameController,
                hintText: 'Nombre',
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa tu nombre.' : null,
              ),
              const SizedBox(height: 16),

              // Campo Apellido
              _buildTextField(
                controller: _lastNameController,
                hintText: 'Apellidos',
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa tu apellido.' : null,
              ),
              const SizedBox(height: 16),

              // Campo Correo
              _buildTextField(
                controller: _emailController,
                hintText: 'Correo electrónico',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value!.isEmpty || !value.contains('@')) {
                    return 'Ingresa un correo válido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Campo Usuario
              _buildTextField(
                controller: _usernameController,
                hintText: 'Nombre de usuario',
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa un nombre de usuario.' : null,
              ),
              const SizedBox(height: 16),

              // Campo Contraseña
              _buildTextField(
                controller: _passwordController,
                hintText: 'Contraseña',
                obscureText: !_showPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                    color: _unselectedDarkColor.withAlpha(153),
                  ),
                  onPressed: () {
                    setState(() {
                      _showPassword = !_showPassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value!.isEmpty || value.length < 6) {
                    return 'La contraseña debe tener al menos 6 caracteres.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RichText(
                  text: const TextSpan(
                    text:
                        'Al continuar, aceptas los términos y condiciones de uso. Lea ',
                    style: TextStyle(
                      color: _unselectedDarkColor,
                      fontFamily: "roboto",
                      fontSize: 13,
                    ),
                    children: <TextSpan>[
                      TextSpan(
                        text: 'aquí',
                        style: TextStyle(
                          color: _primaryOrange,
                          fontFamily: "roboto",
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                      TextSpan(text: ' la política de privacidad.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontFamily: "roboto",
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Botón Registrarme
              ElevatedButton(
                onPressed: _isLoading ? null : _signUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _primaryGreen,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.0,
                        ),
                      )
                    : const Text(
                        'Registrarme',
                        style: TextStyle(
                          fontSize: 18,
                          fontFamily: "roboto",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

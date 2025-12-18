//import 'package:eco_granel_app/login/inicio_screen.dart';
// Importamos la librería de gestos para poder hacer clic en partes específicas del texto
import 'package:flutter/gestures.dart';
import 'package:eco_granel_app/screens/condiciones_screen.dart';
import 'package:eco_granel_app/screens/privacidad_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // NECESARIO PARA FIRESTORE
//import 'package:eco_granel_app/main.dart';

const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF424242);
const Color _primaryOrange = Color.fromRGBO(184, 94, 44, 1);
// NUEVA CONSTANTE DE COLOR PARA EL TEXTO DE TÉRMINOS
const Color _termsTextColor = Color(0xFF424242); // Un color gris oscuro

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
  // NUEVO ESTADO PARA EL CHECKBOX
  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Función de registro de usuario con verificación de email
  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate() || !_acceptedTerms) {
      if (!_acceptedTerms) {
        setState(() {
          _errorMessage = 'Debes aceptar los Términos y Condiciones.';
        });
      }
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Crear el usuario en Firebase Authentication
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      User? user = userCredential.user;

      if (user != null) {
        // 2. ENVIAR CORREO DE VERIFICACIÓN (Usa la plantilla de tu imagen)
        await user.sendEmailVerification();

        final uid = user.uid;
        final String fullName =
            '${_nameController.text.trim()} ${_lastNameController.text.trim()}';

        // 3. Guardar datos en Firestore
        await _firestore.collection('users').doc(uid).set({
          'fullName': fullName,
          'username': _usernameController.text.trim(),
          'email': _emailController.text.trim(),
          'createdAt': FieldValue.serverTimestamp(),
          'emailVerified': false, // Marcamos como no verificado inicialmente
        });

        await user.updateDisplayName(_usernameController.text.trim());

        // 4. CERRAR SESIÓN Y MOSTRAR DIÁLOGO
        // Firebase loguea al usuario al crear cuenta, pero debemos sacarlo hasta que verifique
        await _auth.signOut();

        if (mounted) {
          _showVerificationDialog();
        }
      }
    } on FirebaseAuthException catch (e) {
      // ... (Tus validaciones de errores de Firebase permanecen igual)
      setState(() {
        _errorMessage = _handleAuthError(e.code);
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error inesperado: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Función auxiliar para mostrar el aviso al usuario
  void _showVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Obliga al usuario a interactuar con el botón
      builder: (BuildContext dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text('Verifica tu correo'),
        content: Text(
          'Hemos enviado un enlace de confirmación a ${_emailController.text.trim()}. '
          'Por favor, revisa tu bandeja de entrada (o spam) antes de iniciar sesión.',
        ),
        actions: [
          TextButton(
            onPressed: () {
              // 1. Cerramos el diálogo
              Navigator.pop(dialogContext);

              // 2. Hacemos "pop" hasta que lleguemos a la primera ruta (InicioScreen)
              // Esto hace que la pantalla de registro se deslice hacia afuera
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
            child: const Text(
              'Entendido',
              style: TextStyle(
                color: _primaryGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Opcional: Limpiar el catch de errores para que sea más legible
  String _handleAuthError(String code) {
    switch (code) {
      case 'weak-password':
        return 'La contraseña es demasiado débil.';
      case 'email-already-in-use':
        return 'El correo ya está registrado.';
      case 'invalid-email':
        return 'El formato del correo es inválido.';
      default:
        return 'Error de registro. Inténtalo de nuevo.';
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

  // Se usó la constante de color para facilitar el cambio.
  Widget _buildTermsAndPrivacyText() {
    return RichText(
      text: TextSpan(
        text: 'He leído y acepto los ',
        style: const TextStyle(
          color: _termsTextColor,
          fontFamily: "roboto",
          fontSize: 16,
          height: 1.2,
        ),
        children: <TextSpan>[
          TextSpan(
            text: 'Términos y Condiciones',
            style: TextStyle(
              color: _primaryOrange,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            // *** GESTURE RECOGNIZER PARA TÉRMINOS Y CONDICIONES ***
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // Navegar a CondicionesScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CondicionesScreen(),
                  ),
                );
              },
          ),
          const TextSpan(text: ' y la '),
          TextSpan(
            text: 'Política de privacidad',
            style: TextStyle(
              color: _primaryOrange,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
            ),
            // *** GESTURE RECOGNIZER PARA POLÍTICA DE PRIVACIDAD ***
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                // Navegar a PrivacidadScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrivacidadScreen(),
                  ),
                );
              },
          ),
          const TextSpan(
            // Se hereda el estilo principal, que ahora usa _termsTextColor
            text: ' de Eco Granel.',
          ),
        ],
      ),
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
          onPressed: () => Navigator.of(context).pop(),
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

              // ... (Campos de texto)
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
              // --- INICIO DE LA MODIFICACIÓN PARA TÉRMINOS Y CONDICIONES ---
              Row(
                crossAxisAlignment: CrossAxisAlignment
                    .start, // Asegura que el texto y el checkbox se alineen en la parte superior
                children: [
                  Container(
                    // Utilizamos un Container para dar la forma cuadrada al Checkbox
                    width: 30,
                    height: 30,
                    margin: const EdgeInsets.only(
                      right: 8.0,
                      top: 0.0,
                    ), // Espacio a la derecha
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors
                            .grey
                            .shade500, // Color del borde del cuadrado
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.circular(
                        4.0,
                      ), // Bordes ligeramente redondeados
                    ),
                    child: Checkbox(
                      value: _acceptedTerms,
                      onChanged: (bool? newValue) {
                        setState(() {
                          _acceptedTerms = newValue ?? false;
                        });
                      },
                      activeColor: Colors
                          .transparent, // Hacemos transparente el color de fondo cuando está marcado
                      checkColor: _primaryGreen, // Color del "check"
                      materialTapTargetSize: MaterialTapTargetSize
                          .shrinkWrap, // Reduce el área de toque
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                  // Se envuelve en Flexible para evitar un overflow de texto en pantallas pequeñas
                  Flexible(child: _buildTermsAndPrivacyText()),
                ],
              ),

              // --- ---
              const SizedBox(height: 24),

              // ---ajuste de align text y color en mensaje si no se acepta terminos y politicas---
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
                    textAlign: TextAlign
                        .start, // Aseguramos alineación a la izquierda si hay error
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

import 'package:eco_granel_app/login/inicio_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eco_granel_app/main.dart'; // Importa la pantalla principal para la navegación

// Definición de colores basada en el main.dart
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controladores de texto para los 5 campos
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

      // 2. Actualizar el perfil del usuario recién creado
      User? user = userCredential.user;
      if (user != null) {
        // Usamos updateDisplayName para guardar el Nombre de Usuario (@username)
        await user.updateDisplayName(_usernameController.text.trim());

        // NOTA: Para guardar Nombre y Apellido (y otros datos)
        // se recomienda usar Firestore o Realtime Database, por ejemplo:
        // await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        //   'firstName': _nameController.text.trim(),
        //   'lastName': _lastNameController.text.trim(),
        //   'username': _usernameController.text.trim(),
        //   'email': _emailController.text.trim(),
        //   'createdAt': FieldValue.serverTimestamp(),
        // });
      }

      // 3. Navegar a la pantalla principal (EcoGranel) o a la de Login
      if (mounted) {
        // Después de un registro exitoso, se navega al home
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

  // La función _launchPolicyUrl ha sido eliminada.

  // Widget para crear los campos de texto estandarizados
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
          borderRadius: BorderRadius.all(Radius.circular(8.0)),
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
          style: TextStyle(color: _unselectedDarkColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _unselectedDarkColor),
          // Al presionar atrás, lleva al Login (si está disponible)
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
              // Logo de Eco Granel
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'ECO',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Text(
                      'Granel',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _primaryOrange,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 50),

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
                hintText: 'Apellido',
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa tu apellido.' : null,
              ),
              const SizedBox(height: 16),

              // Campo Correo
              _buildTextField(
                controller: _emailController,
                hintText: 'anitaperez@gmail.com',
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
                hintText: '@anita_saludable',
                validator: (value) =>
                    value!.isEmpty ? 'Ingresa tu usuario.' : null,
              ),
              const SizedBox(height: 16),

              // Campo Contraseña
              _buildTextField(
                controller: _passwordController,
                hintText: '**********',
                obscureText: !_showPassword,
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword ? Icons.visibility : Icons.visibility_off,
                    // Uso de .withAlpha(153) para 0.6 de opacidad (255 * 0.6)
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

              // Texto de términos y condiciones/política de privacidad (SIN ENLACE FUNCIONAL)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: RichText(
                  text: TextSpan(
                    text:
                        'Al continuar, aceptas los términos y condiciones de uso. ',
                    style: const TextStyle(
                      color: _unselectedDarkColor,
                      fontSize: 13,
                    ),
                    children: <TextSpan>[
                      // Texto "aquí" sin funcionalidad de Tap
                      TextSpan(
                        text: 'aquí',
                        style: TextStyle(
                          color:
                              _primaryOrange, // Mantiene el color para destacar
                          fontWeight: FontWeight.bold,
                          decoration: TextDecoration.underline,
                        ),
                        // El recognizer: TapGestureRecognizer()..onTap = _launchPolicyUrl, fue eliminado.
                      ),
                      const TextSpan(text: ' la política de privacidad.'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Mostrar mensaje de error si existe
              if (_errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
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
                    borderRadius: BorderRadius.circular(8.0),
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

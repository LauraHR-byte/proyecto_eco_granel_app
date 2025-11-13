import 'package:eco_granel_app/login/inicio_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Importa las pantallas necesarias para la navegación, como la pantalla principal (EcoGranel).
import 'package:eco_granel_app/main.dart'; // Asume que EcoGranel está en main.dart

// Definición de colores basada en el main.dart
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF424242);
const Color _primaryOrange = Color.fromRGBO(
  184,
  94,
  44,
  1,
); // Color del carrito en AppBar

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  bool _showPassword = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Maneja el inicio de sesión con correo/contraseña
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Intenta iniciar sesión con correo y contraseña
      await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // Si el inicio de sesión es exitoso, navega a la pantalla principal (EcoGranel)
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const EcoGranel()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found') {
        message = 'No se encontró un usuario para ese correo.';
      } else if (e.code == 'wrong-password') {
        message = 'Contraseña incorrecta.';
      } else if (e.code == 'invalid-email') {
        message = 'El formato del correo es inválido.';
      } else {
        message = 'Error de inicio de sesión. Por favor, inténtalo de nuevo.';
      }

      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocurrió un error inesperado. ($e)';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Simulación de navegación a la pantalla de Registro
  void _goToSignUp() {
    // Implementar la navegación a la pantalla de registro (por ejemplo, RegisterScreen)
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Navegar a la pantalla de registro')),
    );
  }

  // Simulación de navegación a la pantalla de Olvidé mi Contraseña
  void _forgotPassword() {
    // Implementar la navegación a la pantalla de restablecimiento de contraseña
    // Navigator.of(context).push(MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Navegar a la pantalla de olvidé mi contraseña'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar similar al del diseño, con el botón de retroceso
      appBar: AppBar(
        title: const Text(
          'Iniciar Sesión',
          style: TextStyle(color: _unselectedDarkColor),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _unselectedDarkColor),
          onPressed: () =>
              Navigator.of(context).pop(InicioScreen), // O a donde corresponda
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
              const SizedBox(height: 50),
              // Logo de Eco Granel
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Asume que la parte "ECO" es un widget o texto estilizado
                    const Text(
                      'ECO',
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: _primaryGreen,
                      ),
                    ),
                    const SizedBox(width: 4),
                    // Asume que la parte "Granel" es un widget o texto estilizado
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

              // Campo de Email/Usuario
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'ej. anitaperez@gmail.com',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 16.0,
                    horizontal: 12.0,
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu correo o usuario.';
                  }
                  // Validación simple de formato de correo (necesario para signInWithEmailAndPassword)
                  if (!value.contains('@') || !value.contains('.')) {
                    // Nota: Si quieres aceptar 'usuario' sin '@', tendrías que
                    // implementar una lógica de mapeo con Firestore/RealtimeDB.
                    // Por ahora, asumimos que el campo principal es el correo.
                    // return 'Formato de correo inválido.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              // Campo de Contraseña
              TextFormField(
                controller: _passwordController,
                obscureText: !_showPassword,
                decoration: InputDecoration(
                  hintText: '**********',
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
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ingresa tu contraseña.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),

              // Botón Olvidé mi Contraseña
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: _forgotPassword,
                  child: const Text(
                    'Olvidé mi contraseña',
                    style: TextStyle(
                      color: Color(0xFFE53935),
                      fontWeight: FontWeight.bold,
                    ),
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

              // Botón Entrar
              ElevatedButton(
                onPressed: _isLoading ? null : _signIn,
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
                        'Entrar',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // Enlace ¿No Tienes Cuenta?
              TextButton(
                onPressed: _goToSignUp,
                child: Text(
                  '¿No Tienes Cuenta?',
                  style: TextStyle(
                    color: _primaryGreen.withAlpha(204),
                    decoration: TextDecoration.underline,
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

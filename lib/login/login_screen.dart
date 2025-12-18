import 'package:eco_granel_app/login/inicio_screen.dart';
import 'package:eco_granel_app/login/register_screen.dart';
import 'package:eco_granel_app/login/forgot_password_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
// Importa las pantallas necesarias para la navegación, como la pantalla principal (EcoGranel).
import 'package:eco_granel_app/main.dart'; // Asume que EcoGranel está en main.dart

const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);
const Color _orangeColor = Color(0xFFC76939);

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

  // Maneja el inicio de sesión con correo/contraseña y validación de verificación
  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // 1. Intenta iniciar sesión
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      User? user = userCredential.user;

      // 2. VALIDACIÓN DE CORREO VERIFICADO
      if (user != null) {
        // Recargamos el usuario para obtener el estado más reciente de Firebase
        await user.reload();
        user = _auth.currentUser; // Actualizamos la referencia tras el reload

        if (!user!.emailVerified) {
          // Si NO está verificado: cerramos sesión y lanzamos error
          await _auth.signOut();
          setState(() {
            _errorMessage =
                'Por favor, verifica tu correo electrónico antes de entrar. Revisa tu bandeja de entrada.';
            _isLoading = false;
          });
          return; // Detenemos la ejecución aquí
        }
      }

      // 3. Si llega aquí, está verificado: Navega a la pantalla principal
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const EcoGranel()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String message;
      if (e.code == 'user-not-found' || e.code == 'wrong-password') {
        message = 'Correo o contraseña incorrectos.';
      } else if (e.code == 'invalid-email') {
        message = 'El formato del correo es inválido.';
      } else if (e.code == 'user-disabled') {
        message = 'Esta cuenta ha sido deshabilitada.';
      } else {
        message = 'Error de inicio de sesión. Inténtalo de nuevo.';
      }

      setState(() {
        _errorMessage = message;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Ocurrió un error inesperado.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // >>> INICIO DEL CAMBIO: Navegación real a RegisterScreen
  void _goToSignUp() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const RegisterScreen()));
  }
  // <<< FIN DEL CAMBIO

  // Simulación de navegación a la pantalla de Olvidé mi Contraseña
  void _forgotPassword() {
    // CAMBIO CLAVE: Navegación real a la nueva pantalla
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar similar al del diseño, con el botón de retroceso
      appBar: AppBar(
        title: const Text(
          'Iniciar Sesión',
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
              const SizedBox(height: 10),
              // Logo de Eco Granel: Se inserta la imagen solicitada.
              Center(
                child: SizedBox(
                  width: 220, // Aumentado ligeramente el tamaño para el logo
                  height: 50,
                  // Se quita el color de fondo para que la imagen del logo se vea limpia
                  // decoration: BoxDecoration(
                  //   color: _primaryGreen.withAlpha(26),
                  //   borderRadius: BorderRadius.circular(20),
                  // ),
                  child: Image.asset(
                    'assets/images/logo_ecogranel.png', // Logo solicitado por el usuario
                    fit: BoxFit.contain, // Asegura que la imagen se ajuste
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Campo de Email/Usuario
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  hintText: 'Ingresa tu correo electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(12.0)),
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
                    return 'Ingresa tu correo electrónico.';
                  }
                  // Validación simple de formato de correo (necesario para signInWithEmailAndPassword)
                  if (!value.contains('@') || !value.contains('.')) {
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
                  hintText: 'Ingresa tu contraseña',
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
                      color: _orangeColor,
                      fontFamily: "roboto",
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
                        'Entrar',
                        style: TextStyle(
                          fontSize: 20,
                          fontFamily: "roboto",
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 24),

              // Enlace ¿No Tienes Cuenta? - Ajustado para tener subrayado del mismo color
              TextButton(
                onPressed: _goToSignUp,
                child: Text(
                  '¿No Tienes Cuenta?',
                  style: TextStyle(
                    fontFamily: "roboto",
                    fontSize: 16,
                    color: _primaryGreen, // Texto con el color primario
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                    // Subrayado del mismo color del texto
                    decorationColor: _primaryGreen,
                    // Aumenta el grosor para que se vea ligeramente más abajo
                    decorationThickness: 2.0,
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

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart'; // <--- Importar Firebase Auth

const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseAuth _auth =
      FirebaseAuth.instance; // <--- Instancia de FirebaseAuth

  // Función para mostrar mensajes al usuario
  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: isError ? Colors.red : _primaryGreen,
      ),
    );
  }

  Future<void> _sendPasswordResetEmail() async {
    final String email = _emailController.text.trim();

    if (email.isEmpty) {
      _showSnackBar('Por favor, ingresa tu correo electrónico.', isError: true);
      return;
    }

    // Opcional: Agregar validación de formato de email más estricta si es necesario
    // (e.g., usando regex o un paquete validador)

    try {
      // **1. Ejecuta la lógica de restablecimiento de Firebase.**
      // Firebase gestiona de forma segura si la cuenta existe.
      await _auth.sendPasswordResetEmail(email: email);

      // **2. Muestra un mensaje genérico de éxito.**
      // Es CRUCIAL que este mensaje sea genérico para evitar exponer si un email existe o no.
      _showSnackBar(
        'Si el correo electrónico está registrado, recibirás un enlace de restablecimiento.',
      );

      // Opcional: Navegar de vuelta o mostrar un diálogo de confirmación.
      // Navigator.of(context).pop();
    } on FirebaseAuthException catch (e) {
      // 3. Manejo de errores de Firebase.
      // A pesar del try-catch, por seguridad, Firebase a menudo envía errores mínimos
      // o ninguno. Sin embargo, este es el lugar para manejar, por ejemplo,
      // un error de 'invalid-email' si no se validó antes.

      String errorMessage = 'Ocurrió un error. Inténtalo de nuevo.';

      if (e.code == 'invalid-email') {
        errorMessage = 'El formato del correo electrónico no es válido.';
      } else if (e.code == 'user-not-found') {
        // Aunque Firebase intenta no lanzar 'user-not-found' para restablecimiento
        // si lo hiciera, por seguridad, NO debemos mostrarlo.
        // Mantenemos el mensaje genérico de éxito.
        _showSnackBar(
          'Si el correo electrónico está registrado, recibirás un enlace de restablecimiento.',
        );
        return; // Salir sin mostrar el mensaje de error
      }

      // Si es otro error no seguro de exponer.
      _showSnackBar(errorMessage, isError: true);
    } catch (e) {
      // 4. Otros errores (conexión, etc.)
      _showSnackBar('Error de conexión. Verifica tu internet.', isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(
          size: 30, //tamaño arrow
          color: _unselectedDarkColor,
        ),

        title: const Text(
          'Restablecer Contraseña',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            fontFamily: "roboto",
            color: _unselectedDarkColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: _unselectedDarkColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Ingresa tu correo electrónico para enviarte un enlace de restablecimiento de contraseña.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                hintText: 'Correo electrónico',
                // ... (Estilo de campo similar al de LoginScreen)
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _sendPasswordResetEmail,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: const Text(
                'Enviar Enlace',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Aquí iría la lógica de Firebase para enviar el correo de restablecimiento.
  final TextEditingController _emailController = TextEditingController();

  void _sendPasswordResetEmail() {
    // 1. Validar el email
    // 2. Usar FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text)
    // 3. Mostrar un SnackBar o un diálogo de éxito/error.

    // Placeholder de Simulación:
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Si la cuenta existe, se ha enviado un enlace a tu correo.',
        ),
      ),
    );
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

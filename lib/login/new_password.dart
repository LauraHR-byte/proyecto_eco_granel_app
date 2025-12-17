import 'package:flutter/material.dart';

// Definición de colores basada en el código original
const Color _primaryGreen = Color(0xFF4CAF50); // Verde principal
const Color _primaryOrange = Color(0xFFC76939);

// ----------------------------------------------------------------------
// *** Custom AppBar para el retorno ***
// ----------------------------------------------------------------------
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: Text(
        title,
        style: const TextStyle(
          color: _primaryGreen,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      // Icono de flecha hacia atrás en color verde
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: _primaryGreen),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

// ----------------------------------------------------------------------
// *** Nueva Pantalla: ResetPasswordScreen (Establecer Nueva Contraseña) ***
// ----------------------------------------------------------------------
class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  // Controladores para los campos de texto
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Variables para la visibilidad de las contraseñas
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Clave global para el formulario
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Función de validación de la contraseña
  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, ingrese su nueva contraseña';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  // Función de validación de la confirmación de contraseña
  String? _validateConfirmPassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor, confirme su nueva contraseña';
    }
    if (value != _passwordController.text) {
      return 'Las contraseñas no coinciden';
    }
    return null;
  }

  // Lógica de reseteo de contraseña (Simulación)
  void _resetPassword() {
    if (_formKey.currentState!.validate()) {
      // Si la validación es exitosa, se puede proceder con la lógica de autenticación
      if (_formKey.currentState!.validate()) {
        // *** Lógica para enviar la nueva contraseña al backend ***

        // Simulación de éxito
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              '✅ Contraseña restablecida con éxito. ¡Inicia sesión!',
            ),
            backgroundColor: _primaryGreen,
          ),
        );

        // Navegar de vuelta a la pantalla de Login (o a la pantalla de Inicio)
        // Se asume que deseas volver al Login para que el usuario pruebe su nueva contraseña.
        // Navigator.pushAndRemoveUntil(
        //   context,
        //   MaterialPageRoute(builder: (context) => const LoginScreen()), // Reemplaza con tu LoginScreen real
        //   (Route<dynamic> route) => false,
        // );
      }
    }
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white,
      // Usamos el CustomAppBar para la navegación y título
      appBar: const CustomAppBar(title: 'Restablecer Contraseña'),
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // --- 1. Sección Superior: Logo (pequeño) ---
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 20.0),
              child: SizedBox(
                width:
                    size.width * 0.7, // Logo más pequeño en la parte superior
                height: 50,
                // Asegúrate de tener esta imagen en 'assets/images/'
                child: Image.asset(
                  'assets/images/logo_ecogranel.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),

            // --- 2. Contenedor Principal del Formulario ---
            Padding(
              padding: const EdgeInsets.all(30.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // Título de la sección
                    const Text(
                      'Establece tu nueva contraseña',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: _primaryGreen,
                      ),
                    ),

                    const SizedBox(height: 10),

                    const Text(
                      'Ingresa y confirma la nueva clave de acceso para tu cuenta.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),

                    const SizedBox(height: 40),

                    // 1. Campo de Nueva Contraseña
                    TextFormField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      validator: _validatePassword,
                      decoration: InputDecoration(
                        labelText: 'Nueva Contraseña',
                        hintText: 'Mínimo 6 caracteres',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: _primaryGreen,
                            width: 2.0,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.lock,
                          color: _primaryGreen,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: _primaryGreen,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPasswordVisible = !_isPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // 2. Campo de Confirmar Contraseña
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      validator: _validateConfirmPassword,
                      decoration: InputDecoration(
                        labelText: 'Confirmar Contraseña',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.0),
                          borderSide: const BorderSide(
                            color: _primaryGreen,
                            width: 2.0,
                          ),
                        ),
                        prefixIcon: const Icon(
                          Icons.lock_reset,
                          color: _primaryGreen,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility
                                : Icons.visibility_off,
                            color: _primaryGreen,
                          ),
                          onPressed: () {
                            setState(() {
                              _isConfirmPasswordVisible =
                                  !_isConfirmPasswordVisible;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 50),

                    // 3. Botón para Restablecer Contraseña
                    ElevatedButton(
                      onPressed: _resetPassword,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _primaryOrange,
                        padding: const EdgeInsets.symmetric(vertical: 18.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Restablecer Contraseña',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

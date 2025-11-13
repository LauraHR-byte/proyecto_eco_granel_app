import 'package:flutter/material.dart';

// Importa las pantallas de autenticación
import 'package:eco_granel_app/login/login_screen.dart';
import 'package:eco_granel_app/login/register_screen.dart';

// Definición de colores basada en el main.dart y otros archivos
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _primaryOrange = Color.fromRGBO(184, 94, 44, 1);

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos el tamaño de la pantalla para calcular la altura de las olas
    final size = MediaQuery.of(context).size;

    // Altura del área de la curva (aproximadamente el 40% de la altura total)
    final double waveHeight = size.height * 0.45;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            // --- Sección Superior (Olas y Título) ---
            ClipPath(
              clipper: CustomWaveClipper(),
              child: Container(
                width: double.infinity,
                // Usamos la altura calculada para la sección de olas
                height: waveHeight,
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color.fromARGB(
                        255,
                        117,
                        185,
                        119,
                      ), // Verde más claro/suave
                      _primaryGreen,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 40), // Espacio para el status bar
                    // Logo de Eco Granel (adaptado del Register Screen)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'ECO',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Granel',
                          style: TextStyle(
                            fontSize: 38,
                            fontWeight: FontWeight.bold,
                            color: _primaryOrange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Título principal
                    const Text(
                      'Consumo\nconsciente',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // --- Sección Inferior (Botones) ---
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 40.0,
                vertical: 50.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // 1. Botón "Iniciar sesión"
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryOrange,
                      padding: const EdgeInsets.symmetric(vertical: 18.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 4,
                    ),
                    child: const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 80), // Espacio entre botones
                  // 2. Botón "Crear una cuenta con tu email" (Simula el texto pequeño)
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      'Crea una cuenta con tu email',
                      style: TextStyle(
                        fontSize: 16,
                        color: _primaryOrange,
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),

                  // NOTA: Se ha omitido la sección de "Acceso rápido con Google y Facebook"
                  // según lo solicitado.
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Clipper personalizado para replicar el diseño de onda verde
class CustomWaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    var path = Path();
    path.lineTo(0, size.height - 100);

    // Primera curva (Grande)
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 80);
    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    // Segunda curva (Pequeña)
    var secondControlPoint = Offset(size.width * 3 / 4, size.height - 160);
    var secondEndPoint = Offset(size.width, size.height - 60);
    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, size.height - 60);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

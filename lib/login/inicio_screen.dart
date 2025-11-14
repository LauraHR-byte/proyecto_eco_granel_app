import 'package:flutter/material.dart';

// Importa las pantallas de autenticación (manteniendo las importaciones originales)
// NOTA: Estas importaciones deben existir en el proyecto real.
import 'package:eco_granel_app/login/login_screen.dart';
import 'package:eco_granel_app/login/register_screen.dart';

// Definición de colores basada en el main.dart y otros archivos
const Color _primaryGreen = Color(0xFF4CAF50); // Verde principal
const Color _primaryOrange = Color.fromRGBO(
  184,
  94,
  44,
  1,
); // Naranja/Marrón principal

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Altura total de la sección superior (Columna de Logo Blanco + Texto Verde)
    final double topSectionTotalHeight = size.height * 0.75;

    // Altura de la sección del Logo (aprox. 35% de la sección superior)
    final double logoContainerHeight = topSectionTotalHeight * 0.35;

    // Altura de la sección del Texto (aprox. 65% de la sección superior)
    final double textContainerHeight = topSectionTotalHeight * 0.65;

    // Define el punto de inicio (top) de la tarjeta blanca de botones.
    // Se mantiene en 60% para asegurar el desplazamiento hacia abajo solicitado anteriormente.
    final double whiteCardStartPoint = size.height * 0.60;

    return Scaffold(
      backgroundColor: Colors.white,
      // Se utiliza Stack directamente para el diseño de capas
      body: Stack(
        children: <Widget>[
          // --- 1. Sección Superior (Dividida en Logo Blanco y Texto Verde) ---
          Column(
            children: [
              // A. Contenedor del Logo (Blanco con curva superior e inferior)
              Container(
                width: double.infinity,
                // Usamos la altura calculada
                height: logoContainerHeight,
                decoration: const BoxDecoration(
                  color: Colors.white, // Fondo blanco para el logo
                  borderRadius: BorderRadius.only(
                    // Aplicamos el mismo redondeo de 50.0 en las cuatro esquinas (SOLICITADO)
                    topLeft: Radius.circular(50.0),
                    topRight: Radius.circular(50.0),
                    bottomLeft: Radius.circular(50.0),
                    bottomRight: Radius.circular(50.0),
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // El Padding superior se gestiona internamente por el 'center' y el radio.
                    // Logo
                    Center(
                      child: SizedBox(
                        width: 220,
                        height: 50,
                        // Asegúrate de tener esta imagen en 'assets/images/'
                        child: Image.asset(
                          'assets/images/logo_ecogranel.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // B. Contenedor del Título (Verde)
              Container(
                width: double.infinity,
                // Usamos la altura calculada
                height: textContainerHeight,
                decoration: const BoxDecoration(
                  color: _primaryGreen, // Fondo verde para el título
                ),
                child: const Center(
                  child: Padding(
                    // Pequeño ajuste para centrar visualmente
                    padding: EdgeInsets.only(top: 20.0),
                    child: Text(
                      'Consumo\nconsciente',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),

          // --- 2. Sección Inferior Superpuesta (Tarjeta Blanca con Bordes Curvos - Botones) ---
          Positioned(
            // Utilizamos el punto de inicio calculado (60% de la pantalla) para mantener la tarjeta abajo.
            top: whiteCardStartPoint,
            left: 0,
            right: 0,
            child: Container(
              // La altura es el resto de la pantalla, asegurando que cubra el espacio restante
              height: size.height - whiteCardStartPoint,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(
                    50.0,
                  ), // Bordes superiores muy redondeados
                  topRight: Radius.circular(
                    50.0,
                  ), // Bordes superiores muy redondeados
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 40.0,
                  vertical:
                      60.0, // Aumentamos el padding superior para bajar los botones
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    // 1. Botón "Iniciar sesión"
                    ElevatedButton(
                      onPressed: () {
                        // Navegación a la pantalla de Login
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

                    // Espacio entre botones
                    const SizedBox(height: 30),

                    // 2. Botón "Crear una cuenta con tu email"
                    TextButton(
                      onPressed: () {
                        // Navegación a la pantalla de Register
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
                          decorationColor: _primaryOrange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

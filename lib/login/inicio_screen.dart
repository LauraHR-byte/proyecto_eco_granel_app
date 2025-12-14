import 'package:flutter/material.dart';

// Importa las pantallas de autenticación (manteniendo las importaciones originales)
// NOTA: Estas importaciones deben existir en el proyecto real.
import 'package:eco_granel_app/login/login_screen.dart';
import 'package:eco_granel_app/login/register_screen.dart';

// Definición de colores basada en el main.dart y otros archivos
const Color _primaryGreen = Color(0xFF4CAF50); // Verde principal
const Color _primaryOrange = Color.fromRGBO(184, 94, 44, 1);

// ----------------------------------------------------------------------
// *** AJUSTADO: Custom Clipper para la curva inferior (Arc Clipper) ***
// ----------------------------------------------------------------------
class LogoClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // 1. Iniciar en la esquina superior izquierda (0, 0)
    path.lineTo(0, size.height); // Línea hasta la esquina inferior izquierda

    // 2. Definir los puntos para la Curva de Bézier cuadrática (Curva única y suave)

    // Punto de Control (Control Point):

    final controlPoint = Offset(
      size.width * 0.5,
      size.height - 60,
    ); // 40 es la profundidad del arco
    //----------------------------------------------------
    // ---------------------------------------------------
    // AQUI AJUSTO QUE TAN PROFUNDA ES LA CURVA --------
    //-------------------------------------------
    //-------------------------------------------
    // Punto Final (End Point):
    // El punto final de la curva es la esquina inferior derecha.
    final endPoint = Offset(size.width, size.height);

    // Crear la curva desde el punto inferior izquierdo (que es size.height) hasta el punto final
    path.quadraticBezierTo(
      controlPoint.dx,
      controlPoint.dy,
      endPoint.dx,
      endPoint.dy,
    );

    // 3. Ir a la esquina superior derecha
    path.lineTo(size.width, 0);

    // 4. Cerrar el path (automáticamente cierra volviendo a (0, 0))
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
// ----------------------------------------------------------------------

class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    // Altura total de la sección superior (Columna de Logo Blanco + Texto Verde)
    final double topSectionTotalHeight = size.height * 0.70;

    // Altura de la sección del Logo (aprox. 45% de la sección superior)
    final double logoContainerHeight = topSectionTotalHeight * 0.40;

    // Altura de la sección del Texto (el resto)
    final double textContainerHeight =
        topSectionTotalHeight - logoContainerHeight;

    // Define el punto de inicio (top) de la tarjeta blanca de botones.
    final double whiteCardStartPoint = size.height * 0.58;

    return Scaffold(
      backgroundColor: _primaryGreen,
      body: Stack(
        children: <Widget>[
          // --- 1. Sección Superior (Dividida en Logo y Texto) ---
          Column(
            children: [
              // A. Contenedor del Logo (Ahora con ClipPath para la curva inferior)
              // ----------------------------------------------------------------------
              ClipPath(
                clipper:
                    LogoClipper(), // Aplicamos el clipper de la curva ajustado
                child: Container(
                  width: double.infinity,
                  height: logoContainerHeight,
                  decoration: const BoxDecoration(
                    color: Colors.white, //  fondo blanco
                  ),
                  child: Center(
                    child: Padding(
                      // Mantenemos un padding superior para centrar el logo correctamente
                      padding: const EdgeInsets.only(top: 40.0),
                      child: SizedBox(
                        width: 264,
                        height: 60,
                        // Asegúrate de tener esta imagen en 'assets/images/'
                        child: Image.asset(
                          'assets/images/logo_ecogranel.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // ----------------------------------------------------------------------

              // B. Contenedor del Título (Verde)
              Container(
                width: double.infinity,
                // Ajustamos la altura restante para el título
                height: textContainerHeight,
                decoration: const BoxDecoration(
                  color: _primaryGreen, // Fondo verde para el título
                ),
                child: Center(
                  // **AJUSTE SOLICITADO: Agregar Padding superior e inferior al título**
                  child: Padding(
                    padding: const EdgeInsets.only(
                      bottom: 130.0,
                    ), // Padding vertical añadido
                    child: const Text(
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
                color: Colors.white, // Esta tarjeta debe seguir siendo blanca
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
                      80.0, // Aumentamos el padding superior para bajar los botones
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
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        elevation: 4,
                      ),
                      child: const Text(
                        'Iniciar sesión',
                        style: TextStyle(
                          fontSize: 19,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Espacio entre botones
                    const SizedBox(height: 20),

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
                          fontSize: 18,
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

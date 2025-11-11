import 'package:flutter/material.dart';
import 'package:eco_granel_app/screens/somos_screen.dart';
// **PASO 1: Importar la nueva pantalla de Ubicaciones**
import 'package:eco_granel_app/screens/ubicaciones_screen.dart';
// Asegúrate de que la ruta sea correcta

// Definimos el color verde primario para el tema (usando formato ARGB de 8 dígitos)
const Color _primaryGreen = Color(0xFF4CAF50);
// Definición del color oscuro para títulos (gris casi negro)
const Color _unselectedDarkColor = Color(0xFF333333);

// HomeScreen debe recibir el callback de navegación
class HomeScreen extends StatelessWidget {
  final Function(int) onNavigate;

  const HomeScreen({super.key, required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Sección "Descubre" (Banner Principal)
            _DiscoverSection(onNavigate: onNavigate),

            // Sección "Productos Destacados"
            // Pasamos el callback a _FeaturedProductsSection
            _FeaturedProductsSection(onNavigate: onNavigate),
            Divider(
              color: Color.fromRGBO(224, 224, 224, 100), // Color gris claro
              height: 50, // Espacio vertical que ocupa el divisor
              thickness: 5, // Grosor de la línea
              indent: 0, // Aseguramos que no haya indentación inicial
              endIndent: 0, // Aseguramos que no haya indentación final
            ),
            // Sección "Quiénes Somos"
            const _AboutUsSection(),

            SizedBox(height: 30), // Espacio final
          ],
        ),
      ),
    );
  }
}

// -----------------------------------------------------
// --- 1. Seccion Descubre (Banner Principal) ---
// -----------------------------------------------------
// **AJUSTE: _DiscoverSection ahora acepta el callback de navegación**
class _DiscoverSection extends StatelessWidget {
  final Function(int) onNavigate;

  const _DiscoverSection({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      height: screenWidth * 0.68, // Alto fijo basado en el ancho (ajustable)
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        // El color sólido para el banner se define aquí
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: Color.fromRGBO(224, 224, 224, 100),
          width: 4.0,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(224, 224, 224, 100),
            blurRadius: 1,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Contenido del Banner
          Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                const Text(
                  "Encuéntranos en tu ciudad",
                  style: TextStyle(
                    color: _unselectedDarkColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    fontFamily: "roboto",
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  "Nuestro carro sostenible llega a los barrios con"
                  " productos a granel, desayunos y snacks"
                  " conscientes."
                  "\n\nDescubre cuándo estaremos cerca"
                  " de ti.",
                  style: TextStyle(
                    color: _unselectedDarkColor,
                    fontFamily: "roboto",
                    fontWeight: FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 20),
                // Botón de Llamada a la Acción (CTA)
                Align(
                  alignment: Alignment.centerLeft,
                  // **AJUSTE: Pasamos la acción de navegación al botón**
                  child: _CtaButton(
                    label: "Ver Ubicaciones",
                    // Implementamos la navegación a la nueva pantalla aquí
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const UbicacionesScreen(),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Botón de Llamada a la Acción (Reutilizable)
// **AJUSTE: El botón ahora recibe un VoidCallback para la acción**
class _CtaButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed; // Nuevo callback para la acción del botón

  const _CtaButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // **AJUSTE: Usamos el callback onPressed recibido**
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2, // Sombra sutil del botón
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: "roboto",
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// --- 2. Seccion Productos Destacados (Scroll Horizontal) ---
// ----------------------------------------------------------------------
// (código de _FeaturedProductsSection, _ProductCard y _AboutUsSection)
class _FeaturedProductsSection extends StatelessWidget {
  final Function(int) onNavigate;

  const _FeaturedProductsSection({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    // Lista de datos simulada para productos
    const List<Map<String, String>> products = [
      {
        'name': 'Avena en Hojuelas',
        'price': '\$750 COP / 50g',
        'imagePath': 'assets/images/avena-hojuelas.jpg',
      },
      {
        'name': 'Harina de Almendra',
        'price': '\$5.600 COP / 50g',
        'imagePath': 'assets/images/harina-de-almendras.jpg',
      },
      {
        'name': 'Semillas de Chía',
        'price': '\$1.400 COP / 20g',
        'imagePath': 'assets/images/chia.jpg',
      },
      {
        'name': 'Garbanzos',
        'price': '\$400 COP / 50g',
        'imagePath': 'assets/images/garbanzos.jpg',
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 10.0),
          child: Text(
            "Productos Destacados",
            style: TextStyle(
              fontFamily: "roboto",
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _unselectedDarkColor,
            ),
          ),
        ),
        // Lista horizontal de productos
        SizedBox(
          height: 220, // Altura fija para el scroll horizontal
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return _ProductCard(
                name: product['name']!,
                price: product['price']!,
                imagePath: product['imagePath']!,
                isFirst: index == 0,
                onTap: () => onNavigate(2),
              );
            },
          ),
        ),
      ],
    );
  }
}

// ProductCard debe recibir el onTap y usarlo
class _ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String imagePath;
  final bool isFirst;
  final VoidCallback onTap; // Propiedad para el callback

  const _ProductCard({
    required this.name,
    required this.price,
    required this.imagePath,
    this.isFirst = false,
    required this.onTap, // Requerimos el callback
  });

  @override
  Widget build(BuildContext context) {
    // Ejecuta la navegación (cambio de índice) al hacer tap
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 150,
        margin: EdgeInsets.only(
          left: isFirst ? 18.0 : 8.0,
          right: 8.0,
          bottom: 10.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: const [
            BoxShadow(
              color: _unselectedDarkColor,
              blurRadius: 3,
              offset: Offset(0, 0),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // **CORRECCIÓN 2.1: Implementación de Image.asset para mostrar la imagen**
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
              child: Image.asset(
                imagePath, // Usa la ruta del producto
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 120,
                  // CORREGIDO: Usando .withAlpha(25) en caso de error
                  color: _primaryGreen.withAlpha(25),
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.image_not_supported,
                    color: _primaryGreen,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: "roboto",
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    price,
                    style: const TextStyle(
                      color: _primaryGreen,
                      fontFamily: "roboto",
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------
// --- 3. Seccion Quiénes Somos ---
// ----------------------------------------------------
class _AboutUsSection extends StatelessWidget {
  const _AboutUsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            "¿Quiénes Somos?",
            style: TextStyle(
              fontFamily: "roboto",
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _unselectedDarkColor,
            ),
          ),
          const SizedBox(height: 10),

          // Imagen "Quiénes Somos"
          Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.asset(
                'assets/images/somos.jpg', // RUTA DE TU IMAGEN "ACERCA DE"
                width: MediaQuery.of(context).size.width * 0.9,
                height: 260,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  height: 180,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    // CORREGIDO: Usando .withAlpha(51) en caso de error
                    color: _primaryGreen.withAlpha(51),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.info_outline,
                    size: 60,
                    color: _primaryGreen,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 15),

          Container(
            padding: const EdgeInsets.all(6.0),
            decoration: const BoxDecoration(
              color: Colors.white, // Fondo sutil
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "En Eco Granel creemos que cada pequeña decisión puede generar un gran cambio. "
                  "Nacimos con la misión de promover un consumo consciente y sostenible, ofreciendo "
                  "alimentos frescos y de alta calidad a granel.",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "roboto",
                    height: 1.5,
                    color: _unselectedDarkColor,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  "Te invitamos a comprar solo la cantidad que necesitas, reduciendo el desperdicio"
                  "y el impacto ambiental. Más que una tienda, somos un espacio que inspira a vivir"
                  "de manera más saludable y en armonia con el planeta.",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "roboto",
                    height: 1.5,
                    color: _unselectedDarkColor,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Botón para ir a la página completa de "Sobre Nosotros"
          Center(
            child: TextButton(
              onPressed: () {
                // Implementación de navegación a la nueva pantalla SomosScreen
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SomosScreen()),
                );
              },
              child: const Text(
                "Leer más sobre nuestra misión... →",
                style: TextStyle(
                  color: _primaryGreen,
                  fontFamily: "roboto",
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

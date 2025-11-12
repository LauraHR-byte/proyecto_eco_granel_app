import 'package:flutter/material.dart';
import 'package:eco_granel_app/screens/somos_screen.dart';
// PASO 1: Importar la nueva pantalla de Ubicaciones
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
// AJUSTE: _DiscoverSection ahora acepta el callback de navegación
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
                const SizedBox(height: 8),
                // Botón de Llamada a la Acción (CTA)
                Align(
                  alignment: Alignment.centerLeft,
                  // AJUSTE: Pasamos la acción de navegación al botón
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
// AJUSTE: El botón ahora recibe un VoidCallback para la acción
class _CtaButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed; // Nuevo callback para la acción del botón

  const _CtaButton({required this.label, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // AJUSTE: Usamos el callback onPressed recibido
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
class _FeaturedProductsSection extends StatelessWidget {
  final Function(int) onNavigate;

  const _FeaturedProductsSection({required this.onNavigate});

  @override
  Widget build(BuildContext context) {
    // Lista de datos simulada para productos
    // Los datos de la home ahora incluyen el peso para un diseño unificado
    const List<Map<String, String>> products = [
      {
        'name': 'Avena en Hojuelas',
        'price': '\$750 COP',
        'weight': '50g', // Agregamos peso
        'imagePath': 'assets/images/avena-hojuelas.jpg',
      },
      {
        'name': 'Harina de Almendra',
        'price': '\$5.600 COP',
        'weight': '50g', // Agregamos peso
        'imagePath': 'assets/images/harina-de-almendras.jpg',
      },
      {
        'name': 'Semillas de Chía',
        'price': '\$1.400 COP',
        'weight': '20g', // Agregamos peso
        'imagePath': 'assets/images/chia.jpg',
      },
      {
        'name': 'Garbanzos',
        'price': '\$400 COP',
        'weight': '50g', // Agregamos peso
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
          // La altura debe ajustarse para el nuevo diseño de tarjeta unificada
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              // **AJUSTE: Usamos el nuevo widget _ProductCardUnified**
              return _ProductCardUnified(
                name: product['name']!,
                price: product['price']!,
                weight: product['weight']!, // Pasamos el peso
                imagePath: product['imagePath']!,
                isFirst: index == 0,
                // El onTap navega a la tienda (índice 2)
                onTap: () => onNavigate(2),
              );
            },
          ),
        ),
      ],
    );
  }
}

// -------------------------------------------------------------------
// --- NUEVO Componente de Tarjeta de Producto Unificado (Home) ---
// -------------------------------------------------------------------
// Basado en el diseño de TiendaScreen, pero sin el botón '+' y con InkWell
class _ProductCardUnified extends StatelessWidget {
  final String name;
  final String price;
  final String weight; // Nuevo: Para unificar el diseño de precio/peso
  final String imagePath;
  final bool isFirst;
  final VoidCallback onTap;

  const _ProductCardUnified({
    required this.name,
    required this.price,
    required this.weight,
    required this.imagePath,
    this.isFirst = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos Card y InkWell para replicar el diseño y animación de TiendaScreen
    return Container(
      height: 50,
      width: 150, // Mantenemos el ancho del Producto Destacado
      margin: EdgeInsets.only(
        left: isFirst ? 18.0 : 3.0,
        right: 8.0,
        bottom: 10.0,
      ),
      child: Card(
        elevation: 2, // Mantenemos la elevación del Card de TiendaScreen
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            12,
          ), // Radio del Card de TiendaScreen
          side: BorderSide.none,
        ),
        child: InkWell(
          onTap: onTap, // Acción al hacer tap
          borderRadius: BorderRadius.circular(
            12,
          ), // Radio para el efecto de InkWell
          child: Padding(
            padding: const EdgeInsets.only(
              bottom: 8.0,
            ), // Padding inferior para el contenido
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. Imagen del Producto:
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.asset(
                    imagePath,
                    height: 130, // Altura ajustada para el nuevo diseño
                    width: double.infinity,
                    fit: BoxFit.cover,
                    // Manejo de error de imagen (mantenido)
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 120,
                      color: _primaryGreen.withAlpha(25),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: _primaryGreen,
                      ),
                    ),
                  ),
                ),

                // 2. Información del Producto (Nombre y Precio/Peso)
                Padding(
                  padding: const EdgeInsets.fromLTRB(8.0, 12.0, 8.0, 4.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment
                        .center, // Centramos el texto como en TiendaScreen
                    children: [
                      Text(
                        name,
                        textAlign: TextAlign.center, // Alineación del texto
                        style: const TextStyle(
                          fontSize: 15, // Tamaño de TiendaScreen
                          fontWeight: FontWeight.bold,
                          color: _unselectedDarkColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$price / $weight', // Formato de precio unificado
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: _primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
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
      padding: const EdgeInsets.all(8.0),
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
          const SizedBox(height: 8),

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
          const SizedBox(height: 8),

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
                SizedBox(height: 8),
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

import 'package:flutter/material.dart';
import 'package:eco_granel_app/screens/somos_screen.dart';

// Definimos el color verde primario para el tema (usando formato ARGB de 8 dígitos)
const Color _primaryGreen = Color(0xFF4CAF50);
// AÑADIDO: Definición del color oscuro para títulos (gris casi negro)
const Color _unselectedDarkColor = Color(0xFF333333);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Usamos ListView para permitir el desplazamiento a través de las secciones
    return const Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Sección "Descubre" (Banner Principal)
            _DiscoverSection(),

            // 2. Sección "Productos Destacados"
            _FeaturedProductsSection(),

            // 3. Sección "Quiénes Somos"
            _AboutUsSection(),

            SizedBox(height: 30), // Espacio final
          ],
        ),
      ),
    );
  }
}

// --- 1. Seccion Descubre (Banner Principal) ---
class _DiscoverSection extends StatelessWidget {
  const _DiscoverSection();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Container(
      width: screenWidth,
      // Usamos un alto considerable para simular el banner de la web
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        // CORREGIDO: Opacidad al 90% (~230/255)
        color: _primaryGreen.withAlpha(230),
        borderRadius: BorderRadius.circular(15),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(224, 224, 224, 100),
            blurRadius: 5,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Fondo o imagen (simulado)
          ClipRRect(
            borderRadius: BorderRadius.circular(15),
            child: Container(
              // CORREGIDO: Opacidad al 10% (~25/255)
              color: _primaryGreen.withAlpha(25), // Placeholder de color claro
            ),
          ),

          // Contenido del Banner
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Encuéntranos en tu ciudad",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "roboto",
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Nuestro carro sostenible llega a los barrios con productos a granel, desayunos y snacks conscientes. Descubre cuándo estaremos cerca de ti.",
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: "roboto",
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 20),
                // Botón de Llamada a la Acción (CTA)
                _CtaButton(label: "Ver Ubicaciones"),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Botón de Llamada a la Acción (Reutilizable)
class _CtaButton extends StatelessWidget {
  final String label;
  const _CtaButton({required this.label});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        // Implementar navegación a la sección de Tienda
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Navegando a: $label')));
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: _primaryGreen,
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: "roboto",
          fontWeight: FontWeight.bold,
          fontSize: 16, //boton
        ),
      ),
    );
  }
}

// --- 2. Seccion Productos Destacados (Scroll Horizontal) ---
class _FeaturedProductsSection extends StatelessWidget {
  const _FeaturedProductsSection();

  @override
  Widget build(BuildContext context) {
    // Lista de datos simulada para productos
    const List<Map<String, String>> products = [
      {'name': 'Avena en Hojuelas', 'price': '\$750 COP / 50g', 'icon': '🌾'},
      {
        'name': 'Harina de Almendra',
        'price': '\$5.600 COP / 50g',
        'icon': '🍇',
      },
      {'name': 'Semillas de Chía', 'price': '\$1.400 COP / 20g', 'icon': '🍲'},
      {'name': 'Garbanzos', 'price': '\$400 COP / 50g', 'icon': '🍲'},
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
              color: _unselectedDarkColor, // ¡Ahora definido!
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
                icon: product['icon']!,
                isFirst: index == 0,
              );
            },
          ),
        ),
      ],
    );
  }
}

// Tarjeta de Producto Individual
class _ProductCard extends StatelessWidget {
  final String name;
  final String price;
  final String icon;
  final bool isFirst;

  const _ProductCard({
    required this.name,
    required this.price,
    required this.icon,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      margin: EdgeInsets.only(
        left: isFirst ? 16.0 : 8.0,
        right: 8.0,
        bottom: 10.0,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Placeholder de la Imagen/Icono
          Container(
            height: 120,
            decoration: BoxDecoration(
              // CORREGIDO: Opacidad al 10% (~25/255)
              color: _primaryGreen.withAlpha(25),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(12),
              ),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 40)),
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
    );
  }
}

// --- 3. Seccion Quiénes Somos ---
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
              color: _unselectedDarkColor, // ¡Ahora definido!
            ),
          ),
          const SizedBox(height: 10),

          // IMAGEN DE PLACEHOLDER
          Center(
            child: Container(
              width:
                  MediaQuery.of(context).size.width *
                  0.9, // 90% del ancho para centrar
              height: 180,
              margin: const EdgeInsets.only(bottom: 15),
              decoration: BoxDecoration(
                // CORREGIDO: Opacidad al 20% (~51/255)
                color: _primaryGreen.withAlpha(51), // Color de fondo claro
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Icon(
                  Icons.storefront, // Ícono de tienda/misión
                  size: 60,
                  color: _primaryGreen,
                ),
              ),
            ),
          ),

          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50], // Fondo sutil
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: _primaryGreen.withAlpha(77)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  "En Eco Granel creemos que cada pequeña decisión puede generar un gran cambio. "
                  "Nacimos con la misión de promover un consumo consciente y sostenible, ofreciendo "
                  "alimentos frescos y de alta calidad a granel.",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "roboto",
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 12), // <-- Espacio entre párrafos
                Text(
                  "Te invitamos a comprar solo la cantidad que necesitas, reduciendo el desperdicio"
                  "y el impacto ambiental. Más que una tienda, somos un espacio que inspira a vivir"
                  "de manera más saludable y en armonia con el planeta.",
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: "roboto",
                    height: 1.5,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Botón opcional para ir a una página completa de "Sobre Nosotros"
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
                "Leer más sobre nuestra misión →",
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

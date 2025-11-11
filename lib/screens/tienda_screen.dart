import 'package:flutter/material.dart';

// --- Paleta de Colores ---

const Color _primaryGreen = Color(0xFF4CAF50); // Verde principal de ECO Granel

const Color _darkTextColor = Color(0xFF333333); // Color oscuro para textos

const Color _orangeColor = Color(
  0xFFC76939,
); // Color de adición (sugerido por el carrito/tema)

// --- Modelo de Datos del Producto (simulación) ---

class Product {
  final String name;

  final String imagePath;

  final String price;

  final String weight;

  final bool isFeatured; // Para el borde verde

  const Product({
    required this.name,

    required this.imagePath,

    required this.price,

    required this.weight,

    this.isFeatured = false,
  });
}

// --- Componente de Tarjeta de Producto (ProductCard) ---

class _ProductCard extends StatelessWidget {
  final Product product;

  final VoidCallback onAddToCart;

  const _ProductCard({required this.product, required this.onAddToCart});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,

      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),

        // Aplicar el borde verde si es un producto destacado
        side: product.isFeatured
            ? const BorderSide(color: _primaryGreen, width: 3)
            : BorderSide.none,
      ),

      child: InkWell(
        onTap: () {
          // Acción al tocar el producto

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ver detalles de ${product.name}')),
          );
        },

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: <Widget>[
            // 1. Imagen del Producto
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0),

                child: Image.asset(
                  product.imagePath,

                  fit: BoxFit.contain,

                  height: 80,
                ),
              ),
            ),

            // 2. Información del Producto
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),

              child: Column(
                children: [
                  Text(
                    product.name,

                    textAlign: TextAlign.center,

                    style: const TextStyle(
                      fontSize: 15,

                      fontWeight: FontWeight.bold,

                      color: _darkTextColor,
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    '${product.price} / ${product.weight}',

                    textAlign: TextAlign.center,

                    style: TextStyle(
                      fontSize: 14,

                      color: _primaryGreen,

                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),

            // 3. Botón de Agregar (Signo Más)
            Container(
              alignment: Alignment.center,

              padding: const EdgeInsets.only(bottom: 8.0),

              child: InkWell(
                onTap: onAddToCart,

                customBorder: const CircleBorder(),

                child: Container(
                  width: 38,

                  height: 38,

                  decoration: BoxDecoration(
                    color: _orangeColor,

                    shape: BoxShape.circle,
                  ),

                  child: const Icon(Icons.add, color: Colors.white, size: 24),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Lista de Productos Simulados (DEBES REEMPLAZAR 'assets/...' CON TUS PROPIAS RUTAS) ---

final List<Product> _products = [
  Product(
    name: "Avena en Hojuelas",

    imagePath: 'assets/images/granola.jpg',

    price: "\$750 COP",

    weight: "50g",

    isFeatured: true,
  ),

  Product(
    name: "Harina de Almendra",

    imagePath: 'assets/images/granola.jpg',

    price: "\$5.600 COP",

    weight: "50g",
  ),

  Product(
    name: "Semillas de Chía",

    imagePath: 'assets/images/granola.jpg',

    price: "\$3.700 COP",

    weight: "50g",
  ),

  Product(
    name: "Almendras Tostadas",

    imagePath: 'assets/images/granola.jpg',

    price: "\$4.650 COP",

    weight: "50g",
  ),

  Product(
    name: "Canela en Polvo",

    imagePath: 'assets/images/granola.jpg',

    price: "\$1.800 COP",

    weight: "20g",
  ),

  Product(
    name: "Arroz Integral",

    imagePath: 'assets/images/granola.jpg',

    price: "\$800 COP",

    weight: "50g",
  ),
];

// --- Pantalla Principal (TiendaScreen) ---

// El Scaffold lo proporciona el main.

class TiendaScreen extends StatelessWidget {
  const TiendaScreen({super.key});

  // Función auxiliar para las acciones

  void _handleAction(BuildContext context, String action) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Acción: $action')));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),

          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,

            children: [
              const Text(
                "Todos los productos",

                style: TextStyle(
                  fontFamily: "roboto",

                  fontSize: 24,

                  fontWeight: FontWeight.w600,

                  color: _darkTextColor,
                ),
              ),

              Row(
                children: [
                  // Icono de Búsqueda
                  IconButton(
                    icon: const Icon(
                      Icons.search,

                      color: _darkTextColor,

                      size: 28,
                    ),

                    onPressed: () {
                      _handleAction(context, 'Búsqueda');
                    },
                  ),

                  // Icono de Filtro
                  IconButton(
                    icon: const Icon(
                      Icons.filter_list,

                      color: _darkTextColor,

                      size: 28,
                    ),

                    onPressed: () {
                      _handleAction(context, 'Filtrar');
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 10),

        // Catálogo de Productos (GridView)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),

            child: GridView.builder(
              padding: const EdgeInsets.only(bottom: 20.0),

              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, // Dos columnas como en el prototipo

                crossAxisSpacing: 12.0,

                mainAxisSpacing: 12.0,

                childAspectRatio: 0.75, // Ajusta la altura de las tarjetas
              ),

              itemCount: _products.length,

              itemBuilder: (context, index) {
                final product = _products[index];

                return _ProductCard(
                  product: product,

                  onAddToCart: () =>
                      _handleAction(context, 'Añadir ${product.name}'),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

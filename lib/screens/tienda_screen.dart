import 'package:flutter/material.dart';

// --- Paleta de Colores ---

const Color _primaryGreen = Color(0xFF4CAF50); // Verde principal de ECO Granel

const Color _darkTextColor = Color(0xFF333333); // Color oscuro para textos

const Color _orangeColor = Color(
  0xFFC76939,
); // Color de adición (sugerido por el carrito/tema)

// NUEVO: Color de fondo solicitado para el menú de filtro
const Color _filterMenuBackgroundColor = Color(0xFFFFFFFF); // Gris muy claro

// Colores originales que ya no se usan en el menú de filtro:
// const Color _menuTextColor = Color(0xFFFFFFFF);
// const Color _selectedOptionColor = Color(0xFFFFFFFF);

// --- Modelo de Datos del Producto (simulación) ---

class Product {
  final String name;

  final String imagePath;

  final String price;

  final String weight;

  final String category; // NUEVA PROPIEDAD DE CATEGORÍA

  const Product({
    required this.name,
    required this.imagePath,
    required this.price,
    required this.weight,
    required this.category, // Requiere la nueva propiedad
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
        borderRadius: BorderRadius.circular(12),
        side: BorderSide.none,
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
            // 1. Imagen del Producto:
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
                child: Image.asset(product.imagePath, fit: BoxFit.cover),
              ),
            ),

            // 2. Información del Producto
            Padding(
              padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 4.0),
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

// --- Lista de Productos Simulados (Clasificados) ---
final List<Product> _products = [
  const Product(
    name: "Avena en Hojuelas",
    imagePath: 'assets/images/avena-hojuelas.jpg',
    price: "\$750 COP",
    weight: "50g",
    category: 'Harinas y Cereales',
  ),
  const Product(
    name: "Harina de Almendra",
    imagePath: 'assets/images/harina-almendras.jpg',
    price: "\$5.600 COP",
    weight: "50g",
    category: 'Harinas y Cereales',
  ),
  const Product(
    name: "Semillas de Chía",
    imagePath: 'assets/images/chia.jpg',
    price: "\$3.700 COP",
    weight: "50g",
    category: 'Frutos Secos y Semillas',
  ),
  const Product(
    name: "Almendras",
    imagePath: 'assets/images/almendras.jpg',
    price: "\$4.650 COP",
    weight: "50g",
    category: 'Frutos Secos y Semillas',
  ),
  const Product(
    name: "Canela en Polvo",
    imagePath: 'assets/images/canela-polvo.jpg',
    price: "\$1.800 COP",
    weight: "20g",
    category: 'Especias y Condimentos',
  ),
  const Product(
    name: "Arroz Integral",
    imagePath: 'assets/images/arroz-integral.jpg',
    price: "\$800 COP",
    weight: "50g",
    category: 'Granos y Legumbres',
  ),
  const Product(
    name: "Garbanzos",
    imagePath: 'assets/images/garbanzos.jpg',
    price: "\$400 COP",
    weight: "50g",
    category: 'Granos y Legumbres',
  ),
  const Product(
    name: "Pimienta negra",
    imagePath: 'assets/images/pimienta.jpg',
    price: "\$1.575 COP",
    weight: "15g",
    category: 'Especias y Condimentos',
  ),
  const Product(
    name: "Cúrcuma en polvo",
    imagePath: 'assets/images/curcuma.jpg',
    price: "\$900 COP",
    weight: "20g",
    category: 'Especias y Condimentos',
  ),
  const Product(
    name: "Nueces",
    imagePath: 'assets/images/nueces.jpg',
    price: "\$2.850 COP",
    weight: "15g",
    category: 'Frutos Secos y Semillas',
  ),
  const Product(
    name: "Lentejas",
    imagePath: 'assets/images/lentejas.jpg',
    price: "\$800 COP",
    weight: "100g",
    category: 'Granos y Legumbres',
  ),
  const Product(
    name: "Quinoa Orgánica",
    imagePath: 'assets/images/quinoa.jpg',
    price: "\$3.400 COP",
    weight: "50g",
    category: 'Harinas y Cereales',
  ),
];

// -------------------------------------------------------------------
// --- Componente para la Opción del Menú de Filtros (Ajustado) ---
// -------------------------------------------------------------------

class _FilterOption extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterOption({
    required this.title,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // 1. Define el color del texto según el estado de selección
    final Color textColor = isSelected ? _orangeColor : _darkTextColor;

    // 2. Define el color de la línea de selección (usando el mismo color naranja)
    final Color selectedLineColor = _orangeColor;

    final TextStyle textStyle = TextStyle(
      fontSize: 18,
      fontFamily: "roboto",
      color: textColor, // Usa el color dinámico
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    );

    return InkWell(
      onTap: onTap,
      // Usamos un Container con Padding para el área de toque/visual
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
        child: Column(
          // Usamos Column para apilar el texto y la línea
          crossAxisAlignment: CrossAxisAlignment.start, // Alineación izquierda
          mainAxisSize: MainAxisSize.min, // Ocupar el mínimo espacio vertical
          children: [
            // El texto de la categoría
            Text(title, style: textStyle),
            // Espacio de separación entre el texto y la línea
            if (isSelected) const SizedBox(height: 4),
            // La línea de selección (Container)
            if (isSelected)
              Container(
                height: 2, // Grosor de la línea
                width: 200, // Ancho de la línea (puede ser ajustado)
                color: selectedLineColor, // Color de la línea
              ),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// --- Componente para la Selección de Filtros a Pantalla Completa ---
// -------------------------------------------------------------------

class _FilterFullScreenDialog extends StatelessWidget {
  final String currentCategory; // Categoría actual para marcar
  final ValueChanged<String> onCategorySelected; // Callback al seleccionar

  const _FilterFullScreenDialog({
    required this.currentCategory,
    required this.onCategorySelected,
  });

  // Lista de las categorías
  static const List<String> _categories = [
    'Todos los productos',
    'Especias y Condimentos',
    'Frutos Secos y Semillas',
    'Granos y Legumbres',
    'Harinas y Cereales',
  ];

  @override
  Widget build(BuildContext context) {
    // 1. Usamos el nuevo color de fondo para el menú
    return Dialog.fullscreen(
      backgroundColor: _filterMenuBackgroundColor,
      child: Scaffold(
        // 2. El AppBar también debe usar el nuevo color de fondo
        appBar: AppBar(
          backgroundColor: _filterMenuBackgroundColor,
          elevation: 5,
          titleSpacing: 0.0,
          leading: IconButton(
            // El icono de cierre usa el color oscuro
            icon: const Icon(Icons.close, color: _darkTextColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          // MODIFICACIÓN: Se envuelve el Text con Padding para añadir el margen izquierdo de 30.0
          title: const Padding(
            padding: EdgeInsets.only(left: 0.0), // Padding de 30 a la izquierda
            child: Text(
              'Categorías',
              style: TextStyle(
                color: _darkTextColor,
                fontFamily: "roboto",
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ), // El título usa color oscuro
            ),
          ),
        ),
        // 3. El cuerpo también usa el nuevo color
        backgroundColor: _filterMenuBackgroundColor,
        body: Padding(
          // 4. Se agrega un padding superior para "subir" el menú
          padding: const EdgeInsets.only(top: 30.0),
          child: Column(
            // 5. Se cambia a MainAxisAlignment.start para empezar desde arriba
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _categories.map((category) {
              // Comprueba si esta categoría es la seleccionada
              final bool isSelected = category == currentCategory;

              return _FilterOption(
                title: category,
                isSelected: isSelected,
                onTap: () {
                  // 1. Llama al callback para actualizar el estado en TiendaScreen
                  onCategorySelected(category);

                  // 2. Cierra el diálogo
                  Navigator.of(context).pop();
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// --- Pantalla Principal Modificada (TiendaScreen) ---
// -------------------------------------------------------------------

class TiendaScreen extends StatefulWidget {
  const TiendaScreen({super.key});

  @override
  State<TiendaScreen> createState() => _TiendaScreenState();
}

class _TiendaScreenState extends State<TiendaScreen> {
  // Estado para rastrear la categoría seleccionada. Por defecto: "Todos los productos"
  String _selectedCategory = 'Todos los productos';

  // --- LÓGICA CLAVE: Filtrado y Ordenamiento ---
  List<Product> _getFilteredProducts() {
    List<Product> filteredList;

    if (_selectedCategory == 'Todos los productos') {
      // Si es 'Todos los productos', usa la lista completa
      filteredList = _products;
    } else {
      // Filtra por la categoría seleccionada
      filteredList = _products
          .where((product) => product.category == _selectedCategory)
          .toList();
    }

    // Ordena la lista alfabéticamente por nombre, según lo solicitado
    filteredList.sort((a, b) => a.name.compareTo(b.name));

    return filteredList;
  }

  // Función para actualizar el estado desde el diálogo y reconstruir la vista
  void _updateCategory(String newCategory) {
    setState(() {
      _selectedCategory = newCategory;
    });
  }

  // Función auxiliar para las acciones
  void _handleAction(BuildContext context, String action) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Acción: $action')));
  }

  // Muestra el diálogo de filtro
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return _FilterFullScreenDialog(
          currentCategory: _selectedCategory,
          onCategorySelected:
              _updateCategory, // Pasa la función de actualización
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Obtiene la lista de productos filtrada y ordenada
    final filteredProducts = _getFilteredProducts();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Muestra la categoría actualmente seleccionada
              Text(
                _selectedCategory,
                style: const TextStyle(
                  fontFamily: "roboto",
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: _darkTextColor,
                ),
              ),
              Row(
                children: [
                  // Icono de Filtro
                  IconButton(
                    icon: const Icon(
                      Icons.filter_list,
                      color: _darkTextColor,
                      size: 28,
                    ),
                    onPressed:
                        _showFilterDialog, // Llama a la función del diálogo
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
                crossAxisCount: 2,
                crossAxisSpacing: 12.0,
                mainAxisSpacing: 12.0,
                childAspectRatio: 0.75,
              ),
              // Usa la lista filtrada y ordenada
              itemCount: filteredProducts.length,
              itemBuilder: (context, index) {
                final product = filteredProducts[index];

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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_granel_app/screens/product_detail_screen.dart'; // Importación necesaria

// --- Paleta de Colores (se mantiene igual) ---
const Color _primaryGreen = Color(0xFF4CAF50); // Verde principal de ECO Granel
const Color _darkTextColor = Color(0xFF333333); // Color oscuro para textos
const Color _orangeColor = Color(0xFFC76939); // Color de adición
const Color _filterMenuBackgroundColor = Color(
  0xFFFFFFFF,
); // Color de fondo del filtro

// --- Modelo de Datos del Producto (MODIFICADO para Firebase) ---

class Product {
  final String id; // Nuevo: ID del documento de Firestore
  final String name;
  final String imagePath;
  final String price;
  final String weight;
  final String category;

  const Product({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.price,
    required this.weight,
    required this.category,
  });

  // ********** CONSTRUCTOR DE FIREBASE **********
  // Convierte un DocumentSnapshot de Firestore en un objeto Product
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Product(
      id: doc.id,
      name: data['name'] ?? 'Producto Desconocido',
      // NOTA: 'imagePath', 'price', y 'weight' deben ser campos en tu DB
      imagePath: data['imagePath'] ?? 'assets/images/default.jpg',
      price: data['price'] ?? '\$0 COP',
      weight: data['weight'] ?? '0g',
      category: data['category'] ?? 'Sin Categoría',
    );
  }
}

// --- Componente de Tarjeta de Producto (_ProductCard) (MODIFICADO) ---
class _ProductCard extends StatelessWidget {
  final Product product;
  // Se mantiene onAddToCart, pero para el tap en la tarjeta se usará un onTap específico.
  // Lo vamos a usar para el botón, pero lo modificaremos para que navegue.
  final VoidCallback onAddToCart;

  const _ProductCard({required this.product, required this.onAddToCart});

  // Función de navegación común para el botón y el tap de la tarjeta.
  void _navigateToProductDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(productId: product.id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide.none,
      ),
      child: InkWell(
        // Se mantiene el onTap principal de la tarjeta para navegación
        onTap: () => _navigateToProductDetail(context),

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
                // ********** MODIFICACIÓN CLAVE AQUÍ **********
                // El tap en el icono + ahora llama a la misma función de navegación
                onTap: () => _navigateToProductDetail(context),
                // **********************************************
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

// Código restante (sin modificar):
// -------------------------------------------------------------------
// --- Componente para la Opción del Menú de Filtros (_FilterOption) (Se mantiene igual) ---
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
    final Color textColor = isSelected ? _orangeColor : _darkTextColor;
    final Color selectedLineColor = _orangeColor;

    final TextStyle textStyle = TextStyle(
      fontSize: 18,
      fontFamily: "roboto",
      color: textColor,
      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
    );

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: textStyle),
            if (isSelected) const SizedBox(height: 4),
            if (isSelected)
              Container(height: 2, width: 200, color: selectedLineColor),
          ],
        ),
      ),
    );
  }
}

// -------------------------------------------------------------------
// --- Componente para la Selección de Filtros a Pantalla Completa (Se mantiene igual) ---
class _FilterFullScreenDialog extends StatelessWidget {
  final String currentCategory;
  final ValueChanged<String> onCategorySelected;

  const _FilterFullScreenDialog({
    required this.currentCategory,
    required this.onCategorySelected,
  });

  static const List<String> _categories = [
    'Todos los productos',
    'Especias y Condimentos',
    'Frutos Secos y Semillas',
    'Granos y Legumbres',
    'Harinas y Cereales',
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      backgroundColor: _filterMenuBackgroundColor,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: _filterMenuBackgroundColor,
          elevation: 5,
          titleSpacing: 0.0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: _darkTextColor),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Padding(
            padding: EdgeInsets.only(left: 0.0),
            child: Text(
              'Categorías',
              style: TextStyle(
                color: _darkTextColor,
                fontFamily: "roboto",
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        backgroundColor: _filterMenuBackgroundColor,
        body: Padding(
          padding: const EdgeInsets.only(top: 30.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _categories.map((category) {
              final bool isSelected = category == currentCategory;

              return _FilterOption(
                title: category,
                isSelected: isSelected,
                onTap: () {
                  onCategorySelected(category);
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

  // Referencia a la colección de Firestore
  final CollectionReference _productCollection = FirebaseFirestore.instance
      .collection('products');

  // Lógica de filtrado y ordenamiento (AHORA RECIBE LA LISTA COMPLETA DE FIREBASE)
  List<Product> _getFilteredProducts(List<Product> allProducts) {
    List<Product> filteredList;

    if (_selectedCategory == 'Todos los productos') {
      filteredList = allProducts;
    } else {
      filteredList = allProducts
          .where((product) => product.category == _selectedCategory)
          .toList();
    }

    // Ordena la lista alfabéticamente por nombre
    filteredList.sort((a, b) => a.name.compareTo(b.name));

    return filteredList;
  }

  // Función para actualizar el estado desde el diálogo y reconstruir la vista
  void _updateCategory(String newCategory) {
    setState(() {
      _selectedCategory = newCategory;
    });
  }

  void _handleAction(BuildContext context, String action) {
    // Esta función ya no se usa para el tap del ícono +, pero se mantiene para la plantilla
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Acción: $action')));
  }

  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return _FilterFullScreenDialog(
          currentCategory: _selectedCategory,
          onCategorySelected: _updateCategory,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.fromLTRB(20.0, 8.0, 20.0, 0.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
                  IconButton(
                    icon: const Icon(
                      Icons.filter_list,
                      color: _darkTextColor,
                      size: 28,
                    ),
                    onPressed: _showFilterDialog,
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        // ********** StreamBuilder para cargar datos de Firebase **********
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _productCollection.snapshots(),
            builder: (context, snapshot) {
              // 1. Manejo del estado de conexión (Cargando)
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // 2. Manejo de errores
              if (snapshot.hasError) {
                return Center(
                  child: Text('Error al cargar datos: ${snapshot.error}'),
                );
              }

              // 3. Manejo de datos vacíos
              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No hay productos disponibles.'),
                );
              }

              // 4. Mapear DocumentSnapshot a objetos Product
              final allProducts = snapshot.data!.docs
                  .map((doc) => Product.fromFirestore(doc))
                  .toList();

              // 5. Aplicar el filtro de categoría y ordenamiento
              final filteredProducts = _getFilteredProducts(allProducts);

              // 6. Catálogo de Productos (GridView)
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: GridView.builder(
                  padding: const EdgeInsets.only(bottom: 20.0),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12.0,
                    mainAxisSpacing: 12.0,
                    childAspectRatio: 0.75,
                  ),
                  itemCount: filteredProducts.length,
                  itemBuilder: (context, index) {
                    final product = filteredProducts[index];

                    return _ProductCard(
                      product: product,
                      // Se usa _handleAction aquí como un placeholder si se requiere una acción al presionar la tarjeta,
                      // aunque el tap principal de la tarjeta ya navega en el widget.
                      onAddToCart: () => _handleAction(
                        context,
                        'Añadir ${product.name} (Acción anterior)',
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        // ***************************************************************
      ],
    );
  }
}

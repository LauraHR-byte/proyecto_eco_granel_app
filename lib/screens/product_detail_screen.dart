import 'package:provider/provider.dart';
import 'package:eco_granel_app/providers/cart_provider.dart';
//import 'package:eco_granel_app/models/cart_item.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// -------------------------------------------------------------------
// --- PALETA DE COLORES (Se mantiene igual) ---
// -------------------------------------------------------------------
const Color _primaryGreen = Color(0xFF4CAF50); // Verde principal de ECO Granel
const Color _darkTextColor = Color(0xFF333333); // Color oscuro para textos
const Color _orangeColor = Color(0xFFC76939); // Color de adición
const Color _filterMenuBackgroundColor = Color(
  0xA0FFFFFF,
); // Color de fondo del filtro

// -------------------------------------------------------------------
// --- MODELO DE DATOS DEL PRODUCTO MODIFICADO ---
// -------------------------------------------------------------------
class Product {
  final String id;
  final String name;
  final String imagePath;
  final String price; // Precio por defecto (ej: para la lista)
  final String weight; // Peso por defecto (ej: para la lista)
  final String category;
  final String description; // Campo de descripción solicitado
  final List<String> availableWeights;
  // ********** CAMPO CLAVE AÑADIDO **********
  // Un mapa donde la clave es el peso (String) y el valor es el precio (double/int)
  final Map<String, int> priceMap;

  const Product({
    required this.id,
    required this.name,
    required this.imagePath,
    required this.price,
    required this.weight,
    required this.category,
    required this.description,
    required this.availableWeights,
    required this.priceMap, // Añadido
  });

  // ********** CONSTRUCTOR DE FIREBASE MODIFICADO **********
  factory Product.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Conversión segura del mapa de precios, asumiendo que Firestore almacena Map<String, dynamic>
    final Map<String, int> loadedPriceMap = {};
    final rawPriceMap = data['priceMap'] as Map<String, dynamic>? ?? {};

    rawPriceMap.forEach((key, value) {
      // Asegura que el valor sea un entero (o conviértelo si es double, si es necesario)
      loadedPriceMap[key] = (value as num).toInt();
    });

    return Product(
      id: doc.id,
      name: data['name'] ?? 'Producto Desconocido',
      imagePath: data['imagePath'] ?? 'assets/images/default.jpg',
      // Se mantiene 'price' y 'weight' para la vista de lista, aunque el detalle usará el mapa
      price: data['price'] ?? '\$0 COP',
      weight: data['weight'] ?? '0g',
      category: data['category'] ?? 'Sin Categoría',
      // Campo de descripción solicitado:
      description: data['description'] ?? 'Descripción no disponible.',
      // Lista de pesos disponibles
      availableWeights: List<String>.from(
        data['availableWeights'] ?? ['50g', '100g', '200g'],
      ),
      // Mapa de precios
      priceMap: loadedPriceMap.isNotEmpty
          ? loadedPriceMap
          : {
              '50g': 1500,
              '100g': 3000,
              '250g': 7000,
              '500g': 13000,
              '1kg': 25000,
            }, // Mapa de precios por defecto
    );
  }
}

// -------------------------------------------------------------------
// --- PANTALLA DE DETALLE DEL PRODUCTO (Se mantiene) ---
// -------------------------------------------------------------------

class ProductDetailScreen extends StatelessWidget {
  // El ID del producto que se pasa desde la pantalla de la tienda
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  // Función para obtener los datos del producto de Firebase
  Future<Product> _fetchProduct() async {
    // Simulación de datos para que la vista funcione si Firestore no está configurado
    if (productId == '1') {
      // ********** DATA SIMULADA MODIFICADA **********
      return const Product(
        id: '1',
        name: 'Avena en hojuela',
        imagePath: 'assets/images/avena.jpg', // Asegúrate de tener esta imagen
        price: '\$3.000 COP',
        weight: '100g',
        category: 'Harinas y Cereales',
        description:
            'La avena en hojuelas es un cereal integral rico en fibra soluble, especialmente beta-glucanos, que ayuda a reducir el colesterol y mejora la digestión. Ideal para desayunos nutritivos.',
        availableWeights: ['50g', '100g', '250g', '500g', '1kg'],
        priceMap: {
          '50g': 1500,
          '100g': 3000,
          '250g': 7000,
          '500g': 13000,
          '1kg': 25000,
        },
      );
    }
    // ************************************************

    final docSnapshot = await FirebaseFirestore.instance
        .collection('products')
        .doc(productId)
        .get();

    if (!docSnapshot.exists) {
      // Usar el producto simulado si no se encuentra en la base de datos
      return const Product(
        id: '1',
        name: 'Avena en hojuela',
        imagePath: 'assets/images/avena.jpg', // Asegúrate de tener esta imagen
        price: '\$3.000 COP',
        weight: '100g',
        category: 'Harinas y Cereales',
        description:
            'La avena en hojuelas es un cereal integral rico en fibra soluble, especialmente beta-glucanos, que ayuda a reducir el colesterol y mejora la digestión. Ideal para desayunos nutritivos.',
        availableWeights: ['50g', '100g', '250g', '500g', '1kg'],
        priceMap: {
          '50g': 1500,
          '100g': 3000,
          '250g': 7000,
          '500g': 13000,
          '1kg': 25000,
        },
      );
      // throw Exception('El producto con ID $productId no existe.');
    }

    return Product.fromFirestore(docSnapshot);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Product>(
        future: _fetchProduct(),
        builder: (context, snapshot) {
          // 1. Manejo del estado de conexión (Cargando)
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Manejo de errores
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar el producto: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }

          // 3. Mostrar los detalles
          if (snapshot.hasData) {
            final product = snapshot.data!;
            return _ProductDetailContent(product: product);
          }

          // Caso por defecto (nunca debería ocurrir si hay manejo de errores)
          return const Center(child: Text('Producto no encontrado.'));
        },
      ),
    );
  }
}

// -------------------------------------------------------------------
// --- CONTENIDO DEL DETALLE DEL PRODUCTO MODIFICADO ---
// -------------------------------------------------------------------

class _ProductDetailContent extends StatefulWidget {
  final Product product;

  const _ProductDetailContent({required this.product});

  @override
  State<_ProductDetailContent> createState() => _ProductDetailContentState();
}

class _ProductDetailContentState extends State<_ProductDetailContent> {
  // Estado para la opción de peso seleccionada (por defecto, la primera de la lista)
  late String _selectedWeight;
  // Estado para la cantidad de unidades
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    // Se inicializa con el primer peso disponible que tenga un precio en el mapa
    _selectedWeight = widget.product.availableWeights.firstWhere(
      (weight) => widget.product.priceMap.containsKey(weight),
      orElse: () => widget.product.availableWeights.first,
    );
  }

  // ********** FUNCIÓN CLAVE AÑADIDA **********
  // Calcula el precio total basado en la selección actual.
  String _calculateTotalPrice() {
    // Obtiene el precio base por la unidad de peso seleccionada (ej: precio de 100g)
    final basePrice = widget.product.priceMap[_selectedWeight] ?? 0;

    // Calcula el precio total: Precio Base * Cantidad de unidades
    final totalPrice = basePrice * _quantity;

    // Formatea el precio a un String (ej: "$3.000 COP")
    // Nota: Una implementación real debería usar una biblioteca como 'intl' para formateo monetario
    return '\$${totalPrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} COP';
  }

  // Lógica para el botón de Agregar al Carrito (simulado)
  void _addToCart() {
    // 1. Obtener el Provider
    final cartProvider = Provider.of<CartProvider>(context, listen: false);

    // 2. Extraer los datos necesarios
    final basePrice = widget.product.priceMap[_selectedWeight];

    if (basePrice == null) {
      // Manejar el caso donde no hay precio (no debería ocurrir si la lógica de chip es correcta)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Error: Precio no disponible para el peso seleccionado.',
          ),
        ),
      );
      return;
    }

    // 3. Añadir el item al carrito
    cartProvider.addItemToCart(
      productId: widget.product.id,
      name: widget.product.name,
      imagePath: widget.product.imagePath,
      weightUnit: _selectedWeight,
      unitPrice: basePrice, // Precio por unidad de peso
      quantity: _quantity, // Cantidad de unidades
    );

    // 4. Muestra la confirmación (opcional, podrías usar un toast mejor)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '¡$_quantity x $_selectedWeight de ${widget.product.name} añadido al carrito!',
        ),
        duration: const Duration(seconds: 2),
        backgroundColor: _primaryGreen,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentTotalPrice = _calculateTotalPrice(); // Calcula el precio total

    // Obtiene el precio por peso para mostrarlo
    final basePrice = widget.product.priceMap[_selectedWeight] ?? 0;
    final basePriceText =
        '\$${basePrice.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]}.')} COP';

    final pricePerWeightText = '$basePriceText / $_selectedWeight';

    // Se usa Scaffold estándar para manejar el AppBar simple.
    return Scaffold(
      appBar: AppBar(
        // El título del AppBar es el nombre del producto ('Avena en hojuela')
        title: Text(
          widget.product.name,
          style: const TextStyle(
            color: _darkTextColor,
            fontSize: 22,
            fontWeight: FontWeight.w600,
            fontFamily: "roboto",
          ),
        ),
        centerTitle: false,
        backgroundColor: Colors.white,
        elevation: 0, // Elimina la sombra para un look plano
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 30, color: _darkTextColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // ********** IMAGEN CENTRADA CON BORDES (Sin cambios) **********
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
                child: Container(
                  width:
                      MediaQuery.of(context).size.width * 0.9, // Ancho relativo
                  height: 260, // Altura fija
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                      12,
                    ), // Bordes redondeados
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withAlpha(127),
                        spreadRadius: 0,
                        blurRadius: 3,
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      widget.product.imagePath,
                      fit: BoxFit.cover, // La imagen cubre el área
                    ),
                  ),
                ),
              ),
            ),
            // *************************************************
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // ********** PRECIO TOTAL ACTUALIZADO **********
                  Text(
                    currentTotalPrice, // Precio Total calculado
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: _primaryGreen,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // ********** PRECIO BASE POR PESO SELECCIONADO **********
                  Text(
                    pricePerWeightText, // Precio por Peso Base (ej: $750 COP / 50g)
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 20),

                  // Selector de Peso
                  const Text(
                    'Peso *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _darkTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: widget.product.availableWeights.map((weight) {
                      final bool isSelected = weight == _selectedWeight;
                      // Deshabilita el chip si el peso no tiene precio asociado en priceMap
                      final bool isPriceAvailable = widget.product.priceMap
                          .containsKey(weight);

                      return ChoiceChip(
                        label: Text(weight),
                        selected: isSelected,
                        // ********** AJUSTES CLAVE AQUÍ **********
                        // 1. Quitar el chulo:
                        showCheckmark: false,
                        // 2. Color cuando está seleccionado (Naranja):
                        selectedColor: _orangeColor.withAlpha(230),
                        // 3. Color cuando NO está seleccionado (Fondo blanco con borde por defecto):
                        backgroundColor: Colors.white,
                        // 4. Color cuando está deshabilitado:
                        disabledColor: Colors.grey[200],
                        // 5. Estilo del borde para simular un botón:
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(
                            color: isSelected
                                ? _orangeColor.withAlpha(230)
                                : Colors
                                      .grey
                                      .shade300, // Borde naranja si está seleccionado
                          ),
                        ),
                        // ****************************************
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : (isPriceAvailable
                                    ? _darkTextColor
                                    : Colors.grey),
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        // ********** ACTUALIZA EL PESO Y RECALCULA EL PRECIO **********
                        onSelected: isPriceAvailable
                            ? (selected) {
                                if (selected) {
                                  setState(() {
                                    _selectedWeight = weight;
                                  });
                                }
                              }
                            : null, // Deshabilita la selección si no hay precio
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),

                  // Selector de Cantidad
                  const Text(
                    'Cantidad *',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _darkTextColor,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: <Widget>[
                      // Botón Menos
                      _buildQuantityButton(
                        icon: Icons.remove,
                        onTap: () {
                          setState(() {
                            if (_quantity > 1) _quantity--;
                          });
                        },
                      ),
                      // Campo de Cantidad
                      Container(
                        width: 50,
                        alignment: Alignment.center,
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: _darkTextColor,
                          ),
                        ),
                      ),
                      // Botón Más
                      _buildQuantityButton(
                        icon: Icons.add,
                        onTap: () {
                          setState(() {
                            _quantity++;
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      // Botón Agregar al Carrito
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _addToCart,
                          icon: const Icon(Icons.shopping_cart),
                          label: const Text(
                            'Agregar al carrito',
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "roboto",
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: _primaryGreen,
                            padding: const EdgeInsets.symmetric(vertical: 12.0),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Descripción del Producto
                  const Text(
                    'Descripción del producto',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _darkTextColor,
                    ),
                  ),
                  const Divider(color: Colors.grey, height: 10, thickness: 1),
                  const SizedBox(height: 10),
                  Text(
                    widget.product.description, // Usa el campo de descripción
                    style: const TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget auxiliar para los botones de cantidad (Se mantiene igual, la actualización del precio se hace automáticamente con setState)
  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: _darkTextColor),
      ),
    );
  }
}

// -------------------------------------------------------------------
// --- EL RESTO DE CLASES (Se mantienen igual) ---
// -------------------------------------------------------------------

// --- COMPONENTE DE TARJETA DE PRODUCTO (_ProductCard) ---
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
        // ********** LÓGICA DE NAVEGACIÓN A DETALLES **********
        onTap: () {
          // Navega a la nueva pantalla de detalles, pasando el ID del producto
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: product.id),
            ),
          );
        },
        // ****************************************************
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
                    style: const TextStyle(
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
                  decoration: const BoxDecoration(
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

// -------------------------------------------------------------------
// --- COMPONENTES DE FILTRO Y TIENDASCREEN (Se mantienen igual) ---
// -------------------------------------------------------------------

// --- Componente para la Opción del Menú de Filtros (_FilterOption)
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

// --- Componente para la Selección de Filtros a Pantalla Completa
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

// --- Pantalla Principal Modificada (TiendaScreen)
class TiendaScreen extends StatefulWidget {
  const TiendaScreen({super.key});

  @override
  State<TiendaScreen> createState() => _TiendaScreenState();
}

class _TiendaScreenState extends State<TiendaScreen> {
  String _selectedCategory = 'Todos los productos';

  // Nota: Asegúrate de que tu configuración de Firebase y Firestore esté correcta
  final CollectionReference _productCollection = FirebaseFirestore.instance
      .collection('products');

  List<Product> _getFilteredProducts(List<Product> allProducts) {
    List<Product> filteredList;

    if (_selectedCategory == 'Todos los productos') {
      filteredList = allProducts;
    } else {
      filteredList = allProducts
          .where((product) => product.category == _selectedCategory)
          .toList();
    }

    filteredList.sort((a, b) => a.name.compareTo(b.name));

    return filteredList;
  }

  void _updateCategory(String newCategory) {
    setState(() {
      _selectedCategory = newCategory;
    });
  }

  void _handleAction(BuildContext context, String action) {
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
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _productCollection.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error al cargar datos: ${snapshot.error}'),
                );
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Center(
                  child: Text('No hay productos disponibles.'),
                );
              }

              final allProducts = snapshot.data!.docs
                  .map((doc) => Product.fromFirestore(doc))
                  .toList();

              final filteredProducts = _getFilteredProducts(allProducts);

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
                      onAddToCart: () =>
                          _handleAction(context, 'Añadir ${product.name}'),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

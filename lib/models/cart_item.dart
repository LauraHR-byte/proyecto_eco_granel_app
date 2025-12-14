// Archivo: models/cart_item.dart

class CartItem {
  final String productId;
  final String name;
  final String imagePath;
  final String weightUnit; // Ejemplo: '100g', '500g'
  final int
  unitPrice; // Precio del peso/unidad seleccionado (ej: $3000 por 100g)
  int quantity; // Cantidad de unidades (ej: 2 unidades de 100g = 200g)

  // El precio total para este item: unitPrice * quantity
  int get totalPrice => unitPrice * quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.imagePath,
    required this.weightUnit,
    required this.unitPrice,
    this.quantity = 1,
  });

  // Método para crear una copia del item con una cantidad diferente (útil para inmutabilidad)
  CartItem copyWith({int? quantity}) {
    return CartItem(
      productId: productId,
      name: name,
      imagePath: imagePath,
      weightUnit: weightUnit,
      unitPrice: unitPrice,
      quantity: quantity ?? this.quantity,
    );
  }
}

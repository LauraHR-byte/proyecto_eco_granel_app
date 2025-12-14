// Archivo: providers/cart_provider.dart

import 'package:flutter/material.dart';
import '../models/cart_item.dart'; // Importa la clase CartItem

class CartProvider extends ChangeNotifier {
  // Mapa donde la clave es una combinación de ProductId y WeightUnit (para unicidad)
  final Map<String, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  int get itemCount => _items.length;

  // Calcula el precio total de todos los items en el carrito
  int get totalAmount {
    int total = 0;
    _items.forEach((key, item) {
      total += item.totalPrice;
    });
    return total;
  }

  // Función auxiliar para generar una clave única (ID del producto + unidad de peso)
  String _generateKey(String productId, String weightUnit) {
    return '${productId}_$weightUnit';
  }

  // AÑADIR/ACTUALIZAR ITEM AL CARRITO
  void addItemToCart({
    required String productId,
    required String name,
    required String imagePath,
    required String weightUnit,
    required int unitPrice,
    required int quantity,
  }) {
    final itemKey = _generateKey(productId, weightUnit);

    if (_items.containsKey(itemKey)) {
      // El producto con esa unidad de peso ya existe, solo actualiza la cantidad
      _items.update(
        itemKey,
        (existingItem) =>
            existingItem.copyWith(quantity: existingItem.quantity + quantity),
      );
    } else {
      // El producto es nuevo para el carrito
      _items[itemKey] = CartItem(
        productId: productId,
        name: name,
        imagePath: imagePath,
        weightUnit: weightUnit,
        unitPrice: unitPrice,
        quantity: quantity,
      );
    }

    notifyListeners();
  }

  // ELIMINAR ITEM
  void removeItem(CartItem item) {
    final itemKey = _generateKey(item.productId, item.weightUnit);
    _items.remove(itemKey);
    notifyListeners();
  }

  // ACTUALIZAR CANTIDAD (usado en CarritoScreen)
  void updateItemQuantity(CartItem item, int newQuantity) {
    if (newQuantity <= 0) {
      removeItem(item);
      return;
    }

    final itemKey = _generateKey(item.productId, item.weightUnit);
    _items.update(
      itemKey,
      (existingItem) => existingItem.copyWith(quantity: newQuantity),
    );
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}

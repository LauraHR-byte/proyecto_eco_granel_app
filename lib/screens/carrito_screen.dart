import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../models/cart_item.dart';
import 'package:intl/intl.dart'; // Necesitas añadir 'intl: ^0.18.1' a pubspec.yaml

// Constantes de Color (Las mantengo tal cual están en tu código original)
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);
const Color _darkTextColor = Color(0xFF333333);
const Color _secondaryLightColor = Color(
  0xFFF0F0F0,
); // Gris muy claro para fondo
const Color _orangeColor = Color(
  0xFFC76939,
); // Color de adición (Usado en el detalle)

// *** NUEVAS CONSTANTES DE ENVÍO ***
const int _freeShippingThreshold = 50000; // 50.000 COP
const int _standardShippingCost = 4500; // 4.500 COP
const Color _shippingMessageBackground = Color(
  0xFFE8F5E9,
); // Gris verdoso muy claro
const Color _shippingMessageTextColor = _primaryGreen;

class CarritoScreen extends StatelessWidget {
  final VoidCallback onClose;
  final VoidCallback onGoToShop;

  const CarritoScreen({
    super.key,
    required this.onClose,
    required this.onGoToShop,
  });

  // Formateador de moneda
  String _formatCurrency(int amount) {
    final formatter = NumberFormat.currency(
      locale: 'es_CO', // o el locale que uses (ej: 'es_ES')
      symbol: '\$',
      decimalDigits: 0,
    );
    // Asume que la cantidad está en centavos si es necesario, pero aquí asumimos que es un entero en COP
    return formatter.format(amount).replaceAll(',00', '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
            color: _unselectedDarkColor,
          ),
          onPressed: onClose,
        ),
        title: const Text(
          'Tu Carrito',
          style: TextStyle(
            fontSize: 20,
            fontFamily: "roboto",
            fontWeight: FontWeight.bold,
            color: _unselectedDarkColor,
          ),
        ),
        centerTitle: false,
        titleSpacing: 0.0,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      // Utilizamos Consumer para escuchar los cambios en el CartProvider
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          final isCartEmpty = cartProvider.itemCount == 0;

          return Column(
            children: [
              const Divider(height: 1, color: _secondaryLightColor),

              // --- Contenido del Carrito (Lista de productos) ---
              Expanded(
                child: isCartEmpty
                    ? _buildEmptyCart(
                        context,
                      ) // Muestra el mensaje de carrito vacío
                    : _buildCartContent(
                        context,
                        cartProvider,
                      ), // Muestra la lista de productos
              ),

              // --- Resumen de Pago y Botón de Checkout ---
              if (!isCartEmpty) _buildCheckoutSummary(context, cartProvider),
            ],
          );
        },
      ),
    );
  }

  // Widget para mostrar el estado de Carrito Vacío (Se mantiene tu código original)
  Widget _buildEmptyCart(BuildContext context) {
    // ... (Tu código para _buildEmptyCart)
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: _orangeColor,
            ),
            const SizedBox(height: 16),
            const Text(
              '¡Tu carrito está vacío!',
              style: TextStyle(
                fontSize: 20,
                fontFamily: "roboto",
                fontWeight: FontWeight.bold,
                color: _unselectedDarkColor,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Parece que aún no has agregado productos a granel.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 14,
                fontFamily: "roboto",
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: onGoToShop,
              icon: const Icon(Icons.storefront_outlined, size: 24),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 12.0),
                child: Text(
                  'Ir a la Tienda',
                  style: TextStyle(fontSize: 20, fontFamily: "roboto"),
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: _primaryGreen,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ********** WIDGET PRINCIPAL DEL CONTENIDO DEL CARRITO (ListView) **********
  Widget _buildCartContent(BuildContext context, CartProvider cartProvider) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // La lista original de productos (usando Column y iterando, o ListView sin el SingleChildScrollView)
            // Para mantener la simplicidad y el ListView.builder existente, se podría cambiar el
            // `Expanded` en el `build` principal a un `SingleChildScrollView` y usar un `Column` aquí.

            // He modificado la estructura para permitir el resumen DESPUÉS de la lista.
            ...cartProvider.items.map((cartItem) {
              return _CartItemWidget(
                item: cartItem,
                formatCurrency: _formatCurrency,
                onQuantityChanged: (newQuantity) {
                  cartProvider.updateItemQuantity(cartItem, newQuantity);
                },
                onRemove: () {
                  cartProvider.removeItem(cartItem);
                },
              );
            }),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ********** NUEVO WIDGET PARA EL MENSAJE DE ENVÍO GRATIS **********
  Widget _buildShippingMessage(int subtotal) {
    final isFree = subtotal >= _freeShippingThreshold;

    final String message = isFree
        ? '¡Envío gratis aplicado!'
        : '¡Te falta poco! A partir de ${_formatCurrency(_freeShippingThreshold)} COP en compras, obtienes envío gratis.';

    return Container(
      padding: const EdgeInsets.all(12.0),
      margin: const EdgeInsets.only(bottom: 20.0),
      decoration: BoxDecoration(
        color: isFree ? _shippingMessageBackground : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFree ? _primaryGreen : Colors.grey.shade300,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.local_shipping_outlined,
            color: isFree ? _shippingMessageTextColor : _unselectedDarkColor,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: isFree
                    ? _shippingMessageTextColor
                    : _unselectedDarkColor,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ********** WIDGET DE RESUMEN DE PAGO (MODIFICADO) **********
  Widget _buildCheckoutSummary(
    BuildContext context,
    CartProvider cartProvider,
  ) {
    final int subtotal = cartProvider.totalAmount;
    final bool isFreeShipping = subtotal >= _freeShippingThreshold;
    final int shipping = isFreeShipping ? 0 : _standardShippingCost;
    final int total = subtotal + shipping;

    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey.shade200)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 0)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 1. Mensaje de Envío Gratis
          _buildShippingMessage(subtotal),

          // 2. Fila de Subtotal
          _buildSummaryRow(
            'Subtotal',
            _formatCurrency(subtotal),
            isTotal: false,
          ),
          const SizedBox(height: 5),

          // 3. Fila de Envío
          _buildSummaryRow(
            'Envío',
            isFreeShipping ? 'Gratis' : _formatCurrency(shipping),
            isTotal: false,
            isShipping: true,
          ),
          const Divider(height: 20, color: Colors.grey),

          // 4. Fila de Total
          _buildSummaryRow('Total', _formatCurrency(total), isTotal: true),
          const SizedBox(height: 15),

          // 5. Botón de Finalizar Compra
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Lógica de pago: Navegar a la pantalla de Checkout/Pago
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Procediendo al pago...')),
                );
              },
              icon: const Icon(Icons.shopping_cart_outlined, size: 24),
              label: const Padding(
                padding: EdgeInsets.symmetric(vertical: 15.0),
                child: Text(
                  'Finalizar compra',
                  style: TextStyle(fontSize: 20, fontFamily: "roboto"),
                ),
              ),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: _primaryGreen, // Usa el verde primario
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                elevation: 5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ********** WIDGET AUXILIAR PARA LAS FILAS DE RESUMEN **********
  Widget _buildSummaryRow(
    String title,
    String value, {
    required bool isTotal,
    bool isShipping = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? _darkTextColor : Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 18 : 16,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal
                ? _darkTextColor
                : (isShipping && value == 'Gratis')
                ? _primaryGreen
                : _darkTextColor,
          ),
        ),
      ],
    );
  }
}

// ********** WIDGET INDIVIDUAL DEL ITEM DEL CARRITO **********
// (Se mantiene sin cambios, pero debe estar fuera de la clase CarritoScreen para ser usado)
class _CartItemWidget extends StatelessWidget {
  final CartItem item;
  final String Function(int) formatCurrency;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const _CartItemWidget({
    required this.item,
    required this.formatCurrency,
    required this.onQuantityChanged,
    required this.onRemove,
  });

  // Widget auxiliar para los botones +/-
  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    required bool isEnabled,
  }) {
    return InkWell(
      onTap: isEnabled ? onTap : null,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: isEnabled ? Colors.grey.shade400 : Colors.grey.shade300,
          ),
          borderRadius: BorderRadius.circular(6),
          color: isEnabled ? Colors.white : Colors.grey.shade100,
        ),
        child: Icon(
          icon,
          color: isEnabled ? _darkTextColor : Colors.grey,
          size: 20,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 1. Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                item.imagePath,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 12),

            // 2. Información y Controles
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Nombre del Producto
                  Text(
                    item.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _darkTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Unidad de Peso y Precio Unitario
                  Text(
                    '${formatCurrency(item.unitPrice)} / ${item.weightUnit}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),

                  // ********** CONTROLES DE CANTIDAD **********
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          // Botón Menos
                          _buildQuantityButton(
                            icon: Icons.remove,
                            isEnabled: item.quantity > 1,
                            onTap: () => onQuantityChanged(item.quantity - 1),
                          ),

                          // Cantidad Actual
                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10.0,
                            ),
                            child: Text(
                              '${item.quantity}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // Botón Más
                          _buildQuantityButton(
                            icon: Icons.add,
                            isEnabled: true,
                            onTap: () => onQuantityChanged(item.quantity + 1),
                          ),
                        ],
                      ),

                      // Precio Total por Ítem
                      Text(
                        formatCurrency(item.totalPrice),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // 3. Botón de Eliminar (Icono 'X')
            IconButton(
              icon: const Icon(Icons.delete_outline, color: _orangeColor),
              onPressed: onRemove,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
      ),
    );
  }
}

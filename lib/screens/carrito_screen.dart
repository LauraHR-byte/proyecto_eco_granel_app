import 'package:flutter/material.dart';

// Constantes de Color
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);
const Color _secondaryLightColor = Color(
  0xFFF0F0F0,
); // Gris muy claro para fondo

class CarritoScreen extends StatelessWidget {
  // 1. Callback para cerrar el carrito
  final VoidCallback onClose;
  // 2. Callback para navegar a la tienda
  final VoidCallback onGoToShop;

  // Si el carrito está vacío
  final bool _isCartEmpty = true;

  const CarritoScreen({
    super.key,
    required this.onClose,
    required this.onGoToShop,
  });

  @override
  Widget build(BuildContext context) {
    // El Scaffold maneja automáticamente la barra de estado (SafeArea) y el AppBar.
    return Scaffold(
      // 1. Usamos un AppBar estándar de Flutter.
      appBar: AppBar(
        // El ícono de retroceso (arrow_back) se muestra automáticamente.
        // Al presionarlo, el AppBar llamará a onClose para manejar el cierre desde main.dart.
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
            color: _unselectedDarkColor,
          ),
          onPressed: onClose, // Usamos el callback para cerrar
        ),
        title: const Text(
          'Tu Carrito',
          style: TextStyle(
            fontSize: 20,
            fontFamily: "roboto",
            fontWeight: FontWeight.bold,
            color:
                _unselectedDarkColor, // Asegura que el color sea oscuro si el fondo es blanco
          ),
        ),
        centerTitle: false,
        titleSpacing: 0.0,
        backgroundColor: Colors.white,
        elevation: 0,
      ),

      // El cuerpo del Scaffold
      body: Column(
        children: [
          const Divider(height: 1, color: _secondaryLightColor),

          // --- Contenido del Carrito ---
          Expanded(
            child: _isCartEmpty
                ? _buildEmptyCart(context) // Si está vacío, muestra el mensaje
                : _buildCartContent(), // Si tiene ítems, muestra la lista (aún por implementar)
          ),
        ],
      ),
    );
  }

  // Widget para mostrar el estado de Carrito Vacío
  Widget _buildEmptyCart(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // El icono del carrito
            const Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Color.fromRGBO(184, 94, 44, 1),
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

            // Botón "Ir a la Tienda"
            ElevatedButton.icon(
              onPressed:
                  onGoToShop, // Llama al callback que navega al índice 2 (Tienda)
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

  // Widget placeholder para el contenido del carrito (cuando no está vacío)
  Widget _buildCartContent() {
    return const Center(child: Text('Lista de productos aquí...'));
  }
}

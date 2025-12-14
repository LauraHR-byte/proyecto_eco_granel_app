import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:eco_granel_app/providers/cart_provider.dart';
import 'package:eco_granel_app/screens/carrito_screen.dart';

const Color _orangeColor = Color.fromRGBO(184, 94, 44, 1);

class CartIconButton extends StatelessWidget {
  final double iconSize;
  final Color? iconColor;

  const CartIconButton({super.key, this.iconSize = 28, this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Consumer<CartProvider>(
      builder: (context, cartProvider, _) {
        final itemCount = cartProvider.itemCount;

        return Stack(
          children: [
            IconButton(
              icon: Icon(
                Icons.shopping_cart,
                size: 30,
                color: Theme.of(context).appBarTheme.foregroundColor,
              ),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => CarritoScreen(
                      onClose: () => Navigator.of(context).pop(),
                      onGoToShop: () {},
                    ),
                  ),
                );
              },
            ),
            if (itemCount > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  decoration: BoxDecoration(
                    color: _orangeColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    itemCount.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}

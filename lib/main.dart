import 'package:eco_granel_app/screens/forum_screen.dart';
import 'package:eco_granel_app/screens/home_screen.dart';
import 'package:eco_granel_app/screens/perfil_screen.dart';
import 'package:eco_granel_app/screens/recetas_screen.dart';
import 'package:eco_granel_app/screens/carrito_screen.dart';
import 'package:eco_granel_app/screens/tienda_screen.dart';
import 'package:flutter/material.dart';

// Color verde para el tema
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF424242);

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          // El color del ícono del carrito
          foregroundColor: Color.fromRGBO(184, 94, 44, 1),
          elevation: 0,
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: _unselectedDarkColor),
          bodyMedium: TextStyle(color: _unselectedDarkColor),
          titleLarge: TextStyle(color: _unselectedDarkColor),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: Colors.white,
          selectedItemColor: _primaryGreen,
          unselectedItemColor: _unselectedDarkColor,
          showSelectedLabels: true,
          showUnselectedLabels: false,
          selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      home: const EcoGranel(),
    );
  }
}

class EcoGranel extends StatefulWidget {
  const EcoGranel({super.key});

  @override
  State<EcoGranel> createState() => _EcoGranelState();
}

class _EcoGranelState extends State<EcoGranel> {
  int _selectedIndex = 0;
  bool _isCartOpen = false;

  // Constante para el índice de la pantalla de perfil
  static const int _perfilIndex = 4;

  // 💡 AJUSTE CLAVE: Usamos un getter para construir la lista de widgets y pasar el callback.
  List<Widget> get _widgetOptions => <Widget>[
    // Pasamos el método _onItemTapped (que cambia el índice) a HomeScreen
    HomeScreen(onNavigate: _onItemTapped),
    const ForoScreen(),
    const TiendaScreen(),
    const Recetas(),
    const PerfilScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
      _isCartOpen = false;
    });
  }

  void _openCart() => setState(() => _isCartOpen = true);
  void _closeCart() => setState(() => _isCartOpen = false);
  void _goToShop() {
    setState(() {
      _closeCart();
      _selectedIndex = 2;
    });
  }

  static const double _iconSize = 32.0;

  // Widget para crear el AppBar
  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      centerTitle: false,
      title: Padding(
        padding: const EdgeInsets.only(
          left: 8.0,
        ), // Ajusta el padding según necesites
        child: SizedBox(
          height: 24, // Altura controlada del logo
          child: Image.asset(
            'assets/images/logo_ecogranel.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
      actions: <Widget>[
        IconButton(
          icon: const Icon(Icons.shopping_cart, size: _iconSize),
          onPressed: _openCart,
          color: Theme.of(context).appBarTheme.foregroundColor,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lógica para quitar el AppBar en la pantalla de Perfil
    final bool showAppBar = _selectedIndex != _perfilIndex;
    //El AppBar solo se muestra si el carrito NO está abierto.
    final bool shouldShowAppBar = showAppBar && !_isCartOpen;

    return Scaffold(
      // Si showAppBar es false (estamos en PerfilScreen), el AppBar es null.
      appBar: shouldShowAppBar ? _buildCustomAppBar() : null,
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isCartOpen,
            child: IndexedStack(
              index: _selectedIndex,
              children: _widgetOptions, // 👈 Usa el getter aquí
            ),
          ),

          //Usamos Visibility (o Offstage) para mostrar/ocultar instantáneamente el carrito.
          Visibility(
            visible: _isCartOpen,
            // Oscurece el fondo antes de que se muestre el carrito si lo necesitas,
            // color: Colors.black.withOpacity(0.4),
            child: CarritoScreen(onClose: _closeCart, onGoToShop: _goToShop),
          ),
        ],
      ),
      // Se mantiene la barra de navegación inferior, ya que es parte del layout principal.
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: _iconSize),
            label: "Inicio",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco, size: _iconSize),
            label: "Blog",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.storefront, size: _iconSize),
            label: "Tienda",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant, size: _iconSize),
            label: "Recetas",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_circle, size: _iconSize),
            label: "Perfil",
          ),
        ],
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

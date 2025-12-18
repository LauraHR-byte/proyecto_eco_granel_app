// Importaciones necesarias para Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:eco_granel_app/firebase_options.dart';
import 'package:flutter/material.dart';

// ********** IMPORTACIÓN DE PROVIDER Y CARTSERVICE **********
import 'package:provider/provider.dart';
import 'package:eco_granel_app/providers/cart_provider.dart';
// **********************************************************

// Importación de persistencia para guardar el estado
import 'package:shared_preferences/shared_preferences.dart';
// Importación de Firebase Auth para verificar el estado de inicio de sesión
import 'package:firebase_auth/firebase_auth.dart';
// *** IMPORTACIÓN PARA LA MONEDA ***
import 'package:intl/date_symbol_data_local.dart';

// Importación de tu pantalla de Onboarding
import 'package:eco_granel_app/onboarding/onboarding_screen.dart';
// importacion pantalla de InicioScreen
import 'package:eco_granel_app/login/inicio_screen.dart';

// Importaciones de tus pantallas principales
import 'package:eco_granel_app/screens/forum_screen.dart';
import 'package:eco_granel_app/screens/home_screen.dart';
import 'package:eco_granel_app/screens/perfil_screen.dart';
import 'package:eco_granel_app/screens/recetas_screen.dart';
import 'package:eco_granel_app/screens/carrito_screen.dart';
import 'package:eco_granel_app/screens/tienda_screen.dart';

// Widget

// Definiciones de Color
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);
// ***** CORRECCIÓN 1: Definición de _orangeColor *****
const Color _orangeColor = Color.fromRGBO(184, 94, 44, 1);

// CLAVE DE SHARED PREFERENCES
const String kOnboardingCompleteKey = 'onboarding_complete';

// Variables globales para almacenar el estado inicial
late bool _onboardingIsComplete;
User? _currentUser;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // *** INICIALIZACIÓN DE FORMATO DE MONEDA/FECHA (COLOMBIA) ***
  // Esto permite que 'es_CO' funcione correctamente en toda la app
  await initializeDateFormatting('es_CO', null);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final prefs = await SharedPreferences.getInstance();

  _onboardingIsComplete = prefs.getBool(kOnboardingCompleteKey) ?? false;

  _currentUser = FirebaseAuth.instance.currentUser;

  // Envoltura con Provider
  runApp(
    ChangeNotifierProvider(
      create: (context) => CartProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Widget _getInitialScreen() {
    if (!_onboardingIsComplete) {
      // 1. Onboarding NO Completo: Mostrar OnboardingScreen
      return const InitialScreenDecider();
    } else {
      // 2. Onboarding COMPLETO: Decidir entre InicioScreen y HomeScreen
      if (_currentUser != null) {
        // 2a. SÍ Autenticado: Mostrar la pantalla principal (HomeScreen/EcoGranel)
        return const EcoGranel();
      } else {
        // 2b. NO Autenticado: Mostrar la pantalla de inicio de sesión/registro
        return const InicioScreen();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          // Se usa _orangeColor, que ahora está definido.
          foregroundColor: _orangeColor,
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
      home: _getInitialScreen(),
    );
  }
}

// ***** WIDGET PARA GESTIONAR LA PANTALLA INICIAL Y EL ESTADO DE ONBOARDING *****
// Este widget debe existir en el archivo main.dart si no se importa.
class InitialScreenDecider extends StatefulWidget {
  const InitialScreenDecider({super.key});

  @override
  State<InitialScreenDecider> createState() => _InitialScreenDeciderState();
}

class _InitialScreenDeciderState extends State<InitialScreenDecider> {
  bool _showOnboarding = true;

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(kOnboardingCompleteKey, true);

    setState(() {
      _showOnboarding = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      return OnboardingScreen(onOnboardingComplete: _completeOnboarding);
    } else {
      return const InicioScreen();
    }
  }
}

// --- WIDGET PRINCIPAL DE LA APLICACIÓN (EcoGranel) ---
class EcoGranel extends StatefulWidget {
  const EcoGranel({super.key});

  @override
  State<EcoGranel> createState() => _EcoGranelState();
}

class _EcoGranelState extends State<EcoGranel> {
  int _selectedIndex = 0;
  bool _isCartOpen = false;

  static const int _perfilIndex = 4;

  List<Widget> get _widgetOptions => <Widget>[
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
      _selectedIndex = 2; //Tienda
    });
  }

  static const double _iconSize = 32.0;

  PreferredSizeWidget _buildCustomAppBar() {
    return AppBar(
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: SizedBox(
          height: 24,
          child: Image.asset(
            'assets/images/logo_ecogranel.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
      actions: <Widget>[
        Padding(
          padding: const EdgeInsets.only(right: 8.0),
          child: Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              final itemCount = cartProvider.itemCount;
              return Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.shopping_cart, size: 30),
                    onPressed: _openCart,
                    color: Theme.of(context).appBarTheme.foregroundColor,
                  ),
                  if (itemCount > 0)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          // ***** CORRECCIÓN 2: Uso de _orangeColor definido *****
                          color: _orangeColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 18,
                          minHeight: 18,
                        ),
                        child: Text(
                          itemCount.toString(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool showAppBar = _selectedIndex != _perfilIndex;
    final bool shouldShowAppBar = showAppBar && !_isCartOpen;

    return Scaffold(
      appBar: shouldShowAppBar ? _buildCustomAppBar() : null,
      body: Stack(
        children: [
          AbsorbPointer(
            absorbing: _isCartOpen,
            child: IndexedStack(
              index: _selectedIndex,
              children: _widgetOptions,
            ),
          ),

          // Carrito como superposición
          Visibility(
            visible: _isCartOpen,
            child: CarritoScreen(onClose: _closeCart, onGoToShop: _goToShop),
          ),
        ],
      ),
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

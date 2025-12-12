// Importaciones necesarias para Firebase
import 'package:firebase_core/firebase_core.dart';
import 'package:eco_granel_app/firebase_options.dart';
import 'package:flutter/material.dart';
// 💡 Importación de persistencia para guardar el estado
import 'package:shared_preferences/shared_preferences.dart';
// 💡 Importación de Firebase Auth para verificar el estado de inicio de sesión
import 'package:firebase_auth/firebase_auth.dart';

// Importación de tu pantalla de Onboarding (Asegúrate de que la ruta sea correcta)
import 'package:eco_granel_app/onboarding/onboarding_screen.dart';
// importacion pantalla de InicioScreen
import 'package:eco_granel_app/login/inicio_screen.dart'; // 💡 Asegúrate de que esta pantalla sea la que quieres mostrar al NO estar logueado.

// Importaciones de tus pantallas principales
import 'package:eco_granel_app/screens/forum_screen.dart';
import 'package:eco_granel_app/screens/home_screen.dart';
import 'package:eco_granel_app/screens/perfil_screen.dart';
import 'package:eco_granel_app/screens/recetas_screen.dart';
import 'package:eco_granel_app/screens/carrito_screen.dart';
import 'package:eco_granel_app/screens/tienda_screen.dart';

// Definiciones de Color
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);

// 💡 CLAVE DE SHARED PREFERENCES
const String kOnboardingCompleteKey = 'onboarding_complete';
// 💡 CAMBIO: Ya no es necesaria una clave separada para la autenticación si usamos Firebase Auth.

// 💡 CAMBIO: Variables globales para almacenar el estado inicial
late bool _onboardingIsComplete;
// 💡 CAMBIO: El usuario de Firebase (será null si no está autenticado)
User? _currentUser;

// ** FUNCIÓN MAIN MODIFICADA **
void main() async {
  // Asegura que Flutter esté listo para la inicialización asíncrona (await)
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 1. OBTENER ESTADO DE ONBOARDING
  final prefs = await SharedPreferences.getInstance();

  // Leer el valor. Si es nulo (primera vez), se asume que NO está completo (false).
  _onboardingIsComplete = prefs.getBool(kOnboardingCompleteKey) ?? false;

  // 💡 CAMBIO: OBTENER ESTADO DE AUTENTICACIÓN
  // Obtiene el usuario actualmente logueado. Si es null, el usuario no está autenticado.
  _currentUser = FirebaseAuth.instance.currentUser;

  // Ejecuta la aplicación
  runApp(const MyApp());
}
// ** FIN FUNCIÓN MAIN MODIFICADA **

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // 💡 CAMBIO: Nueva función para determinar la pantalla inicial
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
      // 2. LÓGICA DE NAVEGACIÓN INICIAL AJUSTADA
      home: _getInitialScreen(),
    );
  }
}

// 💡 WIDGET PARA GESTIONAR LA PANTALLA INICIAL Y EL ESTADO DE ONBOARDING
class InitialScreenDecider extends StatefulWidget {
  const InitialScreenDecider({super.key});

  @override
  State<InitialScreenDecider> createState() => _InitialScreenDeciderState();
}

class _InitialScreenDeciderState extends State<InitialScreenDecider> {
  // Inicialmente, si llegamos aquí, mostramos el onboarding
  bool _showOnboarding = true;

  // Función de callback que se ejecuta cuando el usuario termina o salta el onboarding
  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();

    // 3. GUARDAR EL ESTADO COMO COMPLETADO (true)
    await prefs.setBool(kOnboardingCompleteKey, true);

    setState(() {
      _showOnboarding =
          false; // Esto dispara el cambio a la pantalla de InicioScreen
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_showOnboarding) {
      // Muestra la pantalla de Onboarding y le pasa el callback para guardar el estado.
      return OnboardingScreen(onOnboardingComplete: _completeOnboarding);
    } else {
      // 💡 CAMBIO: Después de completar el onboarding, va a InicioScreen (ya que el usuario aún no se ha logueado).
      return const InicioScreen();
    }
  }
}

// --- WIDGET PRINCIPAL DE LA APLICACIÓN (EcoGranel) ---
// Este widget es la pantalla principal que se muestra SÍ el usuario está autenticado.
// No necesita cambios, ya que ahora se accede a ella únicamente si _currentUser != null.

class EcoGranel extends StatefulWidget {
  const EcoGranel({super.key});

  @override
  State<EcoGranel> createState() => _EcoGranelState();
}

class _EcoGranelState extends State<EcoGranel> {
  int _selectedIndex = 0;
  bool _isCartOpen = false;
  // ... (El resto del código de EcoGranel sigue igual)
  // Constante para el índice de la pantalla de perfil
  static const int _perfilIndex = 4;

  // Usamos un getter para construir la lista de widgets
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
      automaticallyImplyLeading: false,
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
      // Barra de navegación inferior
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

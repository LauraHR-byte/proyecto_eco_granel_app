import 'package:flutter/material.dart';
// ¡IMPORTANTE! Asegúrate de que esta importación es correcta
import 'package:eco_granel_app/login/inicio_screen.dart';

// 1. IMPORTAR LIBRERÍAS DE FIREBASE
import 'package:cloud_firestore/cloud_firestore.dart';

const Color _primaryGreen = Color(0xFF4CAF50);
const Color _brownButtonColor = Color(0xFFB85E2C); // Color del botón Continuar

// --- 1. ESTRUCTURA DE DATOS (Se mantiene igual) ---
class OnboardingPageData {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.imagePath,
  });

  // Constructor de fábrica para crear un objeto desde un DocumentSnapshot de Firestore
  factory OnboardingPageData.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return OnboardingPageData(
      // Se asume que los campos existen en Firestore. Usa '??' para manejo de nulos si es necesario.
      title: data['title'] as String? ?? 'Título no encontrado',
      description:
          data['description'] as String? ?? 'Descripción no encontrada',
      imagePath:
          data['imagePath'] as String? ??
          'assets/images/placeholder.png', // Usa una imagen placeholder local
    );
  }
}

// --- 2. WIDGET PRINCIPAL (Ahora gestiona la carga) ---

class OnboardingScreen extends StatefulWidget {
  // CAMBIO: onOnboardingComplete ya no es obligatorio si manejamos la navegación aquí
  final VoidCallback? onOnboardingComplete;

  // CAMBIO: Se ajusta el constructor
  const OnboardingScreen({super.key, this.onOnboardingComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controlador para PageView
  final PageController _pageController = PageController();
  // Índice de la página actual.
  int _currentPage = 0;

  // NUEVOS CAMPOS PARA DATOS Y ESTADO DE CARGA
  List<OnboardingPageData> _onboardingPages = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchOnboardingData(); // Iniciar la carga de datos
  }

  // --- FUNCIÓN DE CARGA DE FIREBASE ---
  Future<void> _fetchOnboardingData() async {
    try {
      // 3. Obtener una referencia a la colección de Firestore
      final collection = FirebaseFirestore.instance
          .collection('onboardingPages')
          // OPCIONAL: Ordenar por un campo si quieres garantizar el orden
          .orderBy('orderIndex', descending: false);

      // 4. Obtener los documentos
      final snapshot = await collection.get();

      // 5. Mapear los documentos a la lista de objetos OnboardingPageData
      final loadedPages = snapshot.docs
          .map((doc) => OnboardingPageData.fromFirestore(doc))
          .toList();

      setState(() {
        _onboardingPages = loadedPages;
        _isLoading = false; // La carga ha terminado
      });
    } catch (e) {
      // Manejar errores de lectura
      debugPrint("Error al cargar datos de Onboarding: $e");
      setState(() {
        _error =
            "No se pudieron cargar los datos de introducción. Revisa tu conexión a internet o la configuración de Firebase.";
        _isLoading = false;
      });
    }
  }

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  // CAMBIO: Se modifica para que al llegar a la última página navegue a InicioScreen
  void _goToNextPage() {
    if (_currentPage < _onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
    } else {
      // Navegar a InicioScreen y reemplazar la pantalla actual
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const InicioScreen()),
      );
      // Opcionalmente, si el callback original tiene otra función (ej. guardar un estado), se ejecuta:
      widget.onOnboardingComplete?.call();
    }
  }

  // Define el texto del botón según si es la última página
  String get _buttonText {
    // Usamos _onboardingPages.length para asegurar que los datos ya están cargados
    final isLastPage =
        _onboardingPages.isNotEmpty &&
        _currentPage == _onboardingPages.length - 1;
    return isLastPage ? "Comenzar" : "Continuar";
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // --- 3. WIDGET BUILD MODIFICADO ---

  @override
  Widget build(BuildContext context) {
    // Mostrar un indicador de carga si los datos aún no están listos
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: _primaryGreen)),
      );
    }

    // Mostrar un mensaje de error si la carga falla
    if (_error != null) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: Text(_error!, textAlign: TextAlign.center),
          ),
        ),
      );
    }

    // Si los datos están cargados (y no hay error), mostrar la UI normal
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Botón Saltar alineado a la derecha
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                // CAMBIO CLAVE: Usa Navigator.pushReplacement para ir a InicioScreen
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => const InicioScreen(),
                    ),
                  );
                },
                child: const Text(
                  "Saltar",
                  style: TextStyle(color: _brownButtonColor, fontSize: 16),
                ),
              ),
            ),

            // PageView que ocupa la mayor parte del espacio
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                // Usamos la longitud de la lista cargada
                itemCount: _onboardingPages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  // Usamos los datos cargados de Firebase
                  return OnboardingPageView(data: _onboardingPages[index]);
                },
              ),
            ),

            // Indicadores de página y botón "Continuar"
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 16.0,
              ),
              child: Column(
                children: [
                  // Indicadores (Dots)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      // Usamos la longitud de la lista cargada
                      _onboardingPages.length,
                      (index) => buildDot(index, context),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Botón Continuar / Comenzar
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _goToNextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _brownButtonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        _buttonText,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget para construir los indicadores de página (dots)
  Widget buildDot(int index, BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? _primaryGreen : Colors.grey.shade300,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// --- WIDGET PARA CADA PÁGINA INDIVIDUAL (Se mantiene igual) ---

class OnboardingPageView extends StatelessWidget {
  final OnboardingPageData data;

  const OnboardingPageView({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Título principal
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(height: 16),

          // Descripción
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 20,
              color: Color(0xFF333333),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),

          // Imagen (Cargada desde una URL de red)
          Expanded(
            child: Center(
              child:
                  // Se usa Image.network ya que las imágenes de Firestore/Storage
                  // son generalmente URLs (aunque depende de tu setup).
                  Image.network(
                    data.imagePath,
                    fit: BoxFit.contain,
                    // Manejar error/carga si la imagen es lenta o no existe
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                              : null,
                          color: _primaryGreen,
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error, size: 100, color: Colors.grey),
                  ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

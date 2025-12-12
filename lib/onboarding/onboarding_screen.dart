import 'package:flutter/material.dart';
// ¡IMPORTANTE! Asegúrate de que esta importación es correcta
import 'package:eco_granel_app/login/inicio_screen.dart';

// 1. IMPORTAR LIBRERÍAS DE FIREBASE
import 'package:cloud_firestore/cloud_firestore.dart';

const Color _primaryGreen = Color(0xFF4CAF50);
const Color _textColor = Color(0xFF333333);
const Color _brownButtonColor = Color(0xFFC76939); // Color del botón Continuar

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

  // NUEVO GETTER: Comprueba si es la última página
  bool get _isLastPage {
    return _onboardingPages.isNotEmpty &&
        _currentPage == _onboardingPages.length - 1;
  }

  // Define el texto del botón según si es la última página
  String get _buttonText {
    // Usamos _onboardingPages.length para asegurar que los datos ya están cargados
    return _isLastPage ? "Comenzar" : "Continuar";
  }

  // NUEVO GETTER para el color del botón
  Color get _buttonColor {
    // Si es la última página, usa _primaryGreen, de lo contrario, usa _brownButtonColor
    return _isLastPage ? _primaryGreen : _brownButtonColor;
  }

  // *** NUEVA FUNCIÓN AÑADIDA PARA SALTAR A LA ÚLTIMA PÁGINA ***
  void _goToLastPage() {
    if (_onboardingPages.isNotEmpty) {
      _pageController.animateToPage(
        _onboardingPages.length - 1, // El índice de la última página
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeOut,
      );
    }
  }
  // *** FIN DE LA NUEVA FUNCIÓN ***

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
            // *** INICIO DEL AJUSTE PARA MANTENER LA MARGEN SUPERIOR ***
            Container(
              // Este contenedor o SizedBox garantiza que el espacio superior sea el mismo
              // en todas las páginas, independientemente de si el botón "Saltar" se muestra o no.
              alignment: Alignment.topRight,
              // Ajusta este padding si el TextButton original tenía más padding.
              padding: const EdgeInsets.only(right: 8.0, top: 8.0),
              child: _isLastPage
                  ? const SizedBox(
                      // Usamos un SizedBox para ocupar el mismo espacio
                      // que ocuparía el TextButton si estuviera visible.
                      // La altura de un TextButton por defecto es aproximadamente 48-50.
                      height: 48,
                    )
                  : TextButton(
                      // *** MODIFICACIÓN CLAVE AQUÍ: Llama a _goToLastPage() ***
                      onPressed: _goToLastPage,
                      // *** FIN DE LA MODIFICACIÓN CLAVE ***
                      child: const Text(
                        "Saltar",
                        style: TextStyle(
                          color: _textColor,
                          fontFamily: "roboto",
                          fontSize: 15,
                        ),
                      ),
                    ),
            ),
            // *** FIN DEL AJUSTE ***

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
                vertical: 24.0,
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
                        // *** CAMBIO REALIZADO AQUÍ: Usa _buttonColor ***
                        backgroundColor: _buttonColor,
                        // *** FIN DEL CAMBIO ***
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
      padding: const EdgeInsets.symmetric(horizontal: 60.0, vertical: 60.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Título principal
          Text(
            data.title,
            style: const TextStyle(
              fontSize: 30,
              fontFamily: "roboto",
              fontWeight: FontWeight.bold,
              color: _primaryGreen,
            ),
          ),
          const SizedBox(height: 30),

          // Descripción
          Text(
            data.description,
            style: const TextStyle(
              fontSize: 18,
              color: _textColor,
              fontFamily: "roboto",
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

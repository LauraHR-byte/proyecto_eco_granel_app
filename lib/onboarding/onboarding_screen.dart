import 'package:flutter/material.dart';

const Color _primaryGreen = Color(0xFF4CAF50);

// --- DATOS DEL ONBOARDING ---
// Define la estructura de datos para cada página
class OnboardingPageData {
  final String title;
  final String description;
  final String imagePath;

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.imagePath,
  });
}

// Lista de los 5 pasos (ejemplo con rutas de imagen dummy)
const List<OnboardingPageData> onboardingPages = [
  OnboardingPageData(
    title: "Bienvenido a Eco Granel",
    description:
        "Tu espacio para comprar a granel, inspirarte y vivir de forma más sostenible.",
    // Usaremos la misma imagen por ahora, pero aquí iría la ruta para cada paso
    imagePath: 'assets/images/onboarding_step1.png',
  ),
  OnboardingPageData(
    title: "¿Qué es el Granel?",
    description:
        "Compra solo lo que necesitas, reduce el desperdicio de envases y ahorra dinero.",
    imagePath: 'assets/images/onboarding_step2.png',
  ),
  OnboardingPageData(
    title: "Explora la Tienda",
    description:
        "Encuentra frutos secos, cereales, especias y más, con opciones veganas y orgánicas.",
    imagePath: 'assets/images/onboarding_step3.png',
  ),
  OnboardingPageData(
    title: "Únete a la Comunidad",
    description:
        "Comparte recetas, consejos sostenibles y aprende en nuestro foro con otros ecograneleros.",
    imagePath: 'assets/images/onboarding_step4.png',
  ),
  OnboardingPageData(
    title: "¡Empieza a Granel!",
    description:
        "Estás listo para dar el primer paso hacia un estilo de vida más verde. ¡A disfrutar!",
    imagePath: 'assets/images/onboarding_step5.png',
  ),
];

// --- WIDGET PRINCIPAL ---

class OnboardingScreen extends StatefulWidget {
  // El callback que se llama cuando el usuario termina o salta el onboarding.
  final VoidCallback onOnboardingComplete;

  const OnboardingScreen({super.key, required this.onOnboardingComplete});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Controlador para PageView, permite cambiar de página programáticamente.
  final PageController _pageController = PageController();
  // Índice de la página actual.
  int _currentPage = 0;
  // Color principal de la aplicación
  static const Color _primaryGreen = Color(0xFF4CAF50);
  // Color del botón Continuar (marrón)
  static const Color _brownButtonColor = Color(0xFFB85E2C);

  void _onPageChanged(int index) {
    setState(() {
      _currentPage = index;
    });
  }

  void _goToNextPage() {
    if (_currentPage < onboardingPages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeIn,
      );
    } else {
      // Si es la última página, llama al callback para completar el onboarding
      widget.onOnboardingComplete();
    }
  }

  // Define el texto del botón según si es la última página
  String get _buttonText {
    return _currentPage == onboardingPages.length - 1
        ? "Comenzar"
        : "Continuar";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Padding general para el botón "Saltar"
      body: SafeArea(
        child: Column(
          children: [
            // Botón Saltar alineado a la derecha
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: widget.onOnboardingComplete,
                child: const Text(
                  "Saltar",
                  style: TextStyle(
                    color: _brownButtonColor, // Color del botón Saltar
                    fontSize: 16,
                  ),
                ),
              ),
            ),

            // PageView que ocupa la mayor parte del espacio
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: onboardingPages.length,
                onPageChanged: _onPageChanged,
                itemBuilder: (context, index) {
                  return OnboardingPageView(data: onboardingPages[index]);
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
                      onboardingPages.length,
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

// --- WIDGET PARA CADA PÁGINA INDIVIDUAL ---

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
              color: Color(0xFF333333), // Color oscuro
              height: 1.4,
            ),
          ),
          const SizedBox(height: 40),

          // Imagen (Asegúrate de que tus assets estén configurados en pubspec.yaml)
          Expanded(
            child: Center(
              // Usamos el widget de imagen que tienes en tu diseño.
              // En un proyecto real, necesitarías 5 imágenes diferentes.
              child: Image.asset(
                'assets/images/image_902fa2.png', // Usando la imagen base de tu prototipo
                fit: BoxFit.contain,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

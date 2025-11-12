import 'package:flutter/material.dart';

// --- Constantes de Estilo ---
const Color _unselectedDarkColor = Color(0xFF424242);

// --- Componentes Reutilizables ---

/// Widget para los títulos de sección grandes.
class _SectionTitle extends StatelessWidget {
  final String title;
  // REMOVIDO: super.key para eliminar advertencia de parámetro no usado.
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 15.0, bottom: 4.0),
      child: Text(
        title,
        style: const TextStyle(
          color: _unselectedDarkColor,
          fontSize: 16,
          fontFamily: "roboto",
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

/// Widget para los puntos con viñetas.
class _TerminosPoint extends StatelessWidget {
  final String text;
  // REMOVIDO: super.key para eliminar advertencia de parámetro no usado.
  const _TerminosPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '•',
            style: TextStyle(
              fontSize: 18,
              color: _unselectedDarkColor,
              height: 1.4,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 14,
                fontFamily: "roboto",
                color: _unselectedDarkColor,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Widget para los párrafos de política, con soporte opcional para texto en negrita.
class _PolicyParagraph extends StatelessWidget {
  final String text;
  final FontWeight fontWeight;
  final Color color;
  final String? boldText;

  const _PolicyParagraph({
    required this.text,
    this.fontWeight = FontWeight.normal,
    this.color = _unselectedDarkColor,
    this.boldText,
    // REMOVIDO: super.key para eliminar advertencia de parámetro no usado.
  });

  @override
  Widget build(BuildContext context) {
    // Estilo base
    final baseStyle = TextStyle(
      fontSize: 14,
      fontFamily: "roboto",
      color: color,
      fontWeight: fontWeight,
      height: 1.5,
    );

    // Si se proporciona 'boldText' y el texto lo contiene, usamos RichText.
    if (boldText != null && text.contains(boldText!)) {
      final parts = text.split(boldText!);
      final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(text: parts.first, style: baseStyle),
              TextSpan(text: boldText, style: boldStyle),
              if (parts.length > 1)
                TextSpan(text: parts.last, style: baseStyle),
            ],
          ),
        ),
      );
    }

    // Si no hay texto en negrilla específico, volvemos a usar el simple Text.
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(text, style: baseStyle),
    );
  }
}

// --- Pantalla Principal ---

class CondicionesScreen extends StatelessWidget {
  const CondicionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0.0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
            color: _unselectedDarkColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Terminos y Condiciones",
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _unselectedDarkColor,
            fontSize: 20,
            fontFamily: "roboto",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),

              // Introducción
              const _PolicyParagraph(
                text:
                    "Al utilizar nuestra App Eco Granel, aceptas estos términos y condiciones.",
                fontWeight: FontWeight.normal,
                color: _unselectedDarkColor,
              ),

              // 1. Uso de la App
              const _SectionTitle(title: "Uso de la App"),
              const _PolicyParagraph(
                text:
                    "Esta App está destinado para compras personales. No permitimos la reventa de productos sin autorización.",
              ),

              // 2. Productos y Precios
              const _SectionTitle(title: "Productos y Precios"),
              const _TerminosPoint(
                text:
                    "Todos nuestros productos son naturales y a granel, sin empaques innecesarios.",
              ),
              const _TerminosPoint(
                text:
                    "Los precios están en [moneda local] e incluyen impuestos aplicables.",
              ),
              const _TerminosPoint(
                text:
                    "Nos reservamos el derecho de modificar precios y disponibilidad en cualquier momento.",
              ),

              // 3. Pagos y Seguridad
              const _SectionTitle(title: "Pagos y Seguridad"),
              const _PolicyParagraph(
                text:
                    "Aceptamos pagos seguros a través de múltiples métodos. Toda la información financiera se procesa con protocolos de seguridad avanzados.",
                // USADO: boldText se usa aquí para eliminar la advertencia del parámetro 'boldText'.
                boldText: "protocolos de seguridad avanzados",
              ),

              // 4. Responsabilidad del Usuario
              const _SectionTitle(title: "Responsabilidad del Usuario"),
              const _PolicyParagraph(
                text:
                    "Al hacer una compra, te comprometes a proporcionar información veraz y a usar este sitio de manera ética y respetuosa.",
              ),

              // Mensaje final (estilo negrita)
              const _PolicyParagraph(
                text:
                    "Si compras con nosotros, estás apoyando un modelo de consumo consciente y sostenible. Gracias por ser parte del cambio.",
                fontWeight: FontWeight.bold,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

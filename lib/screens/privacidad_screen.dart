import 'package:flutter/material.dart';

// --- Constantes de Estilo (Tomadas de la referencia) ---

// Definición del color oscuro para títulos y texto principal
const Color _unselectedDarkColor = Color(0xFF424242);
// Color más oscuro para los títulos de sección en la imagen.
// --- Componentes Reutilizables  ---

/// Widget para los títulos de sección grandes (Información Recopilada, Uso, etc.)
class _SectionTitle extends StatelessWidget {
  final String title;
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

/// Widget para los puntos con viñetas (Uso de la Información)
class _PolicyPoint extends StatelessWidget {
  final String text;
  const _PolicyPoint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 2.0, bottom: 2.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Viñeta (un punto simple de texto para más control)
          // Se ajusta el tamaño y el color para que se vea como una viñeta discreta.
          const Text(
            '•', // Viñeta simple
            style: TextStyle(
              fontSize: 18, // Tamaño de viñeta
              color: _unselectedDarkColor,
              height: 1.4, // Asegura que esté alineado con la primera línea
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

/// Widget para los párrafos de política (Información recopilada, Protección de Datos)

class _PolicyParagraph extends StatelessWidget {
  final String text;
  final FontWeight fontWeight;
  final Color color;

  // Parámetro opcional para el texto que debe ir en negrilla
  final String? boldText;

  const _PolicyParagraph({
    required this.text,
    this.fontWeight = FontWeight.normal,
    this.color = _unselectedDarkColor,
    this.boldText, // Nuevo parámetro
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

    // Si se proporciona 'boldText', usamos RichText.
    if (boldText != null && text.contains(boldText!)) {
      // Separamos el texto en tres partes: antes, el texto en negrilla, y después.
      final parts = text.split(boldText!);

      // Estilo para la parte en negrilla
      final boldStyle = baseStyle.copyWith(fontWeight: FontWeight.bold);

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: RichText(
          text: TextSpan(
            children: <TextSpan>[
              TextSpan(
                text: parts.first,
                style: baseStyle,
              ), // Parte 1: Texto normal antes
              TextSpan(
                text: boldText,
                style: boldStyle,
              ), // Parte 2: Texto en negrilla
              // Si hay algo después del texto en negrilla
              if (parts.length > 1)
                TextSpan(
                  text: parts.last,
                  style: baseStyle,
                ), // Parte 3: Texto normal después
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

class PrivacidadScreen extends StatelessWidget {
  const PrivacidadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // CAMBIO: Usamos AppBar en lugar de CustomScrollView con SliverAppBar
        backgroundColor: Colors.white,
        elevation: 0,
        // Propiedades heredadas de UbicacionesScreen:
        centerTitle: false,
        titleSpacing: 0.0,
        // Icono de regreso:
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
            color: _unselectedDarkColor,
          ),
          // Al presionar, vuelve a la pantalla anterior
          onPressed: () => Navigator.of(context).pop(),
        ),
        // Título (estilo adaptado al de UbicacionesScreen, aunque con un título más corto)
        title: const Text(
          "Política de Privacidad",
          maxLines: 2, // Se mantiene por si el título fuera largo
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _unselectedDarkColor,
            fontSize: 20,
            fontFamily: "roboto",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      // CAMBIO: Usamos SingleChildScrollView para el cuerpo en lugar de SliverList
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 10),

              // Introducción (similar a la parte superior de la imagen)
              const _PolicyParagraph(
                text:
                    "En Eco Granel, nos tomamos en serio tu privacidad y protegemos tu información personal con total responsabilidad.",
                fontWeight: FontWeight.normal,
                color: _unselectedDarkColor,
              ),

              // 1. Información Recopilada
              const _SectionTitle(title: "Información Recopilada"),
              const _PolicyParagraph(
                text:
                    "Recopilamos datos personales como nombre, correo electrónico, dirección y detalles de compra únicamente para procesar pedidos y mejorar tu experiencia.",
              ),

              // 2. Uso de la Información
              const _SectionTitle(title: "Uso de la Información"),
              const _PolicyPoint(text: "Procesar y gestionar tus pedidos."),
              const _PolicyPoint(
                text:
                    "Comunicarnos contigo sobre actualizaciones o promociones (solo si das tu consentimiento).",
              ),
              const _PolicyPoint(
                text:
                    "Mejorar nuestros servicios y ofrecerte una mejor experiencia de compra.",
              ),

              // 3. Protección de Datos
              const _SectionTitle(title: "Protección de Datos"),
              const _PolicyParagraph(
                text:
                    "Toda tu información está protegida con medidas de seguridad avanzadas. No vendemos ni compartimos tus datos con terceros, excepto en casos necesarios para procesar pagos y envíos.",
              ),

              // 4. Tus Derechos
              const _SectionTitle(title: "Tus Derechos"),
              // Uso del nuevo parámetro 'boldText' para resaltar el correo electrónico.
              const _PolicyParagraph(
                text:
                    "Puedes solicitar el acceso, modificación o eliminación de tus datos personales en cualquier momento. Escríbenos a soporte@ecogranel.com y estaremos felices de ayudarte.",
                boldText:
                    "soporte@ecogranel.com", // Se indica qué parte va en negrilla
              ),

              // Mensaje final (estilo negrita)
              const _PolicyParagraph(
                text:
                    "Nos preocupamos por tu privacidad porque sabemos que el consumo consciente también incluye la seguridad digital.",
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

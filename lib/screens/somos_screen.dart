import 'package:flutter/material.dart';

// Definimos el color verde primario
const Color _primaryGreen = Color(0xFF4CAF50);
// Definición del color oscuro para títulos y texto principal
const Color _unselectedDarkColor = Color(0xFF424242);

// --- Componentes Reutilizables (Sin Cambios Relevantes) ---

class _MainImage extends StatelessWidget {
  final String imageAsset;
  const _MainImage({required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    // Container con una imagen simulada
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Image.asset(
        imageAsset,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 260.0, // <-- MODIFICACIÓN A 260
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: 260.0, // <-- MODIFICACIÓN A 260
          color: _primaryGreen.withAlpha(50),
          child: const Center(
            child: Icon(Icons.public, size: 50, color: _primaryGreen),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: _primaryGreen,
          fontSize: 16,
          fontFamily: "roboto",
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _HistoryContent extends StatelessWidget {
  const _HistoryContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        Text(
          "Todo empezó con un sueño: hacer del mundo un lugar más consciente,"
          " donde cada acción cuente. Creemos que pequeñas acciones generan"
          " grandes cambios, y por eso decidimos crear un espacio donde encontrar"
          " productos que respeten el planeta y cuiden de nosotros.",
          style: TextStyle(
            fontSize: 14,
            fontFamily: "roboto",
            height: 1.5,
            color: _unselectedDarkColor,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Cada alimento a granel, cada artículo sostenible que ofrecemos,"
          " ha sido elegido con amor y responsabilidad. Queremos ser parte de"
          " una compra diferente, sin desperdicios innecesarios y con la"
          " esperanza de que estés contribuyendo a un futuro más limpio y justo.",
          style: TextStyle(
            fontSize: 14,
            fontFamily: "roboto",
            height: 1.5,
            color: _unselectedDarkColor,
          ),
        ),
      ],
    );
  }
}

class _MissionContent extends StatelessWidget {
  const _MissionContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            'assets/images/somos.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 260,
            errorBuilder: (context, error, stackTrace) => Container(
              width: double.infinity,
              height: 180,
              color: _primaryGreen.withAlpha(50),
              child: const Center(
                child: Icon(Icons.person, size: 50, color: _primaryGreen),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Facilitar el acceso a productos a granel de primera calidad y"
          " asequibles, promoviendo hábitos de consumo responsables que"
          " contribuyan al bienestar de las personas y el cuidado del planeta.",
          style: TextStyle(
            fontSize: 14,
            fontFamily: "roboto",
            height: 1.5,
            color: _unselectedDarkColor,
          ),
        ),
      ],
    );
  }
}

class _ValuesContent extends StatelessWidget {
  const _ValuesContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _ValueItem(
          title: "Sostenibilidad",
          description:
              "Creemos en un modelo de negocio que respeta el medio ambiente,"
              " eliminando los envases plásticos y fomentando el consumo"
              " consciente.",
        ),
        const _ValueItem(
          title: "Calidad y frescura",
          description:
              "Nos comprometemos a seleccionar cuidadosamente cada producto"
              " para garantizar ingredientes naturales, sin aditivos y en su"
              " punto óptimo de frescura.",
        ),
        const _ValueItem(
          title: "Compromiso con la comunidad",
          description:
              "Trabajamos con proveedores responsables y apoyamos la economía"
              " local, fortaleciendo el comercio justo.",
        ),
        const _ValueItem(
          title: "Flexibilidad y ahorro",
          description:
              "Ofrecemos la posibilidad de comprar la cantidad exacta que"
              " se necesita, lo que permite reducir desperdicios y ahorrar"
              " dinero.",
        ),
        const _ValueItem(
          title: "Educación y conciencia",
          description:
              "Queremos inspirar a más personas a adoptar un estilo de vida"
              " más sostenible a través de nuestro blog, talleres y actividades.",
        ),
        const _ValueItem(
          title: "Únete al cambio",
          description:
              "Comprar a granel no es solo una tendencia, es una forma de"
              " contribuir a un futuro mejor para todos.",
        ),
        const SizedBox(height: 10),
        const Text(
          "Te invitamos a formar parte de esta comunidad que elige consumir"
          " con conciencia. Juntos podemos hacer una gran diferencia.",
          style: TextStyle(
            fontSize: 14,
            fontFamily: "roboto",
            height: 1.5,
            color: _unselectedDarkColor,
          ),
        ),
      ],
    );
  }
}

class _ValueItem extends StatelessWidget {
  final String title;
  final String description;
  const _ValueItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: "roboto",
              color: _unselectedDarkColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: "roboto",
              color: _unselectedDarkColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// --- Pantalla Principal (SomosScreen) ---
class SomosScreen extends StatelessWidget {
  const SomosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. AppBar estándar
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
          "Compra consciente, vive sostenible",
          style: TextStyle(
            color: _unselectedDarkColor,
            fontSize: 20,
            fontFamily: "roboto",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // 2. SingleChildScrollView
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contenedor principal para padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 10),

                  // Imagen Principal (Contaminación por Plástico/Océano)
                  const _MainImage(
                    imageAsset: 'assets/images/plasticos-en-mar.jpg',
                  ),
                  const SizedBox(height: 15),

                  // Texto de introducción
                  const Text(
                    "Creemos que cada pequeña elección puede generar un gran"
                    " impacto. Nos especializamos en la venta de alimentos a"
                    " granel, ofreciendo productos frescos y de alta calidad"
                    " sin empaques innecesarios. Nuestro objetivo es brindar"
                    " una alternativa de consumo más sostenible, accesible y"
                    " saludable para todas las personas que desean reducir"
                    " desperdicios y hacer compras responsables.",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "roboto",
                      color: _unselectedDarkColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // DIVISOR MODIFICADO (Ocupa todo el ancho sin padding)
            const Divider(
              color: Color.fromRGBO(224, 224, 224, 100),
              height: 50,
              thickness: 5,
              indent: 0,
              endIndent: 0,
            ),

            // Contenido con el padding horizontal de 22.0
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 2. Nuestra Historia
                  const _SectionHeader(title: "Nuestra Historia"),
                  const _HistoryContent(),
                ],
              ),
            ),

            // DIVISOR MODIFICADO (Ocupa todo el ancho sin padding)
            const Divider(
              color: Color.fromRGBO(224, 224, 224, 100),
              height: 50,
              thickness: 5,
              indent: 0,
              endIndent: 0,
            ),

            // Contenido con el padding horizontal de 22.0
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 3. Nuestra Misión
                  const _SectionHeader(title: "Nuestra Misión"),
                  const _MissionContent(),
                ],
              ),
            ),

            // DIVISOR MODIFICADO (Ocupa todo el ancho sin padding)
            const Divider(
              color: Color.fromRGBO(224, 224, 224, 100),
              height: 50,
              thickness: 5,
              indent: 0,
              endIndent: 0,
            ),

            // Contenido con el padding horizontal de 22.0
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 4. Nuestros Valores
                  const _SectionHeader(title: "Nuestros Valores"),
                  const _ValuesContent(),

                  // Separador y Texto Final
                  const SizedBox(height: 20),
                  const Text(
                    "¡Gracias por ser parte de este movimiento sostenible!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _primaryGreen,
                      fontSize: 16,
                      fontFamily: "roboto",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 30), // Espacio final aumentado
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

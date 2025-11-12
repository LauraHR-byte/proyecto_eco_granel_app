import 'package:flutter/material.dart';

// Definimos el color verde primario para el tema
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);

// --- Componente de la Tarjeta de Receta (RecetaCard) ---
class RecetaCard extends StatelessWidget {
  final String title;
  final String description;
  final String
  imageUrl; // Ahora apunta a una ruta local (e.g., assets/images/nombre.jpg)

  const RecetaCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    // Usamos InkWell para que la tarjeta sea clickeable e incluya el ícono de flecha
    return InkWell(
      onTap: () {
        // Lógica de navegación o acción al hacer clic en la tarjeta
        debugPrint('Receta seleccionada: $title');
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
          elevation: 2, // Sombra suave para destacar la tarjeta
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Contenedor de la Imagen
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    // Uso de Image.asset para cargar desde ruta local
                    image: DecorationImage(
                      image: AssetImage(imageUrl), // Usamos AssetImage
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Contenido de Texto
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        title,
                        style: const TextStyle(
                          fontFamily: "roboto",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      // Línea de separación verde debajo del título
                      const SizedBox(height: 2),
                      Container(height: 2, width: 100, color: _primaryGreen),
                      const SizedBox(height: 8),
                      Text(
                        description,
                        style: TextStyle(
                          fontFamily: "roboto",
                          fontSize: 12,
                          color: _unselectedDarkColor,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                // Icono Arrow Forward iOS a la derecha
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    color: _primaryGreen,
                    size: 24,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// --- Componente Principal de Recetas con Pestañas ---
class Recetas extends StatelessWidget {
  const Recetas({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      // Número de pestañas: Desayunos, Snacks y Favoritos
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          // Cambios para alinear a la izquierda y hacer bold el título
          title: const Text(
            "Recetas",
            style: TextStyle(
              fontFamily: "roboto",
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: _unselectedDarkColor,
            ),
          ),
          // Se quita centerTitle: true para alinearlo a la izquierda
          centerTitle: false,
          elevation: 0,
          bottom: const TabBar(
            labelColor: _primaryGreen,
            unselectedLabelColor: Colors.grey,
            indicatorColor: _primaryGreen,
            indicatorWeight: 3.0,
            tabs: [
              Tab(
                child: Text(
                  "Desayunos",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "roboto",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Tab(
                child: Text(
                  "Snacks",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "roboto",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              // Pestaña de Favoritos
              Tab(
                child: Text(
                  "Favoritos",
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: "roboto",
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        // _FavoritosTab al TabBarView
        body: const TabBarView(
          children: [_DesayunosTab(), _SnacksTab(), _FavoritosTab()],
        ),
      ),
    );
  }
}

// --- Contenido de la Pestaña DESAYUNOS ---
class _DesayunosTab extends StatelessWidget {
  const _DesayunosTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const <Widget>[
        // Uso de rutas de assets locales
        RecetaCard(
          title: "Granola Casera",
          description:
              "Preparar tu propia granola en casa es una excelente manera de disfrutar un desayuno saludable y libre de aditivos.",
          imageUrl: "assets/images/granola.jpg",
        ),
        RecetaCard(
          title: "Pudding de Chía y Cúrcuma",
          description:
              "Este pudding es una opción nutritiva y fácil de preparar, cargada de antioxidantes y grasas saludables.",
          imageUrl: "assets/images/pudin.jpg",
        ),
        RecetaCard(
          title: "Avena Cremosa con Frutas y Semillas",
          description:
              "Comienza tu día con un desayuno nutritivo y equilibrado.",
          imageUrl: "assets/images/avena-cremosa.jpg",
        ),
      ],
    );
  }
}

// --- Contenido de la Pestaña SNACKS ---
class _SnacksTab extends StatelessWidget {
  const _SnacksTab();

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: const <Widget>[
        // Uso de rutas de assets locales
        RecetaCard(
          title: "Galletas de Avena y Almendras",
          description:
              "Una opción saludable, crujiente y deliciosa, perfecta para acompañar con café o té.",
          imageUrl: "assets/images/galletas.jpg",
        ),
        RecetaCard(
          title: "Barritas Energéticas de Cacao y Nueces",
          description:
              "Si buscas un snack natural y delicioso para recargar energías, estas barritas caseras son la opción ideal.",
          imageUrl: "assets/images/barritas.jpg",
        ),
        RecetaCard(
          title: "Chips Crujientes de Garbanzo con Especias",
          description:
              "Disfruta de un snack crujiente, sabroso y lleno de proteína vegetal.",
          imageUrl: "assets/images/chips-garbanzos.jpg",
        ),
      ],
    );
  }
}

// --- Contenido de la Pestaña FAVORITOS ---
class _FavoritosTab extends StatelessWidget {
  const _FavoritosTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite, color: _primaryGreen, size: 40),
          SizedBox(height: 10),
          Text(
            "¡Aún no tienes recetas favoritas!",
            style: TextStyle(
              fontSize: 18,
              fontFamily: "roboto",
              color: Colors.grey,
            ),
          ),
          Text(
            "Marca el corazón ❤️ para guardarlas aquí.",
            style: TextStyle(
              fontSize: 14,
              fontFamily: "roboto",
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}

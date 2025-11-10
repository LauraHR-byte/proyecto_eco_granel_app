import 'package:flutter/material.dart';

// Definimos el color verde primario para el tema
const Color _primaryGreen = Color(0xFF4CAF50);

// --- Componente de la Tarjeta de Receta (RecetaCard) ---
class RecetaCard extends StatelessWidget {
  final String title;
  final String description;
  final String imageUrl;

  const RecetaCard({
    super.key,
    required this.title,
    required this.description,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
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
                    // Uso de Image.network para cargar desde un URL
                    image: DecorationImage(
                      image: NetworkImage(imageUrl),
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
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontFamily: "roboto",
                          fontSize: 12,
                          color: Colors.grey[800],
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      // Línea de separación verde
                      Container(height: 3, width: 100, color: _primaryGreen),
                    ],
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
              color: Color(0xFF333333),
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
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              Tab(
                child: Text(
                  "Snacks",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              // Pestaña de Favoritos
              Tab(
                child: Text(
                  "Favoritos",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
        RecetaCard(
          title: "Granola Casera",
          description:
              "Preparar tu propia granola en casa es una excelente manera de disfrutar un desayuno saludable y libre de aditivos.",
          // Ejemplo de URL real de imagen
          imageUrl:
              "https://www.pexels.com/es-es/foto/mujer-con-camisa-azul-sosteniendo-un-vaso-transparente-7772026/",
        ),
        RecetaCard(
          title: "Pudding de Chía y Cúrcuma",
          description:
              "Este pudding es una opción nutritiva y fácil de preparar, cargada de antioxidantes y grasas saludables.",
          imageUrl:
              "https://www.pexels.com/es-es/foto/mujer-con-camisa-azul-sosteniendo-un-vaso-transparente-7772026/",
        ),
        RecetaCard(
          title: "Avena Cremosa con Frutas y Semillas",
          description:
              "Comienza tu día con un desayuno nutritivo y equilibrado.",
          imageUrl:
              "https://www.pexels.com/es-es/foto/mujer-con-camisa-azul-sosteniendo-un-vaso-transparente-7772026/",
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
        RecetaCard(
          title: "Galletas de Avena y Almendras",
          description:
              "Una opción saludable, crujiente y deliciosa, perfecta para acompañar con café o té.",
          imageUrl:
              "https://www.pexels.com/es-es/foto/mujer-con-camisa-azul-sosteniendo-un-vaso-transparente-7772026/",
        ),
        RecetaCard(
          title: "Barritas Energéticas de Cacao y Nueces",
          description:
              "Si buscas un snack natural y delicioso para recargar energías, estas barritas caseras son la opción ideal.",
          imageUrl:
              "https://www.pexels.com/es-es/foto/mujer-con-camisa-azul-sosteniendo-un-vaso-transparente-7772026/",
        ),
        RecetaCard(
          title: "Chips Crujientes de Garbanzo con Especias",
          description:
              "Disfruta de un snack crujiente, sabroso y lleno de proteína vegetal.",
          imageUrl:
              "https://www.pexels.com/es-es/foto/mujer-con-camisa-azul-sosteniendo-un-vaso-transparente-7772026/",
        ),
      ],
    );
  }
}

// --- Contenido de la Pestaña FAVORITOS (Nueva) ---
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
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          Text(
            "Marca el corazón ❤️ para guardarlas aquí.",
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

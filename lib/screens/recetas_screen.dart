import 'package:flutter/material.dart';
// 1. Importaciones necesarias para Firebase (Firestore)
import 'package:cloud_firestore/cloud_firestore.dart';

// 2. Definimos el color verde primario para el tema
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);

// --- 3. Modelo de Datos para Recetas (Receta) ---
// Este modelo nos ayuda a mapear los documentos de Firestore a objetos Dart.
class Receta {
  final String id; // ID del documento en Firestore
  final String title;
  final String description;
  final String imageUrl; // URL de la imagen (de Firebase Storage o externa)
  final String category; // Para filtrar (e.g., 'desayunos', 'snacks')

  Receta({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.category,
  });

  // Constructor factory para crear una instancia desde un DocumentSnapshot de Firestore
  factory Receta.fromFirestore(DocumentSnapshot doc) {
    // Es mejor asegurar que el tipo de datos sea Map<String, dynamic>
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Receta(
      id: doc.id,
      title: data['title'] ?? 'Sin título',
      description: data['description'] ?? 'Sin descripción',
      imageUrl:
          data['imageUrl'] ??
          'assets/images/placeholder.jpg', // Usar URL real o de almacenamiento
      category: data['category'] ?? 'otros',
    );
  }
}

// ==========================================================
// ⭐️ PASO 1: Nueva Pantalla de Detalle de Receta
// ==========================================================
class RecipeDetailScreen extends StatelessWidget {
  // Recibe el objeto Receta completo para mostrar sus detalles
  final Receta receta;

  const RecipeDetailScreen({super.key, required this.receta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(receta.title), backgroundColor: _primaryGreen),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Imagen de la receta
            Image.network(
              receta.imageUrl,
              height: 250,
              width: double.infinity,
              fit: BoxFit.cover,
              // Opcional: placeholder para cuando la imagen esté cargando
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 250,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      color: _primaryGreen,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    receta.title,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: _unselectedDarkColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Categoría: ${receta.category.toUpperCase()}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: _primaryGreen,
                    ),
                  ),
                  const Divider(height: 32, thickness: 1),
                  const Text(
                    "Descripción:",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: _unselectedDarkColor,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    receta.description,
                    style: const TextStyle(
                      fontSize: 16,
                      color: _unselectedDarkColor,
                    ),
                  ),
                  // Aquí añadirías más detalles como ingredientes, pasos, etc.
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      "⭐ ¡Lógica de Ingredientes y Pasos va aquí! ⭐",
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.grey,
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
}

// --- 4. Componente de la Tarjeta de Receta (RecetaCard) ---
// Ahora acepta el ID de la receta y la URL de la imagen es remota.
class RecetaCard extends StatelessWidget {
  final Receta receta; // Usamos el objeto Receta completo
  // Aquí podrías agregar un callback para manejar el estado de favorito

  const RecetaCard({super.key, required this.receta});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      // ==========================================================
      // ⭐️ PASO 2: Lógica de Navegación Añadida
      // ==========================================================
      onTap: () {
        debugPrint('Navegando a detalle de: ${receta.title}');
        // Navega a la nueva pantalla (RecipeDetailScreen)
        Navigator.push(
          context,
          MaterialPageRoute(
            // Le pasamos el objeto 'receta' completo a la pantalla de detalle
            builder: (context) => RecipeDetailScreen(receta: receta),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Card(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Contenedor de la Imagen: Ahora carga desde una URL (NetworkImage)
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      // Usamos NetworkImage si la URL es de Firebase Storage o externa
                      image: NetworkImage(receta.imageUrl),
                      // O podrías usar Image.network
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
                        receta.title,
                        style: const TextStyle(
                          fontFamily: "roboto",
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Container(height: 2, width: 100, color: _primaryGreen),
                      const SizedBox(height: 8),
                      Text(
                        receta.description,
                        style: const TextStyle(
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

// --- 5. Componente Principal de Recetas con Pestañas (Se mantiene igual) ---
class Recetas extends StatelessWidget {
  const Recetas({super.key});

  @override
  Widget build(BuildContext context) {
    // Es CRUCIAL que Firebase esté inicializado antes de este punto.
    // Generalmente se hace en main() o en el widget padre de la aplicación.
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          titleSpacing: 20.0,
          toolbarHeight: 61.0,
          title: const Text(
            "Recetas",
            style: TextStyle(
              fontFamily: "roboto",
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: _unselectedDarkColor,
            ),
          ),
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
        // Las vistas de las pestañas ahora cargan datos de Firestore
        body: const TabBarView(
          children: [
            _RecetasListTab(category: 'desayunos'),
            _RecetasListTab(category: 'snacks'),
            _FavoritosTab(),
          ],
        ),
      ),
    );
  }
}

// --- 6. Componente Reutilizable para Pestañas con Carga de Firestore ---
// Reemplaza _DesayunosTab y _SnacksTab con este widget dinámico.
class _RecetasListTab extends StatelessWidget {
  final String category; // 'desayunos' o 'snacks'

  const _RecetasListTab({required this.category});

  // Referencia a la colección de Firestore
  static final CollectionReference _recetasCollection = FirebaseFirestore
      .instance
      .collection('recetas');

  @override
  Widget build(BuildContext context) {
    // StreamBuilder escucha los cambios en tiempo real en la base de datos
    return StreamBuilder<QuerySnapshot>(
      // Consulta a Firestore: obtenemos documentos donde 'category' es igual al valor de la pestaña
      stream: _recetasCollection
          .where('category', isEqualTo: category)
          .snapshots(),

      builder: (context, snapshot) {
        // Estado de error
        if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar las recetas: ${snapshot.error}'),
          );
        }

        // Estado de carga (conexión esperando)
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _primaryGreen),
          );
        }

        // Estado de datos: mapeamos los documentos a una lista de objetos Receta
        final List<Receta> recetas = snapshot.data!.docs
            .map(
              // El casteo es necesario para evitar errores de tipo en tiempo de ejecución
              (doc) => Receta.fromFirestore(doc as DocumentSnapshot<Object?>),
            )
            .toList();

        // Si no hay recetas
        if (recetas.isEmpty) {
          return Center(
            child: Text('No hay recetas en la categoría de $category.'),
          );
        }

        // Mostrar la lista de recetas
        return ListView.builder(
          itemCount: recetas.length,
          itemBuilder: (context, index) {
            return RecetaCard(receta: recetas[index]);
          },
        );
      },
    );
  }
}

// --- Contenido de la Pestaña FAVORITOS (Se mantiene igual, la lógica de favoritos necesitaría autenticación/estado local) ---
class _FavoritosTab extends StatelessWidget {
  const _FavoritosTab();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.star, color: _primaryGreen, size: 40),
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
            "Marca la estrella ⭐ para guardarlas aquí.",
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

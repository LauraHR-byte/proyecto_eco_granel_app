import 'package:flutter/material.dart';
// 1. Importaciones necesarias para Firebase (Firestore y Auth)
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart'; // ✅ ¡Añadido!
import 'package:eco_granel_app/screens/recipe_detail_screen.dart';

// 2. Definimos el color verde primario para el tema
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);

// --- 3. Modelo de Datos para Recetas (Receta) ---
// NOTA: El constructor 'fromFirestore' se actualiza para funcionar tanto con la
// colección 'recetas' (que tiene 'category') como con la subcolección 'favorites'
// (que solo tiene los campos guardados: title, imageUrl, description).
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

    // **Ajuste clave:** 'recipeId' es el ID de la receta en la subcolección 'favorites'
    final recipeId = data['recipeId'] ?? doc.id;

    return Receta(
      id: recipeId,
      title: data['title'] ?? 'Sin título',
      description: data['description'] ?? 'Sin descripción',
      imageUrl: data['imageUrl'] ?? 'assets/images/placeholder.jpg',
      // En la pestaña Favoritos, el campo 'category' no existe, así que usamos un valor por defecto.
      category: data['category'] ?? 'Favorito',
    );
  }
}

// --- 4. Componente de la Tarjeta de Receta (RecetaCard) ---
class RecetaCard extends StatelessWidget {
  final Receta receta; // Usamos el objeto Receta completo

  const RecetaCard({super.key, required this.receta});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        debugPrint('Acción de tarjeta de receta: ${receta.title}');
        Navigator.push(
          context,
          MaterialPageRoute(
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
                // Contenedor de la Imagen: Carga desde una URL
                Container(
                  height: 100,
                  width: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    image: DecorationImage(
                      image: NetworkImage(receta.imageUrl),
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
            _FavoritosTab(), // <-- Lógica de usuario aquí
          ],
        ),
      ),
    );
  }
}

// --- 6. Componente Reutilizable para Pestañas con Carga de Firestore ---
class _RecetasListTab extends StatelessWidget {
  final String category; // 'desayunos' o 'snacks'

  const _RecetasListTab({required this.category});

  static final CollectionReference _recetasCollection = FirebaseFirestore
      .instance
      .collection('recetas');

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _recetasCollection
          .where('category', isEqualTo: category)
          .snapshots(),

      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar las recetas: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _primaryGreen),
          );
        }

        final List<Receta> recetas = snapshot.data!.docs
            .map(
              (doc) => Receta.fromFirestore(doc as DocumentSnapshot<Object?>),
            )
            .toList();

        if (recetas.isEmpty) {
          return Center(
            child: Text('No hay recetas en la categoría de $category.'),
          );
        }

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

// ----------------------------------------------------------------------
// 7. Componente de la Pestaña FAVORITOS (CORREGIDO para usar el userId)
// ----------------------------------------------------------------------
class _FavoritosTab extends StatefulWidget {
  const _FavoritosTab();

  @override
  State<_FavoritosTab> createState() => __FavoritosTabState();
}

class __FavoritosTabState extends State<_FavoritosTab> {
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    // 🌟 Suscribirse a los cambios de autenticación
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
    // Obtener el estado inicial del usuario
    _currentUser = FirebaseAuth.instance.currentUser;
  }

  // 🛠️ Función que devuelve la consulta a Firestore
  Stream<QuerySnapshot>? _getFavoritesStream() {
    // Si no hay usuario autenticado, no hay stream que devolver.
    if (_currentUser == null) {
      return null;
    }

    final userId = _currentUser!.uid;

    // 🎯 Consulta correcta: userFavorites/{userId}/favorites
    return FirebaseFirestore.instance
        .collection('userFavorites')
        .doc(userId)
        .collection('favorites') // Subcolección específica
        .orderBy(
          'timestamp',
          descending: true,
        ) // Ordenamos por el timestamp de guardado
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    // Si no hay usuario, mostramos un mensaje pidiendo iniciar sesión
    if (_currentUser == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.lock, color: _unselectedDarkColor, size: 40),
            SizedBox(height: 10),
            Text(
              "Inicia Sesión para ver tus Favoritos",
              style: TextStyle(
                fontSize: 18,
                fontFamily: "roboto",
                color: _unselectedDarkColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 5),
            Text(
              "Una vez iniciada la sesión, aparecerán aquí.",
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

    // 🚀 Si hay usuario, construimos el StreamBuilder
    return StreamBuilder<QuerySnapshot>(
      stream: _getFavoritesStream(),
      builder: (context, snapshot) {
        // Estado de error
        if (snapshot.hasError) {
          return Center(
            child: Text('Error al cargar favoritos: ${snapshot.error}'),
          );
        }

        // Estado de carga
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _primaryGreen),
          );
        }

        // Mapeamos los documentos de la subcolección 'favorites' a Receta
        final List<Receta> recetasFavoritas = snapshot.data!.docs
            .map(
              // Usamos el constructor, el cual mapeará los campos guardados
              (doc) => Receta.fromFirestore(doc as DocumentSnapshot<Object?>),
            )
            .toList();

        // Si no hay recetas favoritas
        if (recetasFavoritas.isEmpty) {
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
                  "Marca la estrella ⭐ en cualquier receta para guardarla aquí.",
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

        // Mostrar la lista de recetas favoritas
        return ListView.builder(
          itemCount: recetasFavoritas.length,
          itemBuilder: (context, index) {
            return RecetaCard(receta: recetasFavoritas[index]);
          },
        );
      },
    );
  }
}

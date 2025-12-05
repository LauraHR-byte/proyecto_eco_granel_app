import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eco_granel_app/screens/recetas_screen.dart';

// Tus colores globales
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);

// Recibe: objeto Receta (id, title, description, imageUrl, category)

// CONVERTIMOS A STATEFULWIDGET
class RecipeDetailScreen extends StatefulWidget {
  final Receta receta;

  const RecipeDetailScreen({super.key, required this.receta});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  // Estado inicial de favorito.
  bool _isFavorite = false;

  // Función auxiliar para construir los ítems de info (tiempo, temperatura)
  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 30),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            fontFamily: "roboto",
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontFamily: "roboto",
            color: _unselectedDarkColor,
          ),
        ),
      ],
    );
  }

  // Widget para la sección de favoritos (interactivo)
  Widget _buildFavoritesSection() {
    return GestureDetector(
      onTap: () {
        // Lógica de toggle para favoritos
        setState(() {
          _isFavorite = !_isFavorite;
        });
        // Aquí iría la lógica para guardar/eliminar en Firestore
        final message = _isFavorite
            ? 'Receta agregada a Favoritos'
            : 'Receta eliminada de Favoritos';
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(message)));
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isFavorite ? Icons.star : Icons.star_border,
            color: _isFavorite ? _primaryGreen : _unselectedDarkColor,
            size: 24,
          ),
          const SizedBox(width: 8),
          Text(
            "Favoritos",
            style: TextStyle(
              fontSize: 18,
              fontFamily: "roboto",
              color: _unselectedDarkColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // Widget para el botón de comentarios
  Widget _buildCommentButton() {
    return GestureDetector(
      onTap: () {
        // Lógica para abrir la sección de comentarios o un modal
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Abrir sección de Comentarios')),
        );
      },
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            color: _unselectedDarkColor,
            size: 24,
          ),
          SizedBox(width: 8),
          Text(
            "Comentar",
            style: TextStyle(
              fontSize: 18,
              fontFamily: "roboto",
              color: _unselectedDarkColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: _primaryGreen,
        title: Text(
          widget.receta.title,
          style: const TextStyle(
            fontFamily: "roboto",
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ---------------- CUERPO ----------------
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('recetas')
            .doc(widget.receta.id)
            .get(),

        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _primaryGreen),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text("Error al cargar los datos: ${snapshot.error}"),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text("Receta no encontrada."));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;

          // =====================================================
          // 🛠️ EXTRACCIÓN DE DATOS ADICIONALES
          // =====================================================
          final String prepTime =
              data['prepTime'] ?? 'N/A'; // Tiempo de preparación
          final String ovenTemp =
              data['ovenTemp'] ?? 'N/A'; // Temperatura del horno

          // ARRAYS DESDE FIRESTORE
          final List ingredients = data['ingredients'] ?? [];
          final List steps = data['preparation'] ?? [];

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =====================================================
                // 🖼️ IMAGEN PRINCIPAL (Ajuste de Border Radius y centrado)
                // =====================================================
                Center(
                  // Centra el contenedor de la imagen
                  child: Padding(
                    padding: const EdgeInsets.all(
                      12.0,
                    ), // Agrega un poco de margen
                    child: ClipRRect(
                      // Aplica el Border Radius
                      borderRadius: BorderRadius.circular(12.0),
                      child: Image.network(
                        widget.receta.imageUrl,
                        height: 260,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, progress) {
                          if (progress == null) return child;
                          return Container(
                            height: 260,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(
                                color: _primaryGreen,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),

                // =====================================================
                // 📌 CONTENIDO DETALLADO
                // =====================================================
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // --------------------------------------------------
                      // TÍTULO, CATEGORÍA E INTERACCIONES
                      // --------------------------------------------------
                      Text(
                        widget.receta.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: "roboto",
                          color: _unselectedDarkColor,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Categoría: ${widget.receta.category.toUpperCase()}",
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: "roboto",
                          fontWeight: FontWeight.w600,
                          color: _primaryGreen,
                        ),
                      ),

                      const SizedBox(height: 16),

                      // --------------------------------------------------
                      // 🌟 BOTONES DE FAVORITOS Y COMENTARIOS
                      // --------------------------------------------------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          _buildFavoritesSection(),
                          const SizedBox(width: 30),
                          _buildCommentButton(),
                        ],
                      ),

                      const SizedBox(height: 16),
                      const Divider(),

                      // ==================================================
                      // ⏱️ INFORMACIÓN ADICIONAL (TIEMPO Y TEMPERATURA)
                      // ==================================================
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildInfoItem(
                            Icons.timer_sharp,
                            "PREPARACIÓN",
                            prepTime, // Usando el dato de Firestore
                            _primaryGreen,
                          ),
                          _buildInfoItem(
                            Icons.local_fire_department_sharp,
                            "TEMPERATURA",
                            ovenTemp, // Usando el dato de Firestore
                            Colors.orange.shade700,
                          ),
                        ],
                      ),
                      const Divider(),
                      const SizedBox(height: 16),

                      // --------------------------------------------------
                      // DESCRIPCIÓN
                      // --------------------------------------------------
                      const Text(
                        "Descripción:",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: "roboto",
                          color: _unselectedDarkColor,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        widget.receta.description,
                        style: const TextStyle(
                          fontSize: 16,
                          fontFamily: "roboto",
                          color: _unselectedDarkColor,
                        ),
                      ),

                      // --------------------------------------------------
                      // INGREDIENTES
                      // --------------------------------------------------
                      const SizedBox(height: 30),
                      const Text(
                        "Ingredientes:",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: "roboto",
                          color: _unselectedDarkColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // 👇 CONTENIDO DE INGREDIENTES RESTAURADO (Línea 326)
                      ...ingredients.map(
                        (item) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: _primaryGreen,
                                size: 20,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  item,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.4,
                                    fontFamily: "roboto",
                                    color: _unselectedDarkColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // --------------------------------------------------
                      // PASOS
                      // --------------------------------------------------
                      const SizedBox(height: 35),
                      const Text(
                        "Preparación:",
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          fontFamily: "roboto",
                          color: _unselectedDarkColor,
                        ),
                      ),
                      const SizedBox(height: 15),
                      // 👇 CONTENIDO DE PASOS RESTAURADO (Línea 342)
                      ...steps.asMap().entries.map((entry) {
                        int index = entry.key;
                        String step = entry.value;

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                radius: 15,
                                backgroundColor: _primaryGreen,
                                child: Text(
                                  "${index + 1}",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontFamily: "roboto",
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  step,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    height: 1.4,
                                    fontFamily: "roboto",
                                    color: _unselectedDarkColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eco_granel_app/screens/recetas_screen.dart';

// Tus colores globales
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);
const Color _lightGrey = Color(0xFFE0E0E0);
const Color _orangeColor = Color(0xFFC76939);

// La clase Receta debe estar definida en 'recetas_screen.dart'

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

  // Controlador para el campo de texto del nuevo comentario
  final TextEditingController _commentController = TextEditingController();

  User? _currentUser; // Se mantiene, ya que se usa en _showCommentModal

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  // Función para obtener el usuario actual y escuchar cambios
  void _checkCurrentUser() {
    // Escucha los cambios de autenticación.
    FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (mounted) {
        setState(() {
          _currentUser = user;
        });
      }
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  // 🛠️ FUNCIÓN DE WIDGET AJUSTADA: Usa Chip para apariencia de botón
  Widget _buildInfoItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    final isValid = value.isNotEmpty && value != 'N/A';

    if (!isValid) {
      return const SizedBox.shrink();
    }

    // ⭐ Retorna un Chip para darle una apariencia de botón
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        backgroundColor: color.withAlpha(38), // Fondo suave
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: BorderSide(color: color.withAlpha(128)),
        ),
        labelPadding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        label: Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            fontFamily: "roboto",
            color: color, // Color del texto igual al ícono
          ),
        ),
        avatar: Icon(icon, color: color, size: 20),
      ),
    );
  }

  // Widget para la sección de favoritos (interactivo)
  Widget _buildFavoritesSection() {
    return GestureDetector(
      onTap: () {
        setState(() {
          _isFavorite = !_isFavorite;
        });
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
          const Text(
            "Favoritos",
            style: TextStyle(
              fontSize: 16,
              fontFamily: "roboto",
              color: _unselectedDarkColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // 🆕 FUNCIÓN para mostrar el modal de comentarios (Ajustado)
  void _showCommentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            height: MediaQuery.of(context).size.height * 0.85,
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado del Modal
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Comentarios de la Receta",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: "roboto",
                        color: _unselectedDarkColor,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () =>
                          Navigator.pop(context), // Cierra el modal
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 10),

                // Lista de Comentarios
                Expanded(
                  child: SingleChildScrollView(child: _buildCommentsList()),
                ),

                const SizedBox(height: 20),

                // ---------------------------------------------
                // 🌟 FORMULARIO FIJO EN LA PARTE INFERIOR
                // ---------------------------------------------
                // Aquí se utiliza _currentUser para decidir qué mostrar
                if (_currentUser != null)
                  _buildCommentForm()
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Debes iniciar sesión para poder dejar un comentario.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.red.shade700,
                        fontStyle: FontStyle.italic,
                        fontFamily: 'roboto',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget para el botón de comentarios (sin cambios)
  Widget _buildCommentButton() {
    return GestureDetector(
      onTap: _showCommentModal,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.comment, color: _unselectedDarkColor, size: 20),
          SizedBox(width: 8),
          Text(
            "Comentar",
            style: TextStyle(
              fontSize: 16,
              fontFamily: "roboto",
              color: _unselectedDarkColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // WIDGET AUXILIAR PARA EL FORMULARIO DE COMENTARIOS (sin cambios)
  Widget _buildCommentForm() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: "Escribe tu comentario...",
              fillColor: _lightGrey.withAlpha(128),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10.0),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 10,
              ),
            ),
            maxLines: null,
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          height: 50,
          child: ElevatedButton(
            onPressed: _submitComment,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10),
            ),
            child: const Icon(Icons.send),
          ),
        ),
      ],
    );
  }

  // WIDGET AUXILIAR para la Lista de Comentarios (sin cambios)
  Widget _buildCommentsList() {
    // ... (código para construir la lista de comentarios)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('recetas')
              .doc(widget.receta.id)
              .collection('comments')
              .orderBy('timestamp', descending: true)
              .limit(10)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: _primaryGreen),
              );
            }

            if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0),
                child: Center(
                  child: Text("Sé el primero en comentar esta receta."),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final commentData =
                    snapshot.data!.docs[index].data() as Map<String, dynamic>;
                final commentText = commentData['text'] ?? 'Comentario vacío';
                final userName = commentData['userName'] ?? 'Usuario Anónimo';
                final timestamp = commentData['timestamp'] as Timestamp?;
                final date = timestamp != null
                    ? ' - ${DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch).toLocal().toString().split(' ')[0]}'
                    : '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$userName$date',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: _primaryGreen,
                        fontFamily: 'roboto',
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8.0, bottom: 10.0),
                      child: Text(
                        commentText,
                        style: const TextStyle(
                          fontSize: 16,
                          color: _unselectedDarkColor,
                          fontFamily: 'roboto',
                        ),
                      ),
                    ),
                    const Divider(height: 1, color: _lightGrey),
                    const SizedBox(height: 10),
                  ],
                );
              },
            );
          },
        ),
      ],
    );
  }

  // LÓGICA PARA ENVIAR EL COMENTARIO (sin cambios)
  void _submitComment() async {
    if (_currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Debes iniciar sesión para comentar.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final commentText = _commentController.text.trim();

    if (commentText.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El comentario no puede estar vacío.')),
      );
      return;
    }

    final currentUserId = _currentUser!.uid;
    final currentUserName =
        _currentUser!.displayName ??
        _currentUser!.email?.split('@')[0] ??
        "Usuario Registrado";

    try {
      await FirebaseFirestore.instance
          .collection('recetas')
          .doc(widget.receta.id)
          .collection('comments')
          .add({
            'userId': currentUserId,
            'userName': currentUserName,
            'text': commentText,
            'timestamp': FieldValue.serverTimestamp(),
          });

      if (!mounted) return;
      _commentController.clear();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al enviar el comentario: $e')),
      );
    }
  }

  // Función auxiliar para capitalizar la primera letra de cada palabra (sin cambios)
  String _capitalizeWords(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        })
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ---------------- APP BAR (AJUSTADO) ----------------
      appBar: AppBar(
        // 1. Color del AppBar: Blanco
        backgroundColor: Colors.white,
        // 2. Título adaptable al tamaño
        title: FittedBox(
          child: Text(
            widget.receta.title,
            style: const TextStyle(
              fontFamily: "roboto",
              fontWeight: FontWeight.w600,
              // Color del texto ajustado para ser visible en blanco
              color: _unselectedDarkColor,
            ),
          ),
        ),
        // Iconos de la AppBar: ajustados para ser visibles en blanco
        iconTheme: const IconThemeData(color: _unselectedDarkColor, size: 30),
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

          final String prepTime =
              (data['prepTime'] as String?)?.trim() ?? 'N/A';
          final String ovenTemp =
              (data['ovenTemp'] as String?)?.trim() ?? 'N/A';

          final String closingText =
              (data['closingText'] as String?)?.trim() ??
              '¡Gracias por probar esta receta!';

          final List ingredients = data['ingredients'] ?? [];
          final List steps = data['preparation'] ?? [];

          final hasPrepTime = prepTime.isNotEmpty && prepTime != 'N/A';
          final hasOvenTemp = ovenTemp.isNotEmpty && ovenTemp != 'N/A';
          final bool shouldShowInfoSection = hasPrepTime || hasOvenTemp;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🖼️ IMAGEN PRINCIPAL
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18.0,
                      vertical: 18.0,
                    ),
                    child: ClipRRect(
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

                // 📌 CONTENIDO DETALLADO
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TÍTULO DEBAJO DE LA IMAGEN (AJUSTADO: Fondo Blanco, Texto oscuro, alineado a la izquierda)
                    Container(
                      // ⭐ CAMBIO CLAVE: Fondo blanco
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 20.0,
                      ), // Padding horizontal
                      width: double
                          .infinity, // Asegura que ocupe todo el ancho disponible
                      child: Text(
                        widget.receta.title,
                        // ⭐ AJUSTE: Eliminado 'textAlign: TextAlign.center'
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: "roboto",
                          // ⭐ CAMBIO CLAVE: Color del texto a oscuro para contraste
                          color: _unselectedDarkColor,
                        ),
                      ),
                    ),
                    // Usamos Padding para el resto del contenido y alinearlo con el contenedor
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 10,
                          ), // Separación después del título
                          // CATEGORÍA (sin cambios)
                          Text(
                            "Categoría: ${_capitalizeWords(widget.receta.category)}",
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: "roboto",
                              fontWeight: FontWeight.w600,
                              color: _primaryGreen,
                            ),
                          ),

                          const SizedBox(height: 16),

                          // --------------------------------------------------
                          // TIEMPO Y TEMPERATURA (Ahora como Chips)
                          // --------------------------------------------------
                          if (shouldShowInfoSection) ...[
                            const SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                _buildInfoItem(
                                  Icons.timer_sharp,
                                  "Tiempo",
                                  prepTime,
                                  _primaryGreen,
                                ),
                                _buildInfoItem(
                                  Icons.device_thermostat,
                                  "Temperatura",
                                  ovenTemp,
                                  Colors.orange.shade700,
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                          ],

                          // --------------------------------------------------
                          // DESCRIPCIÓN - TÍTULO
                          const Padding(
                            padding: EdgeInsets.only(top: 20.0),
                            child: Text(
                              "Descripción:",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                fontFamily: "roboto",
                                color: _unselectedDarkColor,
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          // DESCRIPCIÓN - CONTENIDO
                          Text(
                            widget.receta.description,
                            style: const TextStyle(
                              fontSize: 16,
                              fontFamily: "roboto",
                              color: _unselectedDarkColor,
                            ),
                          ),

                          // INGREDIENTES
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
                          // 🌟 USO DE 'ingredients'
                          ...ingredients.map(
                            (item) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(top: 8),
                                    width: 6.0,
                                    height: 6.0,
                                    decoration: const BoxDecoration(
                                      color: _primaryGreen,
                                      shape: BoxShape.circle,
                                    ),
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

                          // PASOS (PREPARACIÓN)
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

                          // PASOS DE PREPARACIÓN
                          // 🌟 USO de 'steps'
                          ...steps.asMap().entries.map((entry) {
                            int index = entry.key;
                            String step = entry.value;

                            return Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 30,
                                    child: Text(
                                      "${index + 1}.",
                                      style: const TextStyle(
                                        color: _primaryGreen,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        fontFamily: "roboto",
                                      ),
                                      textAlign: TextAlign.start,
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

                          const SizedBox(height: 35),

                          // Texto de cierre (Sin cursiva)
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 10.0,
                            ), // Padding opcional para espacio adicional
                            child: Text(
                              closingText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: "roboto",
                                color: _orangeColor,
                                fontWeight: FontWeight.bold, // AJUSTE: Negrilla
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),

                          const SizedBox(height: 35),

                          // --------------------------------------------------
                          // BOTONES DE FAVORITOS Y COMENTARIOS
                          // --------------------------------------------------
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildFavoritesSection(),
                              const SizedBox(width: 30),
                              _buildCommentButton(),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // --------------------------------------------------
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

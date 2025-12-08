import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:eco_granel_app/screens/recetas_screen.dart'; // Asegúrate de que esta importación sea correcta
import 'dart:developer';

// Tus colores globales
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);
const Color _lightGrey = Color(0xFFE0E0E0);
const Color _orangeColor = Color(0xFFC76939);
const Color _commentTextColor = Color(0xFF424242);

// -----------------------------------------------------------------
// FavoriteButton (Clase auxiliar)
// -----------------------------------------------------------------
class FavoriteButton extends StatefulWidget {
  final String recipeId;
  final User? currentUser;
  final String title;
  final String imageUrl;
  final String description;

  const FavoriteButton({
    super.key,
    required this.recipeId,
    required this.currentUser,
    required this.title,
    required this.imageUrl,
    required this.description,
  });

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool _isFavorite = false;

  DocumentReference<Map<String, dynamic>> _getFavoriteDocRef(String userId) {
    return FirebaseFirestore.instance
        .collection('userFavorites')
        .doc(userId)
        .collection('favorites')
        .doc(widget.recipeId);
  }

  @override
  void initState() {
    super.initState();
    if (widget.currentUser != null) {
      _checkInitialFavoriteStatus(widget.currentUser!.uid);
    }
  }

  @override
  void didUpdateWidget(covariant FavoriteButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.currentUser?.uid != oldWidget.currentUser?.uid) {
      if (widget.currentUser != null) {
        _checkInitialFavoriteStatus(widget.currentUser!.uid);
      } else {
        setState(() {
          _isFavorite = false;
        });
      }
    }
  }

  void _checkInitialFavoriteStatus(String userId) async {
    final docRef = _getFavoriteDocRef(userId);
    try {
      final docSnapshot = await docRef.get();
      if (mounted) {
        setState(() {
          _isFavorite = docSnapshot.exists;
        });
      }
    } catch (e) {
      log(
        'Error al verificar el estado de favorito: $e',
        name: 'FavoriteCheck',
      );
    }
  }

  void _toggleFavorite() async {
    if (widget.currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para agregar a favoritos.'),
          backgroundColor: _orangeColor,
        ),
      );
      return;
    }

    final userId = widget.currentUser!.uid;
    final docRef = _getFavoriteDocRef(userId);

    try {
      final newFavoriteStatus = !_isFavorite;

      if (newFavoriteStatus) {
        await docRef.set({
          'recipeId': widget.recipeId,
          'title': widget.title,
          'imageUrl': widget.imageUrl,
          'description': widget.description,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await docRef.delete();
      }

      if (mounted) {
        setState(() {
          _isFavorite = newFavoriteStatus;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al actualizar favoritos: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _toggleFavorite,
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
}

// -----------------------------------------------------------------
// CLASE PRINCIPAL: RecipeDetailScreen
// -----------------------------------------------------------------
class RecipeDetailScreen extends StatefulWidget {
  final Receta receta;

  const RecipeDetailScreen({super.key, required this.receta});

  @override
  State<RecipeDetailScreen> createState() => _RecipeDetailScreenState();
}

class _RecipeDetailScreenState extends State<RecipeDetailScreen> {
  final TextEditingController _commentController = TextEditingController();
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkCurrentUser();
  }

  // Función para obtener el usuario actual y escuchar cambios
  void _checkCurrentUser() {
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

  // --------------------------------------------------
  // AÑADIDO: LÓGICA PARA ELIMINAR EL COMENTARIO
  // --------------------------------------------------
  void _deleteComment(String commentId) async {
    try {
      await FirebaseFirestore.instance
          .collection('recetas')
          .doc(widget.receta.id)
          .collection('comments')
          .doc(commentId)
          .delete();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Comentario eliminado con éxito.'),
          backgroundColor: _primaryGreen,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al eliminar el comentario: $e'),
          backgroundColor: _orangeColor,
        ),
      );
    }
  }

  // --------------------------------------------------
  // AÑADIDO: DIÁLOGO DE CONFIRMACIÓN (Centrado y Padding)
  // --------------------------------------------------
  void _showDeleteConfirmationDialog(
    String commentId,
    BuildContext itemContext,
  ) {
    showDialog(
      context: itemContext,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          // Centrado con Padding
          title: Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 0),
            child: const Text(
              '¿Confirmas que quieres eliminar este comentario?',
              textAlign: TextAlign.center, // <-- Texto Centrado
              style: TextStyle(
                color: _unselectedDarkColor,
                fontSize: 18,
                fontFamily: "roboto",
                fontWeight: FontWeight.normal,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'CANCELAR',
                style: TextStyle(
                  color: _commentTextColor,
                  fontSize: 14,
                  fontFamily: "roboto",
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text(
                'ELIMINAR',
                style: TextStyle(
                  color: _orangeColor,
                  fontSize: 14,
                  fontFamily: "roboto",
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _deleteComment(commentId);
              },
            ),
          ],
        );
      },
    );
  }

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

    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: Chip(
        backgroundColor: color.withAlpha(38),
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
            color: color,
          ),
        ),
        avatar: Icon(icon, color: color, size: 20),
      ),
    );
  }

  Widget _buildCommentButton() {
    return GestureDetector(
      onTap: _showCommentModal,
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.comment_outlined, color: _unselectedDarkColor, size: 20),
          SizedBox(width: 8),
          Text(
            "Comentar",
            style: TextStyle(
              fontSize: 14,
              fontFamily: "roboto",
              color: _unselectedDarkColor,
              fontWeight: FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  void _showCommentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.8,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(
              18.0,
            ).copyWith(bottom: 18.0 + MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 40,
                      height: 5,
                      margin: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Comentarios de la Receta',
                      style: TextStyle(
                        fontSize: 18,
                        fontFamily: "roboto",
                        fontWeight: FontWeight.bold,
                        color: _primaryGreen,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.grey),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
                const Divider(),

                // Lista de Comentarios (Usa la función modificada)
                Expanded(
                  child: SingleChildScrollView(child: _buildCommentsList()),
                ),
                const Divider(),
                const SizedBox(height: 10),

                // FORMULARIO FIJO EN LA PARTE INFERIOR
                if (_currentUser != null)
                  _buildCommentForm()
                else
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20.0),
                    child: Text(
                      'Debes iniciar sesión para poder dejar un comentario.',
                      style: TextStyle(
                        fontSize: 16,
                        color: _orangeColor,
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

  Widget _buildCommentForm() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: TextField(
            controller: _commentController,
            decoration: InputDecoration(
              hintText: "Añadir un comentario...",
              fillColor: _lightGrey.withAlpha(128),
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(20.0),
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
        IconButton(
          icon: const Icon(Icons.send, color: _primaryGreen, size: 22),
          onPressed: _submitComment,
        ),
      ],
    );
  }

  // --------------------------------------------------
  // MODIFICADO: WIDGET DE LISTA DE COMENTARIOS
  // --------------------------------------------------
  Widget _buildCommentsList() {
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
                  child: Text(
                    "Sé el primero en comentar esta receta.",
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              );
            }

            return ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final commentDoc =
                    snapshot.data!.docs[index]; // Referencia al documento
                final commentData = commentDoc.data() as Map<String, dynamic>;
                final commentId = commentDoc.id; // ID del comentario
                final commentText = commentData['text'] ?? 'Comentario vacío';
                final userName = commentData['userName'] ?? 'Usuario Anónimo';
                final commentUserId =
                    commentData['userId'] as String?; // ID del autor

                // Determinar si puede borrar
                final bool canDelete =
                    _currentUser != null && commentUserId == _currentUser!.uid;

                final timestamp = commentData['timestamp'] as Timestamp?;
                final date = timestamp != null
                    ? ' - ${DateTime.fromMillisecondsSinceEpoch(timestamp.millisecondsSinceEpoch).toLocal().toString().split(' ')[0]}'
                    : '';

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nombre de usuario y fecha
                        Flexible(
                          child: Text(
                            '$userName$date',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: _primaryGreen,
                              fontFamily: 'roboto',
                            ),
                          ),
                        ),

                        // Botón de ELIMINAR (Solo si canDelete es true)
                        if (canDelete)
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: _orangeColor,
                              size: 20,
                            ),
                            onPressed: () {
                              _showDeleteConfirmationDialog(commentId, context);
                            },
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                          ),
                      ],
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

  // LÓGICA PARA ENVIAR EL COMENTARIO
  void _submitComment() async {
    if (_currentUser == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error: Debes iniciar sesión para comentar.'),
          backgroundColor: _orangeColor,
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

  // Función auxiliar para capitalizar la primera letra de cada palabra
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

      // ---------------- APP BAR ----------------
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: FittedBox(
          child: Text(
            widget.receta.title,
            style: const TextStyle(
              fontFamily: "roboto",
              fontWeight: FontWeight.w600,
              color: _unselectedDarkColor,
            ),
          ),
        ),
        iconTheme: const IconThemeData(color: _unselectedDarkColor, size: 30),
      ),

      // ---------------- CUERPO (FutureBuilder) ----------------
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

                //CONTENIDO DETALLADO
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // TÍTULO DEBAJO DE LA IMAGEN
                    Container(
                      color: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 20.0,
                      ),
                      width: double.infinity,
                      child: Text(
                        widget.receta.title,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          fontFamily: "roboto",
                          color: _unselectedDarkColor,
                        ),
                      ),
                    ),
                    // Usamos Padding para el resto del contenido
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 10),
                          // CATEGORÍA
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
                          // TIEMPO Y TEMPERATURA (Chips)
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
                          // --------------------------------------------------
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
                          // USO DE 'ingredients'
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
                          // USO de 'steps'
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

                          const SizedBox(height: 26),

                          // Texto de cierre
                          Padding(
                            padding: const EdgeInsets.only(bottom: 10.0),
                            child: Text(
                              closingText,
                              style: const TextStyle(
                                fontSize: 16,
                                fontFamily: "roboto",
                                color: _unselectedDarkColor,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.start,
                            ),
                          ),

                          const SizedBox(height: 26),

                          // --------------------------------------------------
                          // BOTONES DE FAVORITOS Y COMENTARIOS
                          // --------------------------------------------------
                          const Divider(),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              //AQUÍ SE PASAN LOS DATOS COMPLETOS DE LA RECETA AL BOTÓN DE FAVORITOS
                              FavoriteButton(
                                recipeId: widget.receta.id,
                                currentUser: _currentUser,
                                //Nuevos parámetros para guardar en la colección del usuario
                                title: widget.receta.title,
                                imageUrl: widget.receta.imageUrl,
                                description: widget.receta.description,
                              ),
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

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Definimos los colores utilizados en el diseño
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);
const Color _reactionButtonColor = Color(0xFF6E6E6E);
const Color _commentTextColor = Color(0xFF424242);
const Color _likeColor = Color(0xFF4CAF50);
const Color _orangeColor = Color(0xFFC76939);
const int _maxLinesExcerpt = 4;

// ------------------------------------
// 0. MODELOS DE DATOS (Firestore)
// ------------------------------------

class BlogPost {
  final String id;
  final String title;
  final String author;
  final String date;
  final String fullContent;
  final String imageUrl;

  BlogPost.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc)
    : id = doc.id,
      title = doc['title'] as String? ?? 'Título Desconocido',
      author = doc['author'] as String? ?? 'Eco Granel',
      date = doc['date'] as String? ?? 'Fecha Desconocida',
      fullContent = doc['fullContent'] as String? ?? 'Contenido no disponible',
      imageUrl = doc['imageUrl'] as String? ?? '';
}

class CommentData {
  final String id;
  final String authorName;
  final String content;
  final String time;
  final String userId;

  CommentData.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc)
    : id = doc.id,
      userId = doc['userId'] as String? ?? '',
      authorName = doc['authorName'] as String? ?? 'Anónimo',
      content = doc['content'] as String? ?? '',
      time = (doc['timestamp'] as Timestamp?) != null
          ? 'Recién publicado'
          : 'Ahora';
}

// ------------------------------------
// --- Comentario Individual (Para el Modal) ---
// AJUSTADO: Se añadió la lógica de confirmación al presionar eliminar.
// ------------------------------------
class _CommentItem extends StatelessWidget {
  final CommentData comment;
  final String? currentUserId;
  // La función onDelete ahora abre el diálogo de confirmación
  final Function(String commentId, BuildContext context) onDelete;

  const _CommentItem({
    required this.comment,
    required this.currentUserId,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    // Variable para determinar si el usuario actual es el autor del comentario
    final bool canDelete =
        currentUserId != null && currentUserId == comment.userId;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey,
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        comment.authorName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          fontFamily: "roboto",
                          color: _unselectedDarkColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      comment.time,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  comment.content,
                  style: const TextStyle(
                    fontSize: 14,
                    fontFamily: "roboto",
                    color: _commentTextColor,
                  ),
                ),
              ],
            ),
          ),
          // AÑADIDO: Botón de eliminar, visible solo para el autor
          if (canDelete)
            IconButton(
              icon: const Icon(
                Icons.delete_forever,
                color: _orangeColor,
                size: 20,
              ),
              // Llamamos a onDelete, pasando el ID del comentario y el contexto
              onPressed: () => onDelete(comment.id, context),
            ),
        ],
      ),
    );
  }
}

// ------------------------------------
// --- Modal de Comentarios (AJUSTADO: Uso de ModalBottomSheet) ---
// AJUSTADO: Se añadió el método _showDeleteConfirmationDialog
// ------------------------------------
class CommentsModal extends StatefulWidget {
  final String postId;

  const CommentsModal({super.key, required this.postId});

  @override
  State<CommentsModal> createState() => _CommentsModalState();
}

class _CommentsModalState extends State<CommentsModal> {
  final TextEditingController _commentController = TextEditingController();
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Lógica para agregar comentario a Firestore
  void _addComment() async {
    final String content = _commentController.text.trim();
    if (content.isNotEmpty && currentUser != null) {
      final String authorName =
          currentUser!.displayName ?? 'Usuario Autenticado';

      try {
        await FirebaseFirestore.instance.collection('comments').add({
          'postId': widget.postId,
          'userId': currentUser!.uid,
          'authorName': authorName,
          'content': content,
          'timestamp': FieldValue.serverTimestamp(),
        });

        _commentController.clear();

        if (mounted) {
          FocusScope.of(context).unfocus();
        }
      } catch (e) {
        // Manejar errores
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error al publicar comentario: $e')),
          );
        }
      }
    } else if (currentUser == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Debes iniciar sesión para comentar.')),
        );
      }
    }
  }

  // Lógica para eliminar comentario de Firestore
  void _deleteComment(String commentId) async {
    if (currentUser == null) return;

    try {
      // Intentamos eliminar el documento del comentario
      await FirebaseFirestore.instance
          .collection('comments')
          .doc(commentId)
          .delete();

      if (mounted) {
        // Muestra un mensaje de éxito, pero no cerramos el modal de comentarios
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comentario eliminado con éxito.'),
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al eliminar comentario: $e'),
            backgroundColor: _orangeColor,
          ),
        );
      }
    }
  }

  // AÑADIDO: Diálogo de confirmación
  void _showDeleteConfirmationDialog(
    String commentId,
    BuildContext itemContext,
  ) {
    showDialog(
      context: itemContext, // Usamos el contexto del elemento para el diálogo
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: Padding(
            padding: const EdgeInsets.only(
              top: 10.0,
              bottom: 0,
            ), // Ajusta el padding deseado (e.g., más arriba/abajo)
            child: const Text(
              '¿Confirmas que quieres eliminar este comentario?',
              textAlign: TextAlign.center,
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
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
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
                Navigator.of(dialogContext).pop(); // Cierra el diálogo
                _deleteComment(commentId); // Ejecuta la eliminación
              },
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white, // Fondo blanco para el modal
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0).copyWith(
          // Espacio extra para el teclado en la parte inferior si es necesario
          bottom: 18.0 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado (Manija + Título)
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
                  'Comentarios',
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: "roboto",
                    fontWeight: FontWeight.bold,
                    color: _primaryGreen,
                  ),
                ),
                // Botón de cierre
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.grey),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const Divider(),

            // Lista de Comentarios Existentes (StreamBuilder)
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection('comments')
                    .where('postId', isEqualTo: widget.postId)
                    .orderBy('timestamp', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return const Center(
                      child: Text('Error al cargar comentarios.'),
                    );
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: _primaryGreen),
                    );
                  }

                  final comments = snapshot.data!.docs
                      .map((doc) => CommentData.fromFirestore(doc))
                      .toList();

                  if (comments.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Center(
                        child: Text(
                          'Sé el primero en comentar.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: comments.length,
                    separatorBuilder: (context, index) => const Divider(
                      height: 1,
                      indent: 48,
                    ), // Indentado para alinear con el texto del comentario
                    itemBuilder: (context, index) {
                      return _CommentItem(
                        comment: comments[index],
                        currentUserId: currentUser?.uid,
                        // LLAMAMOS a la nueva función de confirmación
                        onDelete: _showDeleteConfirmationDialog,
                      );
                    },
                  );
                },
              ),
            ),
            const Divider(),

            // Campo para Añadir Nuevo Comentario
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: InputDecoration(
                        hintText: currentUser != null
                            ? 'Añadir un comentario...'
                            : 'Inicia sesión para comentar',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        fillColor: Colors.grey[200],
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 10,
                        ),
                      ),
                      minLines: 1,
                      maxLines: 4,
                      enabled:
                          currentUser != null, // Deshabilita si no hay usuario
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: _primaryGreen,
                      size: 22,
                    ),
                    onPressed: currentUser != null ? _addComment : null,
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

// ------------------------------------
// --- Barra de Reacciones (Mantenido igual) ---
// ------------------------------------
class ReactionBar extends StatelessWidget {
  final String postId;

  const ReactionBar({super.key, required this.postId});

  // Obtener el ID del usuario actual
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // Lógica de Toggle Like
  void _toggleLike(BuildContext context, bool isLiked) async {
    final userId = currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para dar "Me Gusta".'),
        ),
      );
      return;
    }

    final likeRef = FirebaseFirestore.instance.collection('likes');
    final docId = '${postId}_$userId';

    if (isLiked) {
      // Eliminar like
      await likeRef.doc(docId).delete();
    } else {
      // Agregar like
      await likeRef.doc(docId).set({
        'postId': postId,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  // Lógica de Toggle Save (CORREGIDA LA ADVERTENCIA ASÍNCRONA)
  void _toggleSave(BuildContext context, bool isSaved) async {
    final userId = currentUserId;
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para guardar artículos.'),
        ),
      );
      return;
    }

    final savedRef = FirebaseFirestore.instance.collection('saved_posts');
    final docId = '${userId}_$postId';

    if (isSaved) {
      // Eliminar guardado
      await savedRef.doc(docId).delete();

      // Usar context.mounted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Guardado eliminado'),
            duration: Duration(milliseconds: 1000),
          ),
        );
      }
    } else {
      // Agregar guardado
      await savedRef.doc(docId).set({
        'userId': userId,
        'postId': postId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Usar context.mounted
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Publicación guardada'),
            duration: Duration(milliseconds: 1000),
          ),
        );
      }
    }
  }

  void _showCommentsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled:
          true, // Importante para que ocupe gran parte de la pantalla y el teclado
      backgroundColor: Colors
          .transparent, // Necesario para ver el BorderRadius del Container
      builder: (BuildContext context) {
        return CommentsModal(postId: postId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = currentUserId;

    // 1. Stream para contar Likes
    final likesStream = FirebaseFirestore.instance
        .collection('likes')
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);

    // 2. Stream para verificar si el usuario actual le dio like
    final isLikedStream = userId != null
        ? FirebaseFirestore.instance
              .collection('likes')
              .doc('${postId}_$userId')
              .snapshots()
              .map((snapshot) => snapshot.exists)
        : Stream.value(false);

    // 3. Stream para verificar si el usuario actual guardó el post
    final isSavedStream = userId != null
        ? FirebaseFirestore.instance
              .collection('saved_posts')
              .doc('${userId}_$postId')
              .snapshots()
              .map((snapshot) => snapshot.exists)
        : Stream.value(false);

    // Stream anidado para manejar las tres propiedades
    return StreamBuilder<bool>(
      stream: isLikedStream,
      builder: (context, isLikedSnapshot) {
        final isLiked = isLikedSnapshot.data ?? false;

        return StreamBuilder<int>(
          stream: likesStream,
          builder: (context, likesSnapshot) {
            final currentLikes = likesSnapshot.data ?? 0;

            return StreamBuilder<bool>(
              stream: isSavedStream,
              builder: (context, isSavedSnapshot) {
                final isSaved = isSavedSnapshot.data ?? false;

                return Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Botón de Me Gusta
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            isLiked ? Icons.favorite : Icons.favorite_border,
                            color: isLiked ? _likeColor : _reactionButtonColor,
                          ),
                          onPressed: userId != null
                              ? () => _toggleLike(context, isLiked)
                              : null,
                        ),
                        Text(
                          currentLikes.toString(),
                          style: const TextStyle(
                            color: _reactionButtonColor,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),

                    // Botón de Comentar (Abrir Modal)
                    TextButton.icon(
                      icon: const Icon(
                        Icons.comment_outlined,
                        size: 20,
                        color: _reactionButtonColor,
                      ),
                      label: const Text(
                        'Comentar',
                        style: TextStyle(
                          color: _reactionButtonColor,
                          fontFamily: "roboto",
                          fontWeight: FontWeight.normal,
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () => _showCommentsModal(context),
                    ),

                    // Botón de Guardar
                    IconButton(
                      icon: Icon(
                        isSaved ? Icons.bookmark : Icons.bookmark_border,
                        color: isSaved ? _primaryGreen : _reactionButtonColor,
                      ),
                      onPressed: userId != null
                          ? () => _toggleSave(context, isSaved)
                          : null,
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}

// ------------------------------------
// --- MarkdownTextWidget (Mantenido Igual) ---
// ------------------------------------
class MarkdownTextWidget extends StatelessWidget {
  final String text;
  final int? maxLines;
  final TextOverflow? overflow;

  final TextStyle baseStyle = const TextStyle(
    fontSize: 14,
    fontFamily: "roboto",
    color: Color(0xFF424242),
    height: 1.4,
  );

  const MarkdownTextWidget({
    super.key,
    required this.text,
    this.maxLines,
    this.overflow,
  });

  List<InlineSpan> _parseBold(String line, TextStyle currentStyle) {
    final List<InlineSpan> spans = [];
    final cleanParts = line.split('**');
    bool isBold = false;

    for (int i = 0; i < cleanParts.length; i++) {
      final part = cleanParts[i];
      if (isBold) {
        spans.add(
          TextSpan(
            text: part,
            style: currentStyle.copyWith(
              fontWeight: FontWeight.bold,
              color: _unselectedDarkColor,
              fontFamily: "roboto",
            ),
          ),
        );
      } else {
        spans.add(TextSpan(text: part, style: currentStyle));
      }
      isBold = !isBold;
    }
    return spans;
  }

  List<InlineSpan> _parseText(String text) {
    final List<InlineSpan> spans = [];
    final lines = text.split('\n');
    final bulletStyle = baseStyle.copyWith(height: 1.2);

    for (var line in lines) {
      if (line.trim().isEmpty) {
        spans.add(const TextSpan(text: '\n', style: TextStyle(height: 0.5)));
        continue;
      }
      if (line.trim().startsWith('* ')) {
        spans.add(
          const TextSpan(
            text: '  • ',
            style: TextStyle(fontWeight: FontWeight.bold, color: _primaryGreen),
          ),
        );
        final content = line.trim().substring(2).trim();
        spans.addAll(_parseBold(content, bulletStyle));
        spans.add(const TextSpan(text: '\n'));
      } else {
        spans.addAll(_parseBold(line, baseStyle));
        spans.add(const TextSpan(text: '\n'));
      }
    }
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(children: _parseText(text), style: baseStyle),
      maxLines: maxLines,
      overflow: overflow ?? TextOverflow.clip,
    );
  }
}

// ------------------------------------
// --- PostCard (Mantenido Igual) ---
// ------------------------------------
class PostCard extends StatefulWidget {
  final BlogPost post;

  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final post = widget.post;
    final String displayText = post.fullContent;
    final bool needsExpansion =
        displayText.split('\n').length > _maxLinesExcerpt;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              const SizedBox(height: 8),
              // Título
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontFamily: "roboto",
                  fontWeight: FontWeight.bold,
                  color: _unselectedDarkColor,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),

              // Metadatos (Autor y fecha)
              Row(
                children: [
                  Text(
                    '${post.author} · ${post.date}',
                    style: const TextStyle(
                      fontSize: 12,
                      fontFamily: "roboto",
                      color: Colors.grey,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 8),

              // Línea de separación verde
              Container(height: 3, width: 60, color: _primaryGreen),
              const SizedBox(height: 10),

              // Contenido del Post (Markdown)
              GestureDetector(
                onTap: () {
                  if (needsExpansion && !_isExpanded) {
                    setState(() {
                      _isExpanded = true;
                    });
                  }
                },
                child: MarkdownTextWidget(
                  text: displayText,
                  maxLines: _isExpanded ? null : _maxLinesExcerpt,
                  overflow: TextOverflow.fade,
                ),
              ),

              // Botón Ver Más (Condicional)
              if (needsExpansion && !_isExpanded)
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isExpanded = true;
                    });
                  },
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 20),
                    alignment: Alignment.centerLeft,
                  ),
                  child: const Text(
                    'Ver Más',
                    style: TextStyle(
                      color: _primaryGreen,
                      fontWeight: FontWeight.bold,
                      fontFamily: "roboto",
                      fontSize: 14,
                    ),
                  ),
                ),
            ],
          ),
          // Fin del contenido principal del texto

          // Sección de la Imagen (Usamos NetworkImage para URLs de Firebase Storage)
          if (post.imageUrl.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Center(
                child: Container(
                  height: 260,
                  width: double.infinity,
                  margin: EdgeInsets.zero,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[300],
                    image: DecorationImage(
                      image: NetworkImage(post.imageUrl),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
            ),

          // Barra de Reacciones
          const Divider(height: 1, color: Colors.grey),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 0.0),
            child: ReactionBar(
              postId: post.id, // Pasamos el ID del post
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

// ------------------------------------
// --- Pantalla Principal del Blog (Mantenido Igual) ---
// ------------------------------------
class ForoScreen extends StatelessWidget {
  const ForoScreen({super.key});

  Widget _articleDivider() {
    return const Divider(
      color: Color.fromRGBO(224, 224, 224, 1),
      height: 10,
      thickness: 5,
      indent: 0,
      endIndent: 0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: <Widget>[
          // Sliver para el Título
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.fromLTRB(20.0, 14.0, 16.0, 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Comunidad Eco Granel",
                    style: TextStyle(
                      fontFamily: "roboto",
                      fontSize: 24,
                      color: _unselectedDarkColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Sliver para los Artículos (StreamBuilder de Firestore)
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            // Consulta a Firestore: trae todos los posts
            stream: FirebaseFirestore.instance
                .collection('posts')
                .orderBy('date', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text('Error al cargar artículos: ${snapshot.error}'),
                  ),
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: _primaryGreen),
                  ),
                );
              }

              final posts = snapshot.data!.docs
                  .map((doc) => BlogPost.fromFirestore(doc))
                  .toList();

              if (posts.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(child: Text('No hay artículos publicados.')),
                );
              }

              // Generar PostCards intercalados con divisores
              return SliverList(
                delegate: SliverChildBuilderDelegate((
                  BuildContext context,
                  int index,
                ) {
                  if (index.isOdd) {
                    return _articleDivider();
                  }
                  final postIndex = index ~/ 2;
                  final post = posts[postIndex];

                  return PostCard(post: post);
                }, childCount: posts.length * 2 - 1),
              );
            },
          ),
        ],
      ),
    );
  }
}

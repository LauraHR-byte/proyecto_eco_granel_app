import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

// ------------------------------------
// 0. CONSTANTES Y REUSO DE WIDGETS
// ------------------------------------

const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);
const Color _reactionButtonColor = Color(0xFF6E6E6E);
const Color _commentTextColor = Color(0xFF424242);
const Color _likeColor = Color(0xFF4CAF50);
const int _maxLinesExcerpt = 4;

// ------------------------------------
// 0. MODELOS DE DATOS (Firestore) (REUTILIZADO)
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

  CommentData.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc)
    : id = doc.id,
      authorName = doc['authorName'] as String? ?? 'Anónimo',
      content = doc['content'] as String? ?? '',
      time = (doc['timestamp'] as Timestamp?) != null
          ? 'Recién publicado'
          : 'Ahora';
}

// ------------------------------------
// --- Comentario Individual (REUTILIZADO) ---
// ------------------------------------
class _CommentItem extends StatelessWidget {
  final CommentData comment;
  const _CommentItem({required this.comment});
  @override
  Widget build(BuildContext context) {
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
        ],
      ),
    );
  }
}

// ------------------------------------
// --- Modal de Comentarios (REUTILIZADO) ---
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

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.all(18.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(18.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
              const Divider(),

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
                      return const Center(
                        child: Text(
                          'Sé el primero en comentar.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: comments.length,
                      separatorBuilder: (context, index) =>
                          const Divider(height: 1),
                      itemBuilder: (context, index) {
                        return _CommentItem(comment: comments[index]);
                      },
                    );
                  },
                ),
              ),
              const Divider(),

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
                            currentUser !=
                            null, // Deshabilita si no hay usuario
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: _primaryGreen),
                      onPressed: currentUser != null ? _addComment : null,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ------------------------------------
// --- Barra de Reacciones (REUTILIZADO) ---
// ------------------------------------
class ReactionBar extends StatelessWidget {
  final String postId;

  const ReactionBar({super.key, required this.postId});

  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  void _toggleLike(BuildContext context, bool isLiked) async {
    final userId = currentUserId;
    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para dar "Me Gusta".'),
          ),
        );
      }
      return;
    }

    final likeRef = FirebaseFirestore.instance.collection('likes');
    final docId = '${postId}_$userId';

    if (isLiked) {
      await likeRef.doc(docId).delete();
    } else {
      await likeRef.doc(docId).set({
        'postId': postId,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
      });
    }
  }

  void _toggleSave(BuildContext context, bool isSaved) async {
    final userId = currentUserId;
    if (userId == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para guardar artículos.'),
          ),
        );
      }
      return;
    }

    final savedRef = FirebaseFirestore.instance.collection('saved_posts');
    final docId = '${userId}_$postId';

    if (isSaved) {
      await savedRef.doc(docId).delete();

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Guardado eliminado'),
            duration: Duration(milliseconds: 1000),
          ),
        );
      }
    } else {
      await savedRef.doc(docId).set({
        'userId': userId,
        'postId': postId,
        'timestamp': FieldValue.serverTimestamp(),
      });

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
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CommentsModal(postId: postId);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final userId = currentUserId;

    final likesStream = FirebaseFirestore.instance
        .collection('likes')
        .where('postId', isEqualTo: postId)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);

    final isLikedStream = userId != null
        ? FirebaseFirestore.instance
              .collection('likes')
              .doc('${postId}_$userId')
              .snapshots()
              .map((snapshot) => snapshot.exists)
        : Stream.value(false);

    final isSavedStream = userId != null
        ? FirebaseFirestore.instance
              .collection('saved_posts')
              .doc('${userId}_$postId')
              .snapshots()
              .map((snapshot) => snapshot.exists)
        : Stream.value(false);

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
                          fontSize: 14,
                        ),
                      ),
                      onPressed: () => _showCommentsModal(context),
                    ),

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
// --- MarkdownTextWidget (REUTILIZADO) ---
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
            text: '  • ',
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
// --- PostCard (REUTILIZADO) ---
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

              Container(height: 3, width: 60, color: _primaryGreen),
              const SizedBox(height: 10),

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
// --- Pantalla de Posts Guardados (guardados_screen.dart) ---
// ------------------------------------

class GuardadoScreen extends StatelessWidget {
  const GuardadoScreen({super.key});

  Widget _articleDivider() {
    return const Divider(
      color: Color.fromRGBO(224, 224, 224, 1),
      height: 10,
      thickness: 5,
      indent: 0,
      endIndent: 0,
    );
  }

  // Obtener el ID del usuario actual
  String? get currentUserId => FirebaseAuth.instance.currentUser?.uid;

  // Consulta para obtener los IDs de los posts guardados por el usuario actual
  Stream<List<String>> _getSavedPostIdsStream(String userId) {
    return FirebaseFirestore.instance
        .collection('saved_posts')
        .where('userId', isEqualTo: userId)
        .orderBy(
          'timestamp',
          descending: true,
        ) // Ordenar por guardado más reciente
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs.map((doc) => doc['postId'] as String).toList(),
        );
  }

  // Función para obtener los objetos BlogPost a partir de una lista de IDs
  Future<List<BlogPost>> _fetchBlogPosts(List<String> postIds) async {
    if (postIds.isEmpty) {
      return [];
    }

    // Firestore solo permite consultas 'in' con hasta 10 elementos.
    // Si tu lista de posts guardados puede ser mayor a 10, necesitarías
    // dividir la consulta o cambiar la estructura de la base de datos.
    // Asumiremos que el límite de 10 es suficiente o manejado por el backend/UI.
    final postQuerySnapshot = await FirebaseFirestore.instance
        .collection('posts')
        .where(FieldPath.documentId, whereIn: postIds.take(10).toList())
        .get();

    // Mapear los posts obtenidos a objetos BlogPost
    final posts = postQuerySnapshot.docs
        .map((doc) => BlogPost.fromFirestore(doc))
        .toList();

    // Reordenar los posts según el orden de guardado (postIds)
    final postMap = {for (var post in posts) post.id: post};

    // Solo devolver los posts encontrados, en el orden de los IDs guardados
    return postIds
        .where((id) => postMap.containsKey(id))
        .map((id) => postMap[id]!)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final userId = currentUserId;

    if (userId == null) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              '🔒 Debes iniciar sesión para ver tus publicaciones guardadas.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontFamily: "roboto",
                color: Colors.grey,
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Guardados',
          style: TextStyle(
            fontFamily: "roboto",
            fontSize: 20,
            color: _unselectedDarkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        // La flecha de volver atrás (back button) es agregada automáticamente**
        // por Flutter si esta pantalla fue lanzada con Navigator.push().**
        // Si la necesitas explícitamente:**
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
            color: _unselectedDarkColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: CustomScrollView(
        slivers: <Widget>[
          // Se eliminó el SliverToBoxAdapter que contenía el título manual.

          // StreamBuilder para obtener los IDs guardados
          StreamBuilder<List<String>>(
            stream: _getSavedPostIdsStream(userId),
            builder: (context, snapshotPostIds) {
              if (snapshotPostIds.hasError) {
                return SliverToBoxAdapter(
                  child: Center(
                    child: Text(
                      'Error al cargar guardados: ${snapshotPostIds.error}',
                    ),
                  ),
                );
              }

              if (snapshotPostIds.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: _primaryGreen),
                  ),
                );
              }

              final savedPostIds = snapshotPostIds.data ?? [];

              if (savedPostIds.isEmpty) {
                return const SliverFillRemaining(
                  child: Center(
                    child: Text(
                      'No has guardado ninguna publicación aún.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                );
              }

              // FutureBuilder anidado para obtener los detalles de cada BlogPost
              return FutureBuilder<List<BlogPost>>(
                future: _fetchBlogPosts(savedPostIds),
                builder: (context, snapshotPosts) {
                  if (snapshotPosts.connectionState ==
                      ConnectionState.waiting) {
                    // Mantenemos el loading
                    return const SliverFillRemaining(
                      child: Center(
                        child: CircularProgressIndicator(color: _primaryGreen),
                      ),
                    );
                  }

                  if (snapshotPosts.hasError) {
                    return SliverToBoxAdapter(
                      child: Center(
                        child: Text(
                          'Error al obtener posts: ${snapshotPosts.error}',
                        ),
                      ),
                    );
                  }

                  final posts = snapshotPosts.data ?? [];

                  if (posts.isEmpty) {
                    return const SliverFillRemaining(
                      child: Center(
                        child: Text('No se encontraron artículos.'),
                      ),
                    );
                  }

                  // Mostrar la lista de PostCard
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
              );
            },
          ),
        ],
      ),
    );
  }
}

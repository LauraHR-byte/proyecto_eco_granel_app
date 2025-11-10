import 'package:flutter/material.dart';

// Definimos los colores utilizados en el diseño
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(
  0xFF333333,
); // Color oscuro para títulos
const Color _reactionButtonColor = Color(
  0xFF6E6E6E,
); // Color para los iconos de reacción
const Color _commentTextColor = Color(
  0xFF424242,
); // Color para el texto de comentarios
const Color _likeColor = Color(0xFF4CAF50); // Color para el corazón relleno
const int _maxLinesExcerpt =
    4; // Líneas máximas para el extracto (Vista reducida)

// --- Comentario Individual (Para el Modal) ---
class _CommentItem extends StatelessWidget {
  final String author;
  final String content;
  final String time;

  const _CommentItem({
    required this.author,
    required this.content,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ícono o avatar simulado
          const CircleAvatar(
            radius: 18,
            backgroundColor: Colors.grey, // Cambiado a gris para distinguirlo
            child: Icon(Icons.person, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      author,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: _unselectedDarkColor,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      time,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  content,
                  style: const TextStyle(
                    fontSize: 14,
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

// --- Modal de Comentarios (Nuevo Componente) ---
class CommentsModal extends StatefulWidget {
  final String postTitle;
  final List<Map<String, String>> initialComments;

  const CommentsModal({
    super.key,
    required this.postTitle,
    required this.initialComments,
  });

  @override
  State<CommentsModal> createState() => _CommentsModalState();
}

class _CommentsModalState extends State<CommentsModal> {
  late List<Map<String, String>> _comments;
  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _comments = List.from(widget.initialComments);
  }

  void _addComment() {
    if (_commentController.text.trim().isNotEmpty) {
      setState(() {
        _comments.insert(0, {
          'author': 'Usuario Actual', // Simulación del usuario que comenta
          'content': _commentController.text.trim(),
          'time': 'Ahora',
        });
        _commentController.clear();
      });
      // Cerrar el teclado después de comentar
      FocusScope.of(context).unfocus();
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
      insetPadding: const EdgeInsets.all(16.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.8, // 80% de la altura
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Encabezado del Modal
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // CAMBIO SOLICITADO: Solo muestra "Comentarios"
                  const Text(
                    'Comentarios',
                    style: TextStyle(
                      fontSize: 18,
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

              // Lista de Comentarios Existentes
              Expanded(
                child: ListView.separated(
                  itemCount: _comments.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final comment = _comments[index];
                    return _CommentItem(
                      author: comment['author']!,
                      content: comment['content']!,
                      time: comment['time']!,
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
                          hintText: 'Añadir un comentario...',
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
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.send, color: _primaryGreen),
                      onPressed: _addComment,
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

// --- 0. Componente de Barra de Reacciones (Like, Comentar, Guardar) ---
class ReactionBar extends StatefulWidget {
  final int initialLikes;
  final int commentsCount;
  final String postTitle;
  final List<Map<String, String>> initialComments;

  const ReactionBar({
    super.key,
    required this.initialLikes,
    required this.commentsCount,
    required this.postTitle,
    required this.initialComments,
  });

  @override
  State<ReactionBar> createState() => _ReactionBarState();
}

class _ReactionBarState extends State<ReactionBar> {
  late bool _isLiked;
  late int _currentLikes;
  bool _isSaved = false; // Estado para el botón de Guardar

  @override
  void initState() {
    super.initState();
    // Simulación: El post inicia 'no gustado', el contador es el valor inicial.
    _isLiked = false;
    _currentLikes = widget.initialLikes;
  }

  void _toggleLike() {
    setState(() {
      _isLiked = !_isLiked;
      if (_isLiked) {
        _currentLikes++;
      } else {
        _currentLikes--;
      }
    });
  }

  void _toggleSave() {
    setState(() {
      _isSaved = !_isSaved;
    });
    // Opcional: Mostrar un SnackBar al usuario
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isSaved ? 'Publicación guardada' : 'Guardado eliminado'),
        duration: const Duration(milliseconds: 1000),
      ),
    );
  }

  void _showCommentsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Usa el nuevo widget de CommentsModal
        return CommentsModal(
          postTitle: widget.postTitle,
          initialComments: widget.initialComments,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // 1. Botón de Me Gusta (con cambio de estado)
        Row(
          children: [
            IconButton(
              icon: Icon(
                _isLiked ? Icons.favorite : Icons.favorite_border,
                color: _isLiked ? _likeColor : _reactionButtonColor,
              ),
              onPressed: _toggleLike,
            ),
            Text(
              _currentLikes.toString(),
              style: const TextStyle(color: _reactionButtonColor, fontSize: 13),
            ),
          ],
        ),

        // 2. Botón de Comentar (Abre Modal de Comentarios)
        TextButton.icon(
          icon: const Icon(
            Icons.comment_outlined,
            size: 20,
            color: _reactionButtonColor,
          ),
          // CAMBIO SOLICITADO: Mostrar solo la palabra "Comentarios"
          label: const Text(
            'Comentarios',
            style: TextStyle(color: _reactionButtonColor, fontSize: 13),
          ),
          onPressed: () => _showCommentsModal(context),
        ),

        // 3. Botón de Guardar (Reemplaza a Compartir)
        IconButton(
          icon: Icon(
            _isSaved ? Icons.bookmark : Icons.bookmark_border,
            color: _isSaved ? _primaryGreen : _reactionButtonColor,
          ),
          onPressed: _toggleSave,
        ),
      ],
    );
  }
}

// --- Widget para Markdown (Mantenido igual) ---
class MarkdownTextWidget extends StatelessWidget {
  final String text;
  final int? maxLines;
  final TextOverflow? overflow;

  final TextStyle baseStyle = const TextStyle(
    fontSize: 14,
    color: Color(0xFF424242),
    height: 1.4,
  );

  const MarkdownTextWidget({
    super.key,
    required this.text,
    this.maxLines,
    this.overflow,
  });

  // Función para parsear negritas dentro de una línea
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

  // Función principal para parsear todo el texto
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

// --- 1. Componente de la Tarjeta de Publicación con Continuidad (PostCard) ---
class PostCard extends StatefulWidget {
  final String title;
  final String author;
  final String date;
  final String fullContent;
  final String imageUrl;
  final int commentsCount;
  final int likesCount;
  final List<Map<String, String>> initialComments; // Añadido

  const PostCard({
    super.key,
    required this.title,
    required this.author,
    required this.date,
    required this.fullContent,
    this.imageUrl = '',
    this.commentsCount = 0,
    this.likesCount = 0,
    required this.initialComments, // Requerido
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // Inicialmente no expandido para mostrar el extracto
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final String displayText = widget.fullContent;
    // Determina si el texto es lo suficientemente largo para necesitar "Ver Más"
    // Usamos una estimación simple basada en la cantidad de líneas.
    final bool needsExpansion =
        displayText.split('\n').length > _maxLinesExcerpt;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Título y Metadatos
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _unselectedDarkColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  Row(
                    children: [
                      // Autor y fecha
                      Text(
                        '${widget.author} · ${widget.date}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // El icono de Guardar del metadato se quita ya que ahora está en la ReactionBar
                      // Se mantiene el spacer para alinear el texto
                      const Spacer(),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Línea de separación verde
                  Container(height: 3, width: 60, color: _primaryGreen),
                  const SizedBox(height: 10),

                  // **Contenido del Post**
                  // Permite expandir al tocar el texto
                  GestureDetector(
                    onTap: () {
                      if (needsExpansion && !_isExpanded) {
                        setState(() {
                          _isExpanded = true; // Solo se permite expandir
                        });
                      }
                    },
                    child: MarkdownTextWidget(
                      text: displayText,
                      // Se usa maxLines si NO está expandido
                      maxLines: _isExpanded ? null : _maxLinesExcerpt,
                      overflow: TextOverflow.fade,
                    ),
                  ),

                  // **Botón Ver Más (Condicional)**
                  // Solo se muestra si necesita expansión y aún no está expandido
                  if (needsExpansion && !_isExpanded)
                    TextButton(
                      onPressed: () {
                        setState(() {
                          _isExpanded =
                              true; // CAMBIO SOLICITADO: Solo 'Ver Más'
                        });
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(50, 20),
                        alignment: Alignment.centerLeft,
                      ),
                      child: const Text(
                        'Ver Más', // CAMBIO SOLICITADO: Se muestra solo "Ver Más"
                        style: TextStyle(
                          color: _primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // **Sección de la Imagen**
            if (widget.imageUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Center(
                  child: Container(
                    height: 200,
                    width: double.infinity,
                    margin: const EdgeInsets.symmetric(horizontal: 16.0),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(8),
                      // Simulación de carga de imagen de asset
                      image: DecorationImage(
                        image: AssetImage('assets/images/${widget.imageUrl}'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

            // **Barra de Reacciones**
            const Divider(height: 1, color: Colors.grey),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: ReactionBar(
                initialLikes: widget.likesCount,
                commentsCount: widget.commentsCount,
                postTitle: widget.title,
                initialComments: widget.initialComments,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- 2. Pantalla Principal del Blog (BlogScreen) ---
class ForoScreen extends StatelessWidget {
  const ForoScreen({super.key});

  final List<Map<String, dynamic>> blogPosts = const [
    {
      'title': 'El Impacto de los Envases en el Medioambiente y Cómo Reducirlo',
      'author': 'EcoGranel',
      'date': '1 min de lectura',
      'fullContent': '''
Los envases plásticos y desechables forman parte de nuestra vida cotidiana, pero ¿te has preguntado cuál es su verdadero impacto en el planeta? A continuación, te mostramos por qué debemos reducir su uso y cómo la compra a granel puede ser una gran solución.

**La Realidad del Plástico**
Se estima que el 91% del plástico producido no se recicla y termina en vertederos o en los océanos.
* Un envase de plástico puede tardar hasta 500 años en degradarse por completo.
* Cada año, más de 8 millones de toneladas de plástico llegan a los océanos, afectando la fauna marina.

**¿Cómo Reducir el Uso de Envases?**
* Compra a granel - Optar por productos sin envase reduce significativamente los residuos plásticos.
* Usa recipientes reutilizables - Frascos de vidrio, bolsas de tela y contenedores de acero inoxidable son excelentes opciones.
* Prefiere materiales biodegradables - Busca alternativas como papel reciclado, vidrio o envases compostables.
* Reutiliza y recicla correctamente - Asegúrate de separar y reciclar los residuos de forma adecuada.

**Un Cambio de Hábito, un Gran Impacto**
Adoptar pequeñas acciones diarias puede marcar la diferencia. Al elegir productos sin envase y fomentar la reutilización, contribuyes a un mundo más limpio y sostenible. Cada elección cuenta. ¿Te sumas al movimiento cero residuos?''',
      'imageUrl': 'placeholder_envases.jpg',
      'comments': 2,
      'likes': 42,
      'initialComments': [
        {
          'author': 'María L.',
          'content':
              '¡Excelente artículo! La información sobre el 91% no reciclado es impactante.',
          'time': '1 día',
        },
        {
          'author': 'Juan P.',
          'content':
              'Empecé a comprar a granel y realmente se nota la diferencia en los residuos.',
          'time': '3 horas',
        },
      ],
    },
    {
      'title':
          'Comprar a Granel: Una Forma Inteligente de Ahorrar y Cuidar el Planeta',
      'author': 'EcoGranel',
      'date': '2 min de lectura',
      'fullContent':
          'En un mundo donde el desperdicio de alimentos y plásticos sigue en aumento, optar por la **compra a granel** es una decisión responsable que beneficia tanto a tu **bolsillo** como al medioambiente. Las ventajas incluyen:\n* Precios más bajos.\n* Capacidad de comprar solo lo necesario.\n* Reducción drástica de residuos de envases.\n\nEs una forma de consumo consciente y una elección poderosa para un futuro más verde. ¡Únete a la compra consciente y haz la diferencia en cada visita al supermercado!',
      'imageUrl': 'placeholder_ahorro.jpg',
      'comments': 1,
      'likes': 25,
      'initialComments': [
        {
          'author': 'Anita R.',
          'content': 'Totalmente de acuerdo, he ahorrado bastante.',
          'time': '5 días',
        },
      ],
    },
    {
      'title': 'Cómo Conservar tus Alimentos a Granel por Más Tiempo',
      'author': 'EcoGranel',
      'date': '1 min de lectura',
      'fullContent':
          'Para aprovechar al máximo los beneficios de comprar a granel, es importante saber cómo **almacenar correctamente** cada producto y evitar desperdicios. Consejos clave:\n* Usa **frascos herméticos de vidrio**.\n* Almacena en un lugar fresco y seco.\n* Etiqueta las fechas de compra.\n\nEsto no solo mantiene la **frescura** sino que también te ayuda a rotar tu inventario de forma eficiente. ¡Adiós al desperdicio!',
      'imageUrl': 'alimentos_granel.png', // Usado como referencia visual
      'comments': 1,
      'likes': 58,
      'initialComments': [
        {
          'author': 'Felipe G.',
          'content': 'El truco de los frascos de vidrio me ha servido mucho.',
          'time': 'Hace 2 semanas',
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Comunidad Eco Granel",
          style: TextStyle(
            fontFamily: "roboto",
            fontSize: 24,
            color: _unselectedDarkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        elevation: 1,
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        itemCount: blogPosts.length,
        itemBuilder: (context, index) {
          final post = blogPosts[index];
          return PostCard(
            title: post['title']!,
            author: post['author']!,
            date: post['date']!,
            fullContent: post['fullContent']!,
            imageUrl: post['imageUrl']!,
            commentsCount: post['comments'],
            likesCount: post['likes'],
            initialComments:
                post['initialComments'], // Pasar los comentarios iniciales
          );
        },
      ),
    );
  }
}

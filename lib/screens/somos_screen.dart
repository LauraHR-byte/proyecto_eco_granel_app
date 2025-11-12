import 'package:flutter/material.dart';

// Definimos el color verde primario
const Color _primaryGreen = Color(0xFF4CAF50);
// Definición del color oscuro para títulos y texto principal
const Color _unselectedDarkColor = Color(0xFF424242);

// Colores del Blog necesarios para ReactionBar
const Color _reactionButtonColor = Color(0xFF6E6E6E);
const Color _likeColor = Color(0xFF4CAF50);
const Color _commentTextColor = Color(0xFF424242);

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

// --- Modal de Comentarios ---
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
          'author': 'Usuario Actual',
          'content': _commentController.text.trim(),
          'time': 'Ahora',
        });
        _commentController.clear();
      });
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
          height: MediaQuery.of(context).size.height * 0.8,
          padding: const EdgeInsets.all(16.0),
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

// --- Componente de Barra de Reacciones (SIN botón de Guardar, Centrado) ---
class _ReactionBar extends StatefulWidget {
  final int initialLikes;
  final int commentsCount;
  final String postTitle;
  final List<Map<String, String>> initialComments;

  const _ReactionBar({
    required this.initialLikes,
    required this.commentsCount,
    required this.postTitle,
    required this.initialComments,
  });

  @override
  State<_ReactionBar> createState() => _ReactionBarState();
}

class _ReactionBarState extends State<_ReactionBar> {
  late bool _isLiked;
  late int _currentLikes;

  @override
  void initState() {
    super.initState();
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

  void _showCommentsModal(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CommentsModal(
          postTitle: widget.postTitle,
          initialComments: widget.initialComments,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // AJUSTE CLAVE: Centrar los botones
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, // <-- ESTE ES EL CAMBIO
      children: [
        // 1. Botón de Me Gusta
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

        const SizedBox(width: 20), // <-- ESPACIO AUMENTADO
        // 2. Botón de Comentar (Abre Modal de Comentarios)
        TextButton.icon(
          icon: const Icon(
            Icons.comment_outlined,
            size: 20,
            color: _reactionButtonColor,
          ),
          label: const Text(
            'Comentarios',
            style: TextStyle(color: _reactionButtonColor, fontSize: 13),
          ),
          onPressed: () => _showCommentsModal(context),
        ),
      ],
    );
  }
}

class SomosScreen extends StatelessWidget {
  const SomosScreen({super.key});

  // Datos simulados para los botones de interacción y comentarios
  static const int _simulatedLikes = 15;
  static const List<Map<String, String>> _simulatedComments = [
    {
      'author': 'Elena M.',
      'content': '¡Qué gran iniciativa! Necesitamos más espacios así.',
      'time': 'hace 2h',
    },
    {
      'author': 'Roberto G.',
      'content': 'Me encanta el concepto. ¿Tienen envíos a domicilio?',
      'time': 'hace 5h',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. REEMPLAZAMOS CustomScrollView con AppBar estándar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false, // Alineación a la izquierda como en Ubicaciones
        titleSpacing: 0.0, // Espaciado mínimo como en Ubicaciones
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
            color: _unselectedDarkColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          "Compra consciente, vive sostenible",
          style: TextStyle(
            color: _unselectedDarkColor,
            fontSize: 20,
            fontFamily: "roboto",
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      // 2. REEMPLAZAMOS CustomScrollView con SingleChildScrollView
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Contenedor principal para padding
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const SizedBox(height: 10),

                  // Imagen Principal (Contaminación por Plástico/Océano)
                  const _MainImage(
                    imageAsset: 'assets/images/plasticos-en-mar.jpg',
                  ),
                  const SizedBox(height: 15),

                  // Texto de introducción
                  const Text(
                    "Creemos que cada pequeña elección puede generar un gran"
                    " impacto. Nos especializamos en la venta de alimentos a"
                    " granel, ofreciendo productos frescos y de alta calidad"
                    " sin empaques innecesarios. Nuestro objetivo es brindar"
                    " una alternativa de consumo más sostenible, accesible y"
                    " saludable para todas las personas que desean reducir"
                    " desperdicios y hacer compras responsables.",
                    style: TextStyle(
                      fontSize: 14,
                      fontFamily: "roboto",
                      color: _unselectedDarkColor,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            // DIVISOR MODIFICADO (Ocupa todo el ancho sin padding)
            const Divider(
              color: Color.fromRGBO(224, 224, 224, 100),
              height: 50,
              thickness: 5,
              indent: 0,
              endIndent: 0,
            ),

            // Contenido con el padding horizontal de 22.0
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 2. Nuestra Historia
                  const _SectionHeader(title: "Nuestra Historia"),
                  const _HistoryContent(),
                ],
              ),
            ),

            // DIVISOR MODIFICADO (Ocupa todo el ancho sin padding)
            const Divider(
              color: Color.fromRGBO(224, 224, 224, 100),
              height: 50,
              thickness: 5,
              indent: 0,
              endIndent: 0,
            ),

            // Contenido con el padding horizontal de 22.0
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 3. Nuestra Misión
                  const _SectionHeader(title: "Nuestra Misión"),
                  const _MissionContent(),
                ],
              ),
            ),

            // DIVISOR MODIFICADO (Ocupa todo el ancho sin padding)
            const Divider(
              color: Color.fromRGBO(224, 224, 224, 100),
              height: 50,
              thickness: 5,
              indent: 0,
              endIndent: 0,
            ),

            // Contenido con el padding horizontal de 22.0
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 22.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // 4. Nuestros Valores
                  const _SectionHeader(title: "Nuestros Valores"),
                  const _ValuesContent(),

                  // Separador y Texto Final
                  const SizedBox(height: 20),
                  const Text(
                    "¡Gracias por ser parte de este movimiento sostenible!",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _primaryGreen,
                      fontSize: 16,
                      fontFamily: "roboto",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Barra de Reacciones (CENTRADA)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: _ReactionBar(
                      initialLikes: _simulatedLikes,
                      commentsCount: _simulatedComments.length,
                      postTitle: "Compra consciente, vive sostenible",
                      initialComments: _simulatedComments,
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Componentes Reutilizables (Modificados) ---

class _MainImage extends StatelessWidget {
  final String imageAsset;
  const _MainImage({required this.imageAsset});

  @override
  Widget build(BuildContext context) {
    // Container con una imagen simulada
    return ClipRRect(
      borderRadius: BorderRadius.circular(12.0),
      child: Image.asset(
        imageAsset,
        fit: BoxFit.cover,
        width: double.infinity,
        height: 260.0, // <-- MODIFICACIÓN A 260
        errorBuilder: (context, error, stackTrace) => Container(
          width: double.infinity,
          height: 260.0, // <-- MODIFICACIÓN A 260
          color: _primaryGreen.withAlpha(50),
          child: const Center(
            child: Icon(Icons.public, size: 50, color: _primaryGreen),
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          color: _primaryGreen,
          fontSize: 16,
          fontFamily: "roboto",
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class _HistoryContent extends StatelessWidget {
  const _HistoryContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const <Widget>[
        Text(
          "Todo empezó con un sueño: hacer del mundo un lugar más consciente,"
          " donde cada acción cuente. Creemos que pequeñas acciones generan"
          " grandes cambios, y por eso decidimos crear un espacio donde encontrar"
          " productos que respeten el planeta y cuiden de nosotros.",
          style: TextStyle(
            fontSize: 14,
            fontFamily: "roboto",
            height: 1.5,
            color: _unselectedDarkColor,
          ),
        ),
        SizedBox(height: 10),
        Text(
          "Cada alimento a granel, cada artículo sostenible que ofrecemos,"
          " ha sido elegido con amor y responsabilidad. Queremos ser parte de"
          " una compra diferente, sin desperdicios innecesarios y con la"
          " esperanza de que estés contribuyendo a un futuro más limpio y justo.",
          style: TextStyle(
            fontSize: 14,
            fontFamily: "roboto",
            height: 1.5,
            color: _unselectedDarkColor,
          ),
        ),
      ],
    );
  }
}

class _MissionContent extends StatelessWidget {
  const _MissionContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(8.0),
          child: Image.asset(
            'assets/images/somos.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: 260,
            errorBuilder: (context, error, stackTrace) => Container(
              width: double.infinity,
              height: 180,
              color: _primaryGreen.withAlpha(50),
              child: const Center(
                child: Icon(Icons.person, size: 50, color: _primaryGreen),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          "Facilitar el acceso a productos a granel de primera calidad y"
          " asequibles, promoviendo hábitos de consumo responsables que"
          " contribuyan al bienestar de las personas y el cuidado del planeta.",
          style: TextStyle(
            fontSize: 14,
            fontFamily: "roboto",
            height: 1.5,
            color: _unselectedDarkColor,
          ),
        ),
      ],
    );
  }
}

class _ValuesContent extends StatelessWidget {
  const _ValuesContent();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const _ValueItem(
          title: "Sostenibilidad",
          description:
              "Creemos en un modelo de negocio que respeta el medio ambiente,"
              " eliminando los envases plásticos y fomentando el consumo"
              " consciente.",
        ),
        const _ValueItem(
          title: "Calidad y frescura",
          description:
              "Nos comprometemos a seleccionar cuidadosamente cada producto"
              " para garantizar ingredientes naturales, sin aditivos y en su"
              " punto óptimo de frescura.",
        ),
        const _ValueItem(
          title: "Compromiso con la comunidad",
          description:
              "Trabajamos con proveedores responsables y apoyamos la economía"
              " local, fortaleciendo el comercio justo.",
        ),
        const _ValueItem(
          title: "Flexibilidad y ahorro",
          description:
              "Ofrecemos la posibilidad de comprar la cantidad exacta que"
              " se necesita, lo que permite reducir desperdicios y ahorrar"
              " dinero.",
        ),
        const _ValueItem(
          title: "Educación y conciencia",
          description:
              "Queremos inspirar a más personas a adoptar un estilo de vida"
              " más sostenible a través de nuestro blog, talleres y actividades.",
        ),
        const _ValueItem(
          title: "Únete al cambio",
          description:
              "Comprar a granel no es solo una tendencia, es una forma de"
              " contribuir a un futuro mejor para todos.",
        ),
        const SizedBox(height: 10),
        const Text(
          "Te invitamos a formar parte de esta comunidad que elige consumir"
          " con conciencia. Juntos podemos hacer una gran diferencia.",
          style: TextStyle(
            fontSize: 14,
            fontFamily: "roboto",
            height: 1.5,
            color: _unselectedDarkColor,
          ),
        ),
      ],
    );
  }
}

class _ValueItem extends StatelessWidget {
  final String title;
  final String description;
  const _ValueItem({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              fontFamily: "roboto",
              color: _unselectedDarkColor,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            description,
            style: const TextStyle(
              fontSize: 14,
              fontFamily: "roboto",
              color: _unselectedDarkColor,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

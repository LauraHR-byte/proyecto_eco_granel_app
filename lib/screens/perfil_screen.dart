import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Asegúrate de que estas rutas son correctas en tu proyecto
import 'package:eco_granel_app/login/inicio_screen.dart';
import 'package:eco_granel_app/screens/edit_profile_screen.dart';
import 'package:eco_granel_app/screens/guardado_screen.dart';
import 'package:eco_granel_app/screens/like_screen.dart';
import 'package:eco_granel_app/screens/pedidos_screen.dart';
import 'privacidad_screen.dart';
import 'condiciones_screen.dart';

const Color _unselectedDarkColor = Color(0xFF333333);
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _orangeColor = Color(0xFFC76939);
const Color _commentTextColor = Color(0xFF424242);

// ----------------------------------------------------------------------
// COMPONENTES REUTILIZABLES (Sin cambios)
// ----------------------------------------------------------------------

class _ProfileOptionRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  final String? subtitle;

  const _ProfileOptionRow({
    required this.title,
    required this.icon,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 12.0),
        child: Row(
          children: <Widget>[
            Icon(icon, color: _unselectedDarkColor, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontFamily: "roboto",
                      color: _unselectedDarkColor,
                    ),
                  ),
                  if (subtitle != null && icon != Icons.language)
                    Text(
                      subtitle!,
                      style: const TextStyle(
                        fontSize: 14,
                        fontFamily: "roboto",
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            if (subtitle != null && icon == Icons.language)
              Text(
                subtitle!,
                style: const TextStyle(
                  fontSize: 16,
                  fontFamily: "roboto",
                  color: Colors.grey,
                ),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 18),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final EdgeInsets padding;

  const _SectionHeader({
    required this.title,
    this.padding = const EdgeInsets.fromLTRB(18.0, 24.0, 18.0, 8.0),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontFamily: "roboto",
          fontWeight: FontWeight.bold,
          color: _unselectedDarkColor,
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// PERFIL SCREEN
// ----------------------------------------------------------------------

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  // Función de navegación para Guardado
  void _navigateToGuardado() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const GuardadoScreen()),
    );
  }

  // Función de navegación a LikesScreen
  void _navigateToLikes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const LikesScreen()),
    );
  }

  // Función de navegación a PedidosScreen <--- 2. Nueva función de navegación
  void _navigateToOrders() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PedidosScreen()),
    );
  }

  // Lógica de cierre de sesión con Firebase Auth
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      // Navegar a InicioScreen y remover todas las rutas anteriores
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const InicioScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cerrar sesión: $e')));
      }
    }
  }

  // Función: DIÁLOGO DE CONFIRMACIÓN CON ESTILO PERSONALIZADO
  void _confirmLogout() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          // Estilo de tarjeta moderna (esquinas redondeadas)
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),

          // Título Centrado
          title: const Text(
            "¿Salir de tu cuenta?",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.normal,
              fontFamily: "roboto",
              color: _unselectedDarkColor,
            ),
          ),

          // Contenido vacío (si no hay texto extra)
          content: null,

          // Acciones personalizadas (Botones)
          actions: <Widget>[
            // Usamos un Center para envolver los botones y que se alineen al centro del diálogo
            Center(
              child: Padding(
                padding: const EdgeInsets.only(
                  bottom: 10.0,
                  left: 10.0,
                  right: 10.0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    // ------------------------------------------------
                    // Botón CANCELAR (Fondo Blanco, Borde Gris, Texto Oscuro)
                    // ------------------------------------------------
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.grey,
                          overlayColor: Colors.grey.withAlpha(
                            25,
                          ), // Overlay sutil
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "CANCELAR",
                          style: TextStyle(
                            fontFamily: "roboto",
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _commentTextColor, // Texto oscuro
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // ------------------------------------------------
                    // Botón SALIR (Fondo Blanco, Borde Naranja, Texto Naranja)
                    // ------------------------------------------------
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                          _logout();
                        },
                        style: ElevatedButton.styleFrom(
                          foregroundColor: _orangeColor,
                          overlayColor: _orangeColor.withAlpha(
                            25,
                          ), // Overlay sutil
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: const BorderSide(
                              color: _orangeColor, // Borde Naranja
                              width: 1,
                            ),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          "SALIR",
                          style: TextStyle(
                            fontFamily: "roboto",
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: _orangeColor, // Texto Naranja
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          // Eliminamos el padding automático del content si es nulo
          contentPadding: EdgeInsets.zero,
          // Eliminamos el padding automático de las acciones para controlarlo con el Padding del Row
          actionsPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        );
      },
    );
  }

  void _navigateToPrivacyPolicy() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PrivacidadScreen()),
    );
  }

  void _navigateToTerms() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const CondicionesScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 0,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // El encabezado ahora se encarga de cargar los datos del usuario
            const _ProfileHeader(),

            const _SectionHeader(title: "Tu actividad"),
            _ProfileOptionRow(
              title: "Guardados",
              icon: Icons.bookmark_border,
              onTap: _navigateToGuardado,
            ),
            _ProfileOptionRow(
              title: "Likes",
              icon: Icons.favorite_border,
              onTap: _navigateToLikes,
            ),
            _ProfileOptionRow(
              title: "Mis pedidos",
              icon: Icons.local_shipping_outlined,
              onTap:
                  _navigateToOrders, // <--- 3. Usar la nueva función de navegación
            ),

            const Divider(
              color: Color.fromRGBO(224, 224, 224, 1.0),
              height: 50,
              thickness: 5,
              indent: 0,
              endIndent: 0,
            ),

            const _SectionHeader(
              title: "Soporte",
              padding: EdgeInsets.fromLTRB(18.0, 16.0, 18.0, 8.0),
            ),
            _ProfileOptionRow(
              title: "Política de Privacidad",
              icon: Icons.check_box_outlined,
              subtitle: "Prácticas de privacidad",
              onTap: _navigateToPrivacyPolicy,
            ),
            _ProfileOptionRow(
              title: "Términos y condiciones",
              icon: Icons.description_outlined,
              subtitle: "Lea los términos que acepta al usar la aplicación",
              onTap: _navigateToTerms,
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  //LLAMAR A LA FUNCIÓN DE CONFIRMACIÓN
                  onPressed: _confirmLogout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _orangeColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: const Text(
                    "Cerrar Sesión",
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: "roboto",
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ----------------------------------------------------------------------
// PROFILE HEADER (CORREGIDO PARA ACTUALIZACIÓN INSTANTÁNEA) (Sin cambios)
// ----------------------------------------------------------------------

class _ProfileHeader extends StatefulWidget {
  const _ProfileHeader();

  @override
  State<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<_ProfileHeader> {
  String _displayName = 'Cargando...';
  String _username = '@cargando';
  String? _photoURL;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    // Carga inicial de datos al crear el widget
    _loadUserData();
  }

  // Función para cargar datos del usuario desde Firebase/Firestore
  Future<void> _loadUserData() async {
    _currentUser = FirebaseAuth.instance.currentUser;

    if (_currentUser != null) {
      final uid = _currentUser!.uid;

      try {
        // Accede a la colección 'users' con el UID del usuario
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .get();

        if (doc.exists) {
          final data = doc.data();
          if (mounted) {
            setState(() {
              // Lee 'fullName' (Nombre y Apellido) de Firestore
              _displayName = data?['fullName'] ?? 'Usuario';

              // Lee 'username' (Alias) de Firestore
              _username = '@${data?['username'] ?? 'usuario'}';

              // Leer el photoURL de Firestore
              _photoURL = data?['photoURL'] as String?;
            });
          }
        } else {
          // Fallback si el documento no existe (usa la información de Auth)
          if (mounted) {
            setState(() {
              _displayName = _currentUser!.displayName ?? 'Usuario';
              _username = '@${_currentUser!.email?.split('@')[0] ?? 'usuario'}';
              // Fallback de photoURL usando la URL de Firebase Auth si existe
              _photoURL = _currentUser!.photoURL;
            });
          }
        }
      } catch (e) {
        if (mounted) {
          // Muestra un error si la carga falla (ej. problemas de conexión)
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
        }
      }
    } else {
      // Estado si no hay un usuario logueado
      if (mounted) {
        setState(() {
          _displayName = 'Invitado';
          _username = 'Inicia sesión para ver tu perfil';
          _photoURL = null; // Asegura que no haya URL de invitado
        });
      }
    }
  }

  // FUNCIÓN DE NAVEGACIÓN A EDITAR PERFIL - MODIFICADA
  // Ahora es asíncrona y llama a _loadUserData() al regresar.
  void _navigateToEditProfile() async {
    if (_currentUser != null) {
      // Espera hasta que la pantalla EditarPerfilScreen se cierre
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditarPerfilScreen()),
      );

      // Al regresar, recarga los datos del usuario para actualizar el avatar y el texto.
      _loadUserData();
    } else {
      // Muestra un mensaje si no hay usuario logueado
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para editar tu perfil.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Determinar el widget del avatar
    Widget avatarWidget;
    if (_photoURL != null && _photoURL!.isNotEmpty) {
      // Si hay una URL de foto, usa NetworkImage
      avatarWidget = CircleAvatar(
        radius: 35,
        // Usa un key único para asegurar que NetworkImage se recargue si la URL cambia
        key: ValueKey(_photoURL),
        backgroundImage: NetworkImage(_photoURL!),
        backgroundColor:
            Colors.transparent, // Color de fondo si la imagen no carga
      );
    } else {
      // Si no hay URL, usa el icono de persona por defecto
      avatarWidget = CircleAvatar(
        radius: 35,
        backgroundColor: Colors.grey[200],
        child: const Icon(Icons.person, size: 40, color: _primaryGreen),
      );
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 18.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // Usar el widget de avatar determinado
              avatarWidget,
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    _displayName, // Muestra el Nombre y Apellido
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    _username, // Muestra el Alias/Usuario
                    style: TextStyle(
                      fontSize: 16,
                      fontFamily: "roboto",
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: _navigateToEditProfile,
            style: OutlinedButton.styleFrom(
              foregroundColor: _orangeColor,
              side: const BorderSide(color: _orangeColor),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              "Editar Perfil",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontFamily: "roboto",
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

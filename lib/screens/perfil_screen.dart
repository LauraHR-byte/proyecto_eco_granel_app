import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Asegúrate de que estas rutas son correctas en tu proyecto
import 'package:eco_granel_app/login/inicio_screen.dart';
import 'privacidad_screen.dart';
import 'condiciones_screen.dart';

const Color _unselectedDarkColor = Color(0xFF333333);
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _orangeColor = Color(0xFFC76939);

// --- Componentes Reutilizables ---

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
// PERFIL SCREEN (Contiene la lógica de navegación y cierre de sesión)
// ----------------------------------------------------------------------

class PerfilScreen extends StatefulWidget {
  const PerfilScreen({super.key});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  void _handleTap(BuildContext context, String action) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Acción: $action')));
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

  // FUNCIÓN PARA MOSTRAR EL DIÁLOGO DE CONFIRMACIÓN CON ESTILO DE PROTOTIPO
  void _confirmLogout() {
    // Usamos showGeneralDialog para tener control total sobre el fondo oscuro
    showGeneralDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(
        120,
      ), // Color de fondo oscuro (50% opacidad)
      barrierDismissible: false, // El usuario debe seleccionar una opción
      transitionDuration: const Duration(milliseconds: 200),
      pageBuilder: (context, anim1, anim2) {
        return Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 40, vertical: 330),
            padding: const EdgeInsets.all(30.0),
            decoration: BoxDecoration(
              color: Colors.grey[700],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  "¿Salir de tu cuenta?",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    fontFamily: "roboto",
                    color: Colors.white,
                    decoration: TextDecoration.none,
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    // ------------------------------------------------
                    // Botón Salir (Fondo Blanco, Overlay Naranja)
                    // ------------------------------------------------
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Cierra el diálogo y luego ejecuta el logout
                          Navigator.of(context).pop();
                          _logout();
                        },
                        style: ElevatedButton.styleFrom(
                          // Fondo por defecto: BLANCO
                          backgroundColor: Colors.white,
                          // Color del texto por defecto: GRIS
                          foregroundColor: Colors.grey,
                          // Color al presionar: NARANJA (con opacidad para el efecto 'tap')
                          overlayColor: _orangeColor.withAlpha(255),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            // Borde sutil del botón
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          elevation:
                              0, // Quitamos la elevación para que parezca más plano
                        ),
                        child: const Text(
                          "Salir",
                          style: TextStyle(
                            fontFamily: "roboto",
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: _unselectedDarkColor, // Texto oscuro
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    // ------------------------------------------------
                    // Botón Cancelar (Fondo Blanco, Overlay Naranja)
                    // ------------------------------------------------
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Solo cierra el diálogo
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          // Fondo por defecto: BLANCO
                          backgroundColor: Colors.white,
                          // Color del texto por defecto: GRIS
                          foregroundColor: Colors.grey,
                          // Color al presionar: NARANJA (con opacidad para el efecto 'tap')
                          overlayColor: _orangeColor.withAlpha(255),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            // Borde sutil del botón
                            side: const BorderSide(
                              color: Colors.grey,
                              width: 1,
                            ),
                          ),
                          elevation:
                              0, // Quitamos la elevación para que parezca más plano
                        ),
                        child: Text(
                          "Cancelar",
                          style: TextStyle(
                            fontFamily: "roboto",
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color:
                                _unselectedDarkColor, // Mantenemos el texto naranja para resaltarlo
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
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
              title: "Guardado",
              icon: Icons.bookmark_border,
              onTap: () => _handleTap(context, 'Guardado'),
            ),
            _ProfileOptionRow(
              title: "Likes",
              icon: Icons.favorite_border,
              onTap: () => _handleTap(context, 'Likes'),
            ),
            _ProfileOptionRow(
              title: "Mis pedidos",
              icon: Icons.local_shipping_outlined,
              onTap: () => _handleTap(context, 'Mis pedidos'),
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
                horizontal: 20.0,
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
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 5,
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
// PROFILE HEADER (Contiene la lógica de carga de datos de Firestore)
// ----------------------------------------------------------------------

class _ProfileHeader extends StatefulWidget {
  const _ProfileHeader();

  @override
  State<_ProfileHeader> createState() => _ProfileHeaderState();
}

class _ProfileHeaderState extends State<_ProfileHeader> {
  String _displayName = 'Cargando...';
  String _username = '@cargando';
  User? _currentUser;

  @override
  void initState() {
    super.initState();
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
          setState(() {
            // Lee 'fullName' (Nombre y Apellido) de Firestore
            _displayName = data?['fullName'] ?? 'Usuario';

            // Lee 'username' (Alias) de Firestore
            _username = '@${data?['username'] ?? 'usuario'}';
          });
        } else {
          // Fallback si el documento no existe (usa la información de Auth)
          setState(() {
            _displayName = _currentUser!.displayName ?? 'Usuario';
            _username = '@${_currentUser!.email?.split('@')[0] ?? 'usuario'}';
          });
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
      setState(() {
        _displayName = 'Invitado';
        _username = 'Inicia sesión para ver tu perfil';
      });
    }
  }

  void _handleTap(BuildContext context, String action) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Acción: $action')));
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 18.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.person, size: 40, color: _primaryGreen),
              ),
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
            onPressed: () => _handleTap(context, 'Editar Perfil'),
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

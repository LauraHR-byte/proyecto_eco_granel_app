import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Definiciones de Color (Copias de PerfilScreen para consistencia) ---

const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);
const Color _orangeColor = Color(0xFFC76939);

// ----------------------------------------------------------------------
// PANTALLA DE EDICIÓN DE PERFIL
// ----------------------------------------------------------------------

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  // 1. Controladores para los campos de texto
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();

  // 2. Estado de la carga y el guardado
  bool _isLoading = true;
  bool _isSaving = false;
  String? _currentPhotoUrl; // URL de la foto de perfil actual

  @override
  void initState() {
    super.initState();
    _loadInitialUserData();
  }

  // 3. Cargar datos iniciales del usuario
  Future<void> _loadInitialUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      // Si no hay usuario, navega de vuelta o muestra un error
      if (mounted) Navigator.of(context).pop();
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists) {
        final data = doc.data();

        // Asignar los valores a los controladores
        _fullNameController.text = data?['fullName'] ?? '';
        _usernameController.text = data?['username'] ?? '';
        _currentPhotoUrl =
            data?['photoURL']; // Asumiendo que guardas la URL de la foto
      } else {
        // Fallback usando datos de FirebaseAuth
        _fullNameController.text = user.displayName ?? '';
        _usernameController.text = user.email?.split('@')[0] ?? '';
        _currentPhotoUrl = user.photoURL;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar datos: $e')));
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 4. Lógica para guardar los cambios
  Future<void> _saveProfileChanges() async {
    // Validar campos si es necesario (ej. que no estén vacíos)
    if (_fullNameController.text.trim().isEmpty ||
        _usernameController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, complete todos los campos.'),
          ),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) return;

    try {
      // 4a. Actualizar en Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {
          'fullName': _fullNameController.text.trim(),
          'username': _usernameController.text.trim(),
          // La actualización de la foto requiere lógica de subida a Storage
          // 'photoURL': _newPhotoUrl,
        },
      );

      // 4b. (Opcional) Actualizar en Firebase Auth
      await user.updateDisplayName(_fullNameController.text.trim());

      if (mounted) {
        // Muestra mensaje de éxito y regresa a la pantalla anterior
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Perfil actualizado con éxito!')),
        );
        Navigator.of(context).pop(true); // Retorna 'true' para indicar éxito
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al guardar: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // 5. Función de ejemplo para subir foto (aquí iría la lógica de ImagePicker y Firebase Storage)
  void _changeProfilePicture() {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Abriendo selector de imágenes...')),
      );
    }
    // Lógica real: Usar ImagePicker y subir a Firebase Storage
    // Después de subir, actualizar _currentPhotoUrl
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        title: const Text(
          'Editar Perfil',
          style: TextStyle(
            fontFamily: "roboto",
            fontSize: 20,
            color: _unselectedDarkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0, // Eliminamos la sombra para que se vea plano
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
            color: _unselectedDarkColor,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: _primaryGreen))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // --- Sección de Foto de Perfil ---
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          // Si hay URL, usa NetworkImage; sino, usa el icono por defecto
                          backgroundImage:
                              _currentPhotoUrl != null &&
                                  _currentPhotoUrl!.isNotEmpty
                              ? NetworkImage(_currentPhotoUrl!) as ImageProvider
                              : null,
                          child:
                              _currentPhotoUrl == null ||
                                  _currentPhotoUrl!.isEmpty
                              ? const Icon(
                                  Icons.person,
                                  size: 60,
                                  color: _primaryGreen,
                                )
                              : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _changeProfilePicture,
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: _orangeColor,
                              child: const Icon(
                                Icons.edit,
                                size: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  // --- Campo Nombre Completo ---
                  const Text(
                    "Nombre Completo",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _unselectedDarkColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  _CustomTextField(
                    controller: _fullNameController,
                    hintText: "Nombre y Apellido",
                    icon: Icons.person_outline,
                  ),

                  const SizedBox(height: 20),

                  // --- Campo Nombre de Usuario ---
                  const Text(
                    "Nombre de Usuario",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _unselectedDarkColor,
                    ),
                  ),

                  const SizedBox(height: 8),

                  _CustomTextField(
                    controller: _usernameController,
                    hintText: "usuario123",
                    icon: Icons.alternate_email,
                  ),

                  const SizedBox(height: 40),

                  // --- Botón de Guardar ---
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveProfileChanges,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _orangeColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text(
                            "Guardar Cambios",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: "roboto",
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}

// ----------------------------------------------------------------------
// WIDGET DE CAMPO DE TEXTO REUTILIZABLE PARA UNIFICAR EL ESTILO
// ----------------------------------------------------------------------

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final IconData? icon;

  const _CustomTextField({
    required this.controller,
    required this.hintText,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: _unselectedDarkColor),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: icon != null
            ? Icon(icon, color: _unselectedDarkColor.withAlpha(153))
            : null,
        filled: true,
        fillColor: Colors.grey[100],
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15.0,
          horizontal: 10.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: BorderSide.none, // Borde más suave
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(
            color: Color.fromRGBO(224, 224, 224, 1.0),
            width: 1.0,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
          borderSide: const BorderSide(color: _orangeColor, width: 2.0),
        ),
      ),
    );
  }
}

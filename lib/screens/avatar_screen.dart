import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- Definiciones de Color (Consistencia con tu código) ---

const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);
const Color _orangeColor = Color(0xFFC76939);

// ----------------------------------------------------------------------
// PANTALLA DE SELECCIÓN DE AVATAR
// ----------------------------------------------------------------------

class SeleccionarAvatarScreen extends StatefulWidget {
  // Parámetro para pasar la URL de la foto actual (opcional)
  final String? currentAvatarUrl;

  const SeleccionarAvatarScreen({super.key, this.currentAvatarUrl});

  @override
  State<SeleccionarAvatarScreen> createState() =>
      _SeleccionarAvatarScreenState();
}

class _SeleccionarAvatarScreenState extends State<SeleccionarAvatarScreen> {
  // Lista para almacenar las URLs de los avatares
  List<String> _avatarUrls = [];
  // URL del avatar seleccionado actualmente por el usuario
  String? _selectedAvatarUrl;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Inicializa la selección con el avatar actual del perfil
    _selectedAvatarUrl = widget.currentAvatarUrl;
    _loadAvatars();
  }

  // 1. Obtener URLs de avatares desde Firebase Firestore
  Future<void> _loadAvatars() async {
    try {
      // **Asume que tienes una colección en Firestore llamada 'avatars'**
      final querySnapshot = await FirebaseFirestore.instance
          .collection('avatars')
          .orderBy(
            'order',
            descending: false,
          ) // Opcional: para ordenar los avatares
          .get();

      final urls = querySnapshot.docs
          .map((doc) => doc.data()['url'] as String)
          .where((url) => url.isNotEmpty)
          .toList();

      setState(() {
        _avatarUrls = urls;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error al cargar avatares: $e')));
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 2. Guardar la selección del avatar en el perfil del usuario (OPTIMIZADA)
  Future<void> _saveSelectedAvatar() async {
    if (_selectedAvatarUrl == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, seleccione un avatar.')),
        );
      }
      return;
    }

    setState(() {
      _isSaving = true;
    });

    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      setState(() => _isSaving = false);
      return;
    }

    try {
      // 1. Rápido: Actualizar el campo 'photoURL' en Firestore
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update(
        {'photoURL': _selectedAvatarUrl},
      );

      // 2. ¡CLAVE! Regresa inmediatamente después de la actualización rápida de Firestore.
      // Esto hace que el botón parezca instantáneo.
      if (mounted) {
        Navigator.of(context).pop(_selectedAvatarUrl);
      }

      // 3. Lento: Actualizar en Firebase Auth. Esto se ejecuta DESPUÉS del pop.
      // Si esta actualización falla, el usuario ya estará en la pantalla anterior.
      await user.updatePhotoURL(_selectedAvatarUrl);
    } catch (e) {
      // Si ocurre un error ANTES del pop
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al guardar el avatar: $e')),
        );
      }
      // Asegurarse de quitar el loading si no pudimos hacer el pop
      setState(() {
        _isSaving = false;
      });
    }
    // No se usa 'finally' porque si fue exitoso, la pantalla ya se cerró.
  }

  // 3. Builder del Grid de Avatares
  Widget _buildAvatarGrid() {
    return GridView.builder(
      shrinkWrap:
          true, // Para que tome el tamaño necesario dentro del SingleChildScrollView
      physics:
          const NeverScrollableScrollPhysics(), // Deshabilita el scroll del grid
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 3 avatares por fila
        crossAxisSpacing: 15.0, // Espacio horizontal
        mainAxisSpacing: 15.0, // Espacio vertical
      ),
      itemCount: _avatarUrls.length,
      itemBuilder: (context, index) {
        final url = _avatarUrls[index];
        final isSelected = url == _selectedAvatarUrl;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedAvatarUrl = url;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: isSelected
                  ? Border.all(
                      color: _orangeColor, // Color de selección
                      width: 5.0,
                    )
                  : Border.all(color: Colors.grey.shade300, width: 1.0),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: _orangeColor.withAlpha(102),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: ClipOval(
              child: Image.network(
                url,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      color: _primaryGreen,
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.broken_image,
                    size: 60,
                    color: Colors.red,
                  );
                },
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Seleccionar Avatar',
          style: TextStyle(
            fontFamily: "roboto",
            fontSize: 20,
            color: _unselectedDarkColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
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
                  const Text(
                    "Elige tu avatar de perfil:",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: _unselectedDarkColor,
                    ),
                  ),
                  const SizedBox(height: 20),

                  // --- Grid de Avatares ---
                  _avatarUrls.isEmpty
                      ? const Center(
                          child: Text(
                            "No hay avatares disponibles.",
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : _buildAvatarGrid(),

                  const SizedBox(height: 40),

                  // --- Botón de Guardar ---
                  ElevatedButton(
                    onPressed: _isSaving ? null : _saveSelectedAvatar,
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
                            "Confirmar Avatar",
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

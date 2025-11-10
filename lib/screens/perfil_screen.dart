import 'package:flutter/material.dart';

// Definimos los colores del tema y la paleta necesaria
// Eliminada _primaryGreen, ya que no se utiliza y causaba advertencia.
const Color _darkTextColor = Color(
  0xFF333333,
); // Color oscuro para texto principal
const Color _orangeColor = Color(
  0xFFC76939,
); // Color del botón "Cerrar Sesión" y "Editar Perfil"

// --- Componente de Fila de Opción de Menú (Para secciones de lista) ---
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
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: Row(
          children: <Widget>[
            Icon(icon, color: Colors.black, size: 24),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                  if (subtitle != null && icon != Icons.language)
                    Text(
                      subtitle!,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                ],
              ),
            ),
            if (subtitle != null && icon == Icons.language)
              Text(
                subtitle!,
                style: const TextStyle(fontSize: 16, color: Colors.grey),
              ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward_ios, color: Colors.grey, size: 16),
          ],
        ),
      ),
    );
  }
}

// --- Encabezado de Sección (Para "Tu actividad", "Preferencias", "Soporte") ---
class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  // ¡CORRECCIÓN APLICADA AQUÍ! Se corrige la sintaxis de BuildContext.
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 24.0, 16.0, 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: _darkTextColor,
        ),
      ),
    );
  }
}

// --- Pantalla Principal del Perfil (PerfilScreen) ---
class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  void _handleTap(BuildContext context, String action) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Acción: $action')));
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
            const _ProfileHeader(),

            // --- Tu actividad ---
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
              title: "Comentarios",
              icon: Icons.chat_bubble_outline,
              onTap: () => _handleTap(context, 'Comentarios'),
            ),
            _ProfileOptionRow(
              title: "Mis pedidos",
              icon: Icons.local_shipping_outlined,
              onTap: () => _handleTap(context, 'Mis pedidos'),
            ),

            const Divider(height: 30, thickness: 1, color: Color(0xFFE0E0E0)),

            // --- Preferencias ---
            const _SectionHeader(title: "Preferencias"),
            _ProfileOptionRow(
              title: "Idioma",
              icon: Icons.language,
              subtitle: "Español",
              onTap: () => _handleTap(context, 'Cambiar Idioma'),
            ),

            const Divider(height: 30, thickness: 1, color: Color(0xFFE0E0E0)),

            // --- Soporte ---
            const _SectionHeader(title: "Soporte"),
            _ProfileOptionRow(
              title: "Política de Privacidad",
              icon: Icons.check_box_outlined,
              subtitle: "Prácticas de privacidad",
              onTap: () => _handleTap(context, 'Política de Privacidad'),
            ),
            _ProfileOptionRow(
              title: "Términos y condiciones",
              icon: Icons.description_outlined,
              subtitle: "Lea los términos que acepta al usar la aplicación",
              onTap: () => _handleTap(context, 'Términos y condiciones'),
            ),

            // 3. Botón de Cerrar Sesión
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _handleTap(context, 'Cerrar Sesión'),
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
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

// --- Encabezado del Perfil de Usuario ---
class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              // Avatar del Usuario - Usando un icono de Flutter en su lugar
              CircleAvatar(
                radius: 35,
                backgroundColor: Colors.grey[200],
                child: const Icon(Icons.person, size: 40, color: Colors.grey),
              ),
              const SizedBox(width: 12),

              // Nombre y @Usuario
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    "Anita",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    "@anita_ambientalista",
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Botón "Editar Perfil"
          OutlinedButton(
            onPressed: () => _handleTap(context, 'Editar Perfil'),
            style: OutlinedButton.styleFrom(
              foregroundColor: _orangeColor,
              side: const BorderSide(color: _orangeColor),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            child: const Text(
              "Editar Perfil",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _handleTap(BuildContext context, String action) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Acción: $action')));
  }
}

// Nota: Para que el AssetImage funcione, debes tener una imagen llamada 'profile_image.png'
// en la carpeta 'assets/' y declarar la carpeta en el archivo pubspec.yaml.
// Si deseas usar un icono de Flutter en su lugar, reemplaza la sección de Container con CircleAvatar:
/*
CircleAvatar(
  radius: 35,
  backgroundColor: Colors.grey[200],
  child: const Icon(Icons.person, size: 40, color: Colors.grey),
),
*/

import 'package:flutter/material.dart';
// 1. IMPORTAR la pantalla de privacidad
import 'privacidad_screen.dart'; // Asegúrate de que esta ruta sea correcta
// 1. AÑADIDO: Importar la pantalla de términos y condiciones
import 'condiciones_screen.dart'; // ¡Asegúrate de que esta ruta sea correcta!

const Color _unselectedDarkColor = Color(0xFF333333);
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _orangeColor = Color(0xFFC76939);

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

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  // Función genérica para manejo de taps
  void _handleTap(BuildContext context, String action) {
    // 2. CORRECCIÓN: Se mantiene el Snackbar para otras opciones
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Acción: $action')));
  }

  // Función específica para navegar a la Política de Privacidad
  void _navigateToPrivacyPolicy(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const PrivacidadScreen(), // Usamos la clase importada
      ),
    );
  }

  // 2. AÑADIDO: Función específica para navegar a Términos y Condiciones
  void _navigateToTerms(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            const CondicionesScreen(), // Usamos la clase importada
      ),
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
            // Llama a la función de navegación para Privacidad
            _ProfileOptionRow(
              title: "Política de Privacidad",
              icon: Icons.check_box_outlined,
              subtitle: "Prácticas de privacidad",
              onTap: () => _navigateToPrivacyPolicy(context),
            ),
            // LLAMA A LA NUEVA FUNCIÓN DE NAVEGACIÓN PARA TÉRMINOS
            _ProfileOptionRow(
              title: "Términos y condiciones",
              icon: Icons.description_outlined,
              subtitle: "Lea los términos que acepta al usar la aplicación",
              onTap: () => _navigateToTerms(context), // <--- CAMBIO CLAVE AQUÍ
            ),

            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 24.0,
              ),
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

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

  void _handleTap(BuildContext context, String action) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Acción: $action')));
  }
}

import 'package:flutter/material.dart';

// Definimos el color verde primario para el tema (usando formato ARGB de 8 dígitos)
const Color _primaryGreen = Color(0xFF4CAF50);
// Definición del color oscuro para títulos (gris casi negro)
const Color _unselectedDarkColor = Color(0xFF333333);

class UbicacionesScreen extends StatelessWidget {
  const UbicacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        // AJUSTE: Permite que el título comience a la izquierda y use más espacio
        centerTitle: false,
        titleSpacing: 0.0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: _unselectedDarkColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Más que una tienda, un estilo de vida',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: _unselectedDarkColor,
            fontSize: 20, // AJUSTE: Reducimos ligeramente el tamaño
            fontWeight: FontWeight.bold,
            fontFamily: "roboto",
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 2.0,
              ),
              // AJUSTE: Container para aplicar bordes redondeados a la imagen
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    'assets/images/carro.JPG', // Usando Image.asset con la ruta local
                    fit: BoxFit.cover,
                    width: double
                        .infinity, // Asegura que ocupe todo el ancho disponible del Padding
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: _primaryGreen.withAlpha(51),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.info_outline,
                        color: _primaryGreen,
                        size: 50,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Text(
                'Puntos de Venta Móviles',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: "roboto",
                  color:
                      _primaryGreen, // Usamos _primaryGreen para un color consistente
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                "Nuestro carro sostenible recorre diferentes barrios de la"
                " ciudad de lunes a viernes, acercándose alimentos a granel,"
                " desayunos y snacks conscientes sin necesidad de desplazarte."
                " Encuentra aquí las ubicaciones y horarios de nuestros puntos"
                " de venta móviles.",
                style: TextStyle(
                  fontSize: 14,
                  color: _unselectedDarkColor,
                  fontFamily: "roboto",
                  height: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // REUTILIZAMOS EL MISMO WIDGET PARA LA IMAGEN DEL MAPA/CALENDARIO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    'assets/images/mapa.JPG', // Asumiendo otra imagen para el mapa
                    fit: BoxFit.cover,
                    width: double.infinity,
                    height: 200,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      color: _primaryGreen.withAlpha(51),
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Text(
                'Calendario Semanal',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: "roboto",
                  color: _primaryGreen,
                ),
              ),
            ),
            // Tarjetas de Horario
            _buildScheduleCard(
              day: 'Lunes',
              address: 'Cra. 33 #40-01 Barrio Villa Bolívar',
              location: 'Parque Villa Bolívar\nVillavicencio, Meta, Colombia',
              time: '9:00 - 17:00',
            ),
            _buildScheduleCard(
              day: 'Martes',
              address: 'Cra. 38a #8-05',
              location:
                  'Barrio del Doce Esperanza\nVillavicencio, Meta, Colombia',
              time: '9:00 - 17:00',
            ),
            _buildScheduleCard(
              day: 'Miércoles',
              address: 'Cra. 33 #40-44, Barrio Centro',
              location: 'Plaza los Libertadores\nVillavicencio, Meta, Colombia',
              time: '9:00 - 17:00',
            ),
            _buildScheduleCard(
              day: 'Jueves',
              address: 'Cra. 33 #40-44, Barrio Centro',
              location: 'Plaza los Libertadores\nVillavicencio, Meta, Colombia',
              time: '9:00 - 17:00',
            ),
            _buildScheduleCard(
              day: 'Viernes',
              address: 'Cra. 30 # 47B-96, Barrio Caudal',
              location:
                  'Parque Infantil del Centenario - Parque Caudal\nVillavicencio, Meta, Colombia',
              time: '9:00 - 17:00',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // Widget de Tarjeta de Horario
  Widget _buildScheduleCard({
    required String day,
    required String address,
    required String location,
    required String time,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    day,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: _unselectedDarkColor,
                      fontFamily: "roboto",
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _unselectedDarkColor,
                      fontFamily: "roboto",
                    ),
                  ),
                  Text(
                    location,
                    style: const TextStyle(
                      fontSize: 14,
                      color:
                          _unselectedDarkColor, // Color más tenue para la ubicación
                      fontFamily: "roboto",
                    ),
                  ),
                ],
              ),
            ),
            Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: _primaryGreen,
                fontFamily: "roboto",
              ),
            ),
          ],
        ),
      ),
    );
  }
}

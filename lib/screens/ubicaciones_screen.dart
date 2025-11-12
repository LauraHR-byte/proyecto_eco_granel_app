import 'package:flutter/material.dart';
// Importación necesaria para Google Maps
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Definimos el color verde primario para el tema (usando formato ARGB de 8 dígitos)
const Color _primaryGreen = Color(0xFF4CAF50);
// Definición del color oscuro para títulos (gris casi negro)
const Color _unselectedDarkColor = Color(0xFF333333);

// --- 1. Definición de las ubicaciones y coordenadas ---

class LocationPoint {
  final String name;
  final String address;
  final String schedule;
  final LatLng coordinates;
  final String snippet;

  LocationPoint({
    required this.name,
    required this.address,
    required this.schedule,
    required this.coordinates,
    required this.snippet,
  });
}

// Lista de todas las ubicaciones móviles con sus coordenadas reales
// (Se han usado coordenadas ficticias/cercanas a Villavicencio para el ejemplo)
final List<LocationPoint> _mobileLocations = [
  LocationPoint(
    name: 'Eco Granel Villa Bolívar (Lunes)',
    address: 'Cra. 33 #40-01 Barrio Villa Bolívar',
    schedule: 'Lunes: 9:00 - 17:00',
    coordinates: const LatLng(4.1437, -73.6163), // Ficticio
    snippet: 'Lunes: 9:00 AM - 5:00 PM',
  ),
  LocationPoint(
    name: 'Eco Granel 6ta Etapa Esperanza (Martes)',
    address: 'Cra. 38a #8-05 Barrio 6ta Etapa Esperanza',
    schedule: 'Martes: 9:00 - 17:00',
    coordinates: const LatLng(4.1485, -73.6180), // Ficticio
    snippet: 'Martes: 9:00 AM - 5:00 PM',
  ),
  LocationPoint(
    name: 'Eco Granel Centro (Miércoles y Jueves)',
    address: 'Cra. 33 #40-44 Barrio Centro',
    schedule: 'Miércoles: 9:00 - 17:00',
    coordinates: const LatLng(4.1420, -73.6262), // Ficticio
    snippet: 'Miércoles: 9:00 AM - 5:00 PM',
  ),
  LocationPoint(
    name: 'Eco Granel Centro (Miércoles y Jueves)',
    address: 'Cra. 33 #40-44 Barrio Centro',
    schedule: 'Jueves: 9:00 - 17:00',
    coordinates: const LatLng(
      4.1425,
      -73.6265,
    ), // Ficticio (ligeramente diferente para evitar superposición)
    snippet: 'Jueves: 9:00 AM - 5:00 PM',
  ),
  LocationPoint(
    name: 'Eco Granel Caudal (Viernes)',
    address: 'Cra. 30 # 47B-96 Barrio Caudal',
    schedule: 'Viernes: 9:00 - 17:00',
    coordinates: const LatLng(4.1500, -73.6090), // Ficticio
    snippet: 'Viernes: 9:00 AM - 5:00 PM',
  ),
];

// --- 2. Conversión a StatefulWidget ---

class UbicacionesScreen extends StatefulWidget {
  const UbicacionesScreen({super.key});

  @override
  State<UbicacionesScreen> createState() => _UbicacionesScreenState();
}

class _UbicacionesScreenState extends State<UbicacionesScreen> {
  GoogleMapController? _mapController;
  final Set<Marker> _markers = {};

  // Posición inicial de la cámara (Villavicencio, Meta)
  static const CameraPosition _initialCameraPosition = CameraPosition(
    target: LatLng(4.14197, -73.62615),
    zoom: 13.0,
  );

  @override
  void initState() {
    super.initState();
    // Generar los marcadores a partir de la lista de ubicaciones
    _setMarkers();
  }

  void _setMarkers() {
    // Usamos setState para asegurar que el mapa se reconstruya con los marcadores
    setState(() {
      _markers.addAll(
        _mobileLocations.map((location) {
          return Marker(
            markerId: MarkerId(location.name),
            position: location.coordinates,
            infoWindow: InfoWindow(
              title: location.name,
              snippet: location.snippet,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
          );
        }).toSet(),
      );
    });
  }

  // Widget de Tarjeta de Horario (Se movió a la clase State para usar las constantes)
  Widget _buildScheduleCard({
    required String day,
    required String address,
    required String location,
    required String time,
  }) {
    // Encuentra las coordenadas para este día para un potencial uso futuro (como ir al mapa)
    final locationData = _mobileLocations.firstWhere(
      (loc) => loc.schedule.startsWith(day),
      orElse: () => _mobileLocations.first, // Fallback
    );

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 6.0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: BorderSide(color: Colors.grey.shade300, width: 0.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        // Se reemplaza el Row principal por un Column para apilar los elementos
        child: Row(
          // <-- Mantenemos el Row para dividir la info de texto del icono/hora
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                // <-- Columna principal para la información de texto
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
                      color: _unselectedDarkColor,
                      fontFamily: "roboto",
                    ),
                  ),
                  // Se añade un contenedor con el icono debajo de la dirección/ubicación
                  const SizedBox(
                    height: 8,
                  ), // Espacio entre texto y el icono de ubicación
                  // Contenedor para el icono de ubicación (ahora debajo de la hora)
                  Row(
                    // Usamos un Row si queremos alinear la hora y el icono horizontalmente
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        // La hora se mantiene aquí para estar junto al icono (pero visualmente debajo de la dirección)
                        time,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: _primaryGreen,
                          fontFamily: "roboto",
                        ),
                      ),
                      // Opcional: Agregar un botón para centrar el mapa en la ubicación
                      IconButton(
                        icon: const Icon(
                          Icons.location_on,
                          color: _primaryGreen,
                          size: 26,
                        ),
                        onPressed: () {
                          _mapController?.animateCamera(
                            CameraUpdate.newLatLngZoom(
                              locationData.coordinates,
                              15.0,
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Se elimina el Text del 'time' y el IconButton que estaban al lado del Expanded

            // Eliminamos el siguiente bloque para mover la hora y el botón dentro del Expanded
            /*
            Text(
              time,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: _primaryGreen,
                fontFamily: "roboto",
              ),
            ),
            // Opcional: Agregar un botón para centrar el mapa en la ubicación
            IconButton(
              icon: const Icon(
                Icons.location_on,
                color: _primaryGreen,
                size: 40,
              ),
              onPressed: () {
                _mapController?.animateCamera(
                  CameraUpdate.newLatLngZoom(locationData.coordinates, 15.0),
                );
              },
            ),
          */
          ],
        ),
      ),
    );
  }

  // --- 3. Implementación del `build` con el GoogleMap ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleSpacing: 0.0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            size: 30,
            color: _unselectedDarkColor,
          ),
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
            fontSize: 20,
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
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.asset(
                    'assets/images/carro.JPG',
                    fit: BoxFit.cover,
                    width: double.infinity,
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
                  color: _primaryGreen,
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

            // --- 4. Reemplazo del Widget de Imagen por GoogleMap ---
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.0),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                height: 300, // Altura fija para el mapa
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: GoogleMap(
                    mapType: MapType.normal,
                    initialCameraPosition: _initialCameraPosition,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
                    markers: _markers, // Cargamos el Set de Markers
                    zoomControlsEnabled: true,
                    mapToolbarEnabled: false,
                  ),
                ),
              ),
            ),

            // ------------------------------------------------------------------
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
            // Tarjetas de Horario (usando las coordenadas definidas en _mobileLocations)
            _buildScheduleCard(
              day: 'Lunes',
              address: 'Cra. 33 #40-01 Barrio Villa Bolívar',
              location: 'Parque Villa Bolívar - Villavicencio, Meta, Colombia',
              time: '9:00 - 17:00',
            ),
            _buildScheduleCard(
              day: 'Martes',
              address: 'Cra. 38a #8-05 Barrio 6ta Etapa Esperanza',
              location: 'Villavicencio, Meta, Colombia',
              time: '9:00 - 17:00',
            ),
            _buildScheduleCard(
              day: 'Miércoles',
              address: 'Cra. 33 #40-44 Barrio Centro',
              location:
                  'Plaza los Libertadores - Villavicencio, Meta, Colombia',
              time: '9:00 - 17:00',
            ),
            _buildScheduleCard(
              day: 'Jueves',
              address: 'Cra. 33 #40-44 Barrio Centro',
              location:
                  'Plaza los Libertadores - Villavicencio, Meta, Colombia',
              time: '9:00 - 17:00',
            ),
            _buildScheduleCard(
              day: 'Viernes',
              address: 'Cra. 30 # 47B-96 Barrio Caudal',
              location:
                  'Parque Ambiental Urbano 1 - Villavicencio, Meta, Colombia',
              time: '9:00 - 17:00',
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

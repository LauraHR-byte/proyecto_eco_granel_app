import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
//import 'package:eco_granel_app/screens/tienda_screen.dart';

const Color _orangeColor = Color(0xFFC76939);

// 1. Modelo de Datos Simple para Pedido (Order) (Sin cambios)
class Order {
  final String id;
  final DateTime date;
  final double total;
  final String status;
  final int itemCount;

  Order({
    required this.id,
    required this.date,
    required this.total,
    required this.status,
    required this.itemCount,
  });

  // Factory para crear una instancia de Order desde un DocumentSnapshot de Firestore
  factory Order.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final Timestamp timestamp = data['date'] ?? Timestamp.now();
    final List items = data['items'] ?? [];

    return Order(
      id: doc.id,
      date: timestamp.toDate(),
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      status: data['status'] ?? 'Desconocido',
      itemCount: items.length,
    );
  }
}

// Colores definidos (mantenemos los de tu código anterior)
const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);

class PedidosScreen extends StatefulWidget {
  const PedidosScreen({super.key});

  @override
  State<PedidosScreen> createState() => _PedidosScreenState();
}

class _PedidosScreenState extends State<PedidosScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Stream para obtener los pedidos del usuario actual
  Stream<List<Order>> _ordersStream() {
    final userId = _auth.currentUser?.uid;

    if (userId == null) {
      // Devolver un Stream vacío si no hay usuario autenticado
      return Stream.value([]);
    }

    // Consulta de Firestore:
    // 1. Apunta a la colección 'orders'.
    // 2. Filtra por el 'userId' del usuario actual.
    // 3. Ordena por fecha de forma descendente (los más recientes primero).
    return _firestore
        .collection('orders')
        .where('userId', isEqualTo: userId)
        .orderBy('date', descending: true)
        .snapshots() // Obtiene un Stream de QuerySnapshots
        .map((snapshot) {
          // Mapea cada DocumentSnapshot a una instancia de Order
          return snapshot.docs.map((doc) => Order.fromFirestore(doc)).toList();
        });
  }

  // Función para navegar a TiendaScreen
  /*void _goToShop() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) =>
            const TiendaScreen(), // Navega a tu pantalla de tienda
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Mis Pedidos',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            fontFamily: "roboto",
            color: _unselectedDarkColor,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: _unselectedDarkColor, size: 30),
      ),

      // Uso de StreamBuilder para escuchar los cambios en los pedidos
      body: StreamBuilder<List<Order>>(
        stream: _ordersStream(),
        builder: (context, snapshot) {
          // Estado de Carga
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _primaryGreen),
            );
          }

          // Estado de Error
          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar pedidos: ${snapshot.error}'),
            );
          }

          // Estado Sin Datos
          final orders = snapshot.data;
          if (orders == null || orders.isEmpty) {
            return Align(
              // Cambiado de Center a Align para respetar el padding superior
              alignment: Alignment.topCenter,
              child: Padding(
                // AJUSTE SOLICITADO: Padding top a 20
                padding: const EdgeInsets.only(
                  top: 220.0,
                  left: 5.0,
                  right: 5.0,
                  bottom: 5.0,
                ),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min, // Ajusta la columna al contenido
                  children: [
                    // Icono de bolsa de compra
                    Icon(
                      Icons.shopping_bag_outlined,
                      size: 80,
                      color: _orangeColor,
                    ),
                    const SizedBox(
                      height: 24,
                    ), // Un poco de espacio tras el icono
                    // Texto principal
                    const Text(
                      'Aún no has realizado pedidos',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: "roboto",
                        fontWeight: FontWeight.bold,
                        color: _unselectedDarkColor,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Cuando realices una compra, podrás \ndarle seguimiento desde aquí.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                        fontFamily: "roboto",
                      ),
                    ),
                    const SizedBox(height: 28),
                    // *** BOTÓN "IR A LA TIENDA" ***
                    /*ElevatedButton.icon(
                      onPressed: _goToShop,
                      icon: const Icon(Icons.storefront_outlined, size: 24),
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'Ir a la Tienda',
                          style: TextStyle(fontSize: 20, fontFamily: "roboto"),
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: _primaryGreen,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 5,
                      ),
                    ),*/
                  ],
                ),
              ),
            );
          }

          // Estado con Datos (Lista de Pedidos)
          return ListView.builder(
            padding: const EdgeInsets.all(12.0),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _OrderCard(order: order);
            },
          );
        },
      ),
    );
  }
}

// Widget para mostrar un pedido individualmente (Sin cambios)
class _OrderCard extends StatelessWidget {
  // ... (El código de _OrderCard se mantiene sin cambios)
  final Order order;
  const _OrderCard({required this.order});

  // Función para obtener el color del estado
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'entregado':
        return Colors.green;
      case 'enviado':
        return Colors.blue;
      case 'pendiente':
      case 'procesando':
        return Colors.orange;
      case 'cancelado':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formato de fecha y moneda
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'es_ES', symbol: '€');

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Fila 1: ID y Fecha
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Pedido #${order.id.substring(0, 8).toUpperCase()}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: _unselectedDarkColor,
                  ),
                ),
                Text(
                  dateFormat.format(order.date),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
            const Divider(height: 16),

            // Fila 2: Estado y Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Estado:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      order.status,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: _getStatusColor(order.status),
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    const Text(
                      'Total:',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      currencyFormat.format(order.total),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: _primaryGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Fila 3: Cantidad de artículos
            Text(
              '${order.itemCount} artículos en total',
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),

            // Botón para ver detalles (opcional)
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  // Implementar navegación a PedidoDetalleScreen
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Ver detalles del pedido ${order.id}'),
                    ),
                  );
                },
                child: const Text('Ver Detalles >'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

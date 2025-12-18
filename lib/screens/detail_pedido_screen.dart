import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);
const Color _darkTextColor = Color(0xFF333333);

class PedidoDetalleScreen extends StatelessWidget {
  final String orderId;

  const PedidoDetalleScreen({super.key, required this.orderId});

  String _formatCurrency(dynamic amount) {
    final formatter = NumberFormat('#,###', 'es_CO');
    int value = (amount is num) ? amount.toInt() : 0;
    String formattedNumber = formatter.format(value);
    return '\$$formattedNumber';
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd MMM yyyy, HH:mm');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Detalle del Pedido',
          style: TextStyle(
            fontSize: 20,
            color: _unselectedDarkColor,
            fontWeight: FontWeight.w600,
            fontFamily: "roboto",
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: _unselectedDarkColor, size: 30),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('orders')
            .doc(orderId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: _primaryGreen),
            );
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text("No se encontró la información del pedido."),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final List items = data['items'] ?? [];
          final address = data['shippingAddress'] ?? {};
          final Timestamp timestamp = data['date'] ?? Timestamp.now();
          final String status = data['status'] ?? 'Pendiente';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionCard(
                  child: Column(
                    children: [
                      _buildInfoRow(
                        "ID del Pedido",
                        "#${orderId.substring(0, 8).toUpperCase()}",
                      ),
                      _buildInfoRow(
                        "Fecha",
                        dateFormat.format(timestamp.toDate()),
                      ),
                      _buildInfoRow("Estado", status, isStatus: true),
                    ],
                  ),
                ),

                const SizedBox(height: 8),
                // --- TÍTULO PRODUCTOS CON PADDING ---
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.0),
                  child: Text(
                    "Productos",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _darkTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                ...items.map(
                  (item) => _OrderItemWidget(
                    item: item,
                    formatCurrency: _formatCurrency,
                  ),
                ),

                const SizedBox(height: 24),
                // --- TÍTULO INFORMACIÓN DE ENVÍO CON PADDING ---
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 14.0),
                  child: Text(
                    "Información de Envío",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: _darkTextColor,
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                _buildSectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['customerName'] ?? 'Cliente',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text("${address['direccion']}"),
                      Text("${address['barrio']}, ${address['ciudad']}"),
                      Text("Tel: ${address['telefono']}"),
                      if (address['extra'] != null &&
                          address['extra'].toString().isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Nota: ${address['extra']}",
                            style: const TextStyle(
                              fontStyle: FontStyle.italic,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
                const Divider(),
                // --- TOTAL PAGADO CON PADDING ---
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14.0),
                  child: _buildInfoRow(
                    "Total Pagado",
                    _formatCurrency(data['total'] ?? 0),
                    isTotal: true,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }

  // Los métodos _buildSectionCard, _buildInfoRow y la clase _OrderItemWidget se mantienen igual
  Widget _buildSectionCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _buildInfoRow(
    String label,
    String value, {
    bool isStatus = false,
    bool isTotal = false,
  }) {
    Color valueColor = _unselectedDarkColor;
    if (isStatus) {
      valueColor = (value.toLowerCase() == 'cancelado')
          ? Colors.red
          : _primaryGreen;
    } else if (isTotal) {
      valueColor = _primaryGreen;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: isTotal ? 18 : 14,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: isTotal ? 22 : 14,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

// ... (Clase _OrderItemWidget se mantiene igual que en tu código original)
class _OrderItemWidget extends StatelessWidget {
  final Map<String, dynamic> item;
  final String Function(dynamic) formatCurrency;

  const _OrderItemWidget({required this.item, required this.formatCurrency});

  @override
  Widget build(BuildContext context) {
    final String imagePath = item['imagePath'] ?? '';
    final int quantity = item['quantity'] ?? 0;
    final num unitPrice = item['unitPrice'] ?? 0;
    final String weightUnit = item['weightUnit'] ?? '';

    return Card(
      color: Colors.grey.shade100,
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: Colors.grey.shade100),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 80,
                height: 80,
                child: imagePath.isEmpty
                    ? Container(
                        color: Colors.grey[50],
                        child: const Icon(
                          Icons.shopping_bag,
                          color: _primaryGreen,
                        ),
                      )
                    : imagePath.startsWith('http')
                    ? Image.network(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      )
                    : Image.asset(
                        imagePath,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) =>
                            const Icon(Icons.broken_image),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'] ?? 'Producto',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: _darkTextColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${formatCurrency(unitPrice)} / $weightUnit',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          'Cant: $quantity',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        formatCurrency(unitPrice * quantity),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _primaryGreen,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

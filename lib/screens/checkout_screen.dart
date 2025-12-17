import 'package:flutter/material.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';

const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);
//const Color _orangeColor = Color(0xFFC76939);

class CheckoutScreen extends StatefulWidget {
  final int subtotal;
  final int shipping;
  final int total;

  const CheckoutScreen({
    super.key,
    required this.subtotal,
    required this.shipping,
    required this.total,
  });

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _extraInfoController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _phoneController = TextEditingController();

  final String _selectedDepartamento = 'Meta';
  String? _selectedCiudad;
  bool _isLoading = true;

  final Map<String, List<String>> _colombiaData = {
    'Meta': [
      'Villavicencio',
      'Acacías',
      'Granada',
      'Puerto López',
      'Cumaral',
      'Restrepo',
    ],
  };

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists) {
          setState(() => _nameController.text = doc.data()?['fullName'] ?? '');
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _startMercadoPagoCheckout() async {
    if (_nameController.text.isEmpty ||
        _addressController.text.isEmpty ||
        _neighborhoodController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _selectedCiudad == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, completa todos los campos obligatorios'),
        ),
      );
      return;
    }

    try {
      final result = await FirebaseFunctions.instance
          .httpsCallable('createPreference')
          .call({
            'title': 'Compra App',
            'unit_price': widget.total,
            'payer_info': {
              'name': _nameController.text,
              'phone': _phoneController.text,
              'address': _addressController.text,
              'extra': _extraInfoController.text,
              'neighborhood': _neighborhoodController.text,
              'city': _selectedCiudad,
              'state': _selectedDepartamento,
              'country': 'Colombia',
            },
          });

      final String urlString = result.data['init_point'];
      if (!mounted) return;

      await launchUrl(
        Uri.parse(urlString),
        customTabsOptions: const CustomTabsOptions(showTitle: true),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: _unselectedDarkColor, size: 30),
        title: const Text(
          'Datos de Envío',
          style: TextStyle(
            color: _unselectedDarkColor,
            fontWeight: FontWeight.bold,
            fontFamily: 'roboto',
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildSectionTitle("Información Personal"),
            _buildTextField("Nombre completo", _nameController, Icons.person),
            const SizedBox(height: 10),
            _buildTextField(
              "Teléfono",
              _phoneController,
              Icons.phone,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 25),
            _buildSectionTitle("Ubicación"),

            _buildReadOnlyField("País", "Colombia", Icons.flag),
            const SizedBox(height: 10),

            _buildReadOnlyField("Departamento", "Meta", Icons.map),
            const SizedBox(height: 10),

            DropdownButtonFormField<String>(
              decoration: _inputDecoration("Ciudad", Icons.location_city),
              initialValue: _selectedCiudad,
              items: _colombiaData['Meta']!
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
              onChanged: (val) => setState(() => _selectedCiudad = val),
            ),

            const SizedBox(height: 25),
            _buildSectionTitle("Dirección"),
            _buildTextField(
              "Barrio",
              _neighborhoodController,
              Icons.grid_view_rounded,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              "Dirección (Ej: Calle 10 #20-30)",
              _addressController,
              Icons.home,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              "Apto, bloque, oficina",
              _extraInfoController,
              Icons.add_home_work_outlined,
            ),
            const SizedBox(height: 30),
            const Divider(),
            _buildPriceRow("Total a pagar", "\$ ${widget.total}"),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryGreen,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: _startMercadoPagoCheckout,
              child: const Text(
                'PROCEDER AL PAGO',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- MÉTODOS DE APOYO AJUSTADOS ---

  Widget _buildReadOnlyField(String label, String value, IconData icon) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: _inputDecoration(
        label,
        icon,
      ).copyWith(filled: true, fillColor: Colors.grey[200]),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: _primaryGreen, // Ajustado a Verde
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      // Bordes en color gris
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
      // Borde cuando el campo ESTÁ seleccionado (Focus)
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: _unselectedDarkColor),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      decoration: _inputDecoration(label, icon),
    );
  }

  Widget _buildPriceRow(String label, String price) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(
          price,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: _primaryGreen,
          ),
        ),
      ],
    );
  }
}

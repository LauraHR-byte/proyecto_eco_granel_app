import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_custom_tabs/flutter_custom_tabs.dart';
import 'package:http/http.dart'
    as http; // IMPORTANTE: Agregado para peticiones HTTP
import 'dart:convert'; // IMPORTANTE: Agregado para manejar JSON

const Color _primaryGreen = Color(0xFF4CAF50);
const Color _unselectedDarkColor = Color(0xFF333333);

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
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _extraInfoController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _acceptCommunications = false;
  String? _selectedCiudad;
  bool _isLoading = true;

  final Map<String, List<String>> _colombiaData = {
    'Meta': ['Villavicencio', 'Acacías', 'Cumaral', 'Restrepo'],
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
          final data = doc.data();
          setState(() {
            _nameController.text = data?['fullName'] ?? '';
            _emailController.text = data?['email'] ?? '';
          });
        }
      }
    } catch (e) {
      debugPrint("Error: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // --- MÉTODO ACTUALIZADO CON TU URL REAL ---
  Future<void> _startMercadoPagoCheckout() async {
    if (_nameController.text.isEmpty ||
        _emailController.text.isEmpty ||
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

    setState(() => _isLoading = true);

    try {
      // ESTA ES TU URL REAL CONFIRMADA EN TU TERMINAL
      final String functionUrl =
          'https://createpreference-mrllhfttqa-uc.a.run.app';

      final response = await http.post(
        Uri.parse(functionUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          "data": {
            // Obligatorio envolver en 'data' para Firebase v2
            "title": "Compra App Eco Granel",
            "unit_price": widget.total,
            "payer_info": {
              "name": _nameController.text,
              "email": _emailController.text,
              "phone": _phoneController.text,
              "city": _selectedCiudad,
            },
          },
        }),
      );

      if (response.statusCode == 200) {
        final decodedResponse = json.decode(response.body);

        // Extraemos el link de pago que generó tu función en el servidor
        final String urlString = decodedResponse['data']['init_point'];

        if (!mounted) return;

        // Abrimos Mercado Pago
        await launchUrl(
          Uri.parse(urlString),
          customTabsOptions: CustomTabsOptions(
            showTitle: true,
            colorSchemes: CustomTabsColorSchemes.defaults(
              toolbarColor: _primaryGreen,
            ),
          ),
        );
      } else {
        throw Exception("Error del servidor: ${response.body}");
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar con el pago: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: _primaryGreen),
              SizedBox(height: 20),
              Text(
                "Preparando tu pago...",
                style: TextStyle(color: _primaryGreen),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        iconTheme: const IconThemeData(color: _unselectedDarkColor, size: 30),
        title: const Text(
          'Datos de Envío',
          style: TextStyle(
            color: _unselectedDarkColor,
            fontWeight: FontWeight.bold,
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
              "Correo electrónico",
              _emailController,
              Icons.email,
              keyboard: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            _buildTextField(
              "Teléfono",
              _phoneController,
              Icons.phone,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 15),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  height: 24,
                  width: 24,
                  child: Checkbox(
                    value: _acceptCommunications,
                    activeColor: _primaryGreen,
                    onChanged: (bool? value) {
                      setState(() => _acceptCommunications = value ?? false);
                    },
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Acepto recibir comunicaciones por e-mail y WhatsApp respecto a mi pedido y novedades de la marca.',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                ),
              ],
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

  // --- MÉTODOS DE APOYO (SIN CAMBIOS) ---
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
          color: _primaryGreen,
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.grey[400]!),
      ),
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

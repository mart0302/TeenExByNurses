import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class PantallaInformacion extends StatefulWidget {
  final String? selectedHead;
  final String? selectedBody;
  final String? selectedOutfit;

  const PantallaInformacion({
    super.key,
    this.selectedHead,
    this.selectedBody,
    this.selectedOutfit,
  });

  @override
  State<PantallaInformacion> createState() => _PantallaInformacionState();
}

class _PantallaInformacionState extends State<PantallaInformacion> {
  // Controladores para los campos de texto
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _alturaController = TextEditingController();
  final _pesoController = TextEditingController();
  final _contacto1Controller = TextEditingController();
  final _telefono1Controller = TextEditingController();
  final _contacto2Controller = TextEditingController();
  final _telefono2Controller = TextEditingController();

  // Variables de estado
  String _genero = 'Masculino';
  DateTime _fechaNacimiento = DateTime(1987, 11, 23);
  int _edad = 0;
  double? _imc;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  @override
  void dispose() {
    // Limpiar todos los controladores
    _nombreController.dispose();
    _apellidoController.dispose();
    _alturaController.dispose();
    _pesoController.dispose();
    _contacto1Controller.dispose();
    _telefono1Controller.dispose();
    _contacto2Controller.dispose();
    _telefono2Controller.dispose();
    super.dispose();
  }

  Future<void> _cargarDatosUsuario() async {
    setState(() => _isLoading = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (!doc.exists) return;

      final data = doc.data()!;

      setState(() {
        _nombreController.text = data['nombre'] ?? '';
        _apellidoController.text = data['apellido'] ?? '';
        _genero = data['genero'] ?? 'Masculino';
        _alturaController.text = data['estatura'] ?? '';
        _pesoController.text = data['peso'] ?? '';
        _contacto1Controller.text = data['contacto1'] ?? '';
        _telefono1Controller.text = data['telefono1'] ?? '';
        _contacto2Controller.text = data['contacto2'] ?? '';
        _telefono2Controller.text = data['telefono2'] ?? '';

        if (data['fechaNacimiento'] != null) {
          _fechaNacimiento = DateTime.parse(data['fechaNacimiento']);
          _calcularEdad(_fechaNacimiento);
        }
      });

      _calcularIMC();
    } catch (e) {
      debugPrint('Error al cargar datos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al cargar información')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _calcularEdad(DateTime fecha) {
    final hoy = DateTime.now();
    int edad = hoy.year - fecha.year;
    if (hoy.month < fecha.month || (hoy.month == fecha.month && hoy.day < fecha.day)) {
      edad--;
    }
    setState(() {
      _edad = edad;
      _fechaNacimiento = fecha;
    });
  }

  void _calcularIMC() {
    final altura = double.tryParse(_alturaController.text) ?? 0;
    final peso = double.tryParse(_pesoController.text) ?? 0;

    if (altura > 0) {
      final imc = peso / pow(altura, 2);
      setState(() {
        _imc = double.parse(imc.toStringAsFixed(1));
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF004C91),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _fechaNacimiento) {
      _calcularEdad(picked);
    }
  }

  Future<void> _guardarCambios() async {
    if (_isSaving) return;

    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      // Validación básica
      if (_nombreController.text.trim().isEmpty ||
          _apellidoController.text.trim().isEmpty) {
        throw 'Nombre y apellido son requeridos';
      }

      final data = {
        'nombre': _nombreController.text.trim(),
        'apellido': _apellidoController.text.trim(),
        'genero': _genero,
        'estatura': _alturaController.text.trim(),
        'peso': _pesoController.text.trim(),
        'contacto1': _contacto1Controller.text.trim(),
        'telefono1': _telefono1Controller.text.trim(),
        'contacto2': _contacto2Controller.text.trim(),
        'telefono2': _telefono2Controller.text.trim(),
        'fechaNacimiento': _fechaNacimiento.toIso8601String(),
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .set(data, SetOptions(merge: true));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Información guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error al guardar: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.toString()),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final consumoAgua = _imc != null
        ? (35 * (double.tryParse(_pesoController.text) ?? 0)).round()
        : 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi información'),
        backgroundColor: const Color(0xFF004C91),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSeccion('Información Personal', [
              _buildCampoTexto('Nombres', _nombreController),
              _buildCampoTexto('Apellidos', _apellidoController),
              _buildDropdownGenero(),
              _buildCampoEdad(),
              _buildSelectorFecha(),
              _buildCampoTexto('Altura (m)', _alturaController,
                  onChanged: (_) => _calcularIMC(),
                  keyboardType: TextInputType.numberWithOptions(decimal: true)),
              _buildCampoTexto('Peso (kg)', _pesoController,
                  onChanged: (_) => _calcularIMC(),
                  keyboardType: TextInputType.numberWithOptions(decimal: true)),
              _buildInfoIMC(),
            ]),

            _buildSeccion('Hidratación', [
              _buildConsumoAgua(consumoAgua),
            ]),

            _buildSeccion('Contactos de Emergencia', [
              _buildCampoTexto('Nombre del contacto 1', _contacto1Controller),
              _buildCampoTexto('Teléfono del contacto 1', _telefono1Controller,
                  keyboardType: TextInputType.phone),
              _buildCampoTexto('Nombre del contacto 2', _contacto2Controller),
              _buildCampoTexto('Teléfono del contacto 2', _telefono2Controller,
                  keyboardType: TextInputType.phone),
            ]),

            const SizedBox(height: 24),
            _buildBotonGuardar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSeccion(String titulo, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF004C91),
            ),
          ),
        ),
        ...children,
        const Divider(height: 32),
      ],
    );
  }

  Widget _buildCampoTexto(String label, TextEditingController controller, {
    ValueChanged<String>? onChanged,
    TextInputType? keyboardType,
    bool enabled = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          filled: !enabled,
          fillColor: !enabled ? Colors.grey[200] : null,
        ),
        onChanged: onChanged,
        keyboardType: keyboardType,
        enabled: enabled,
      ),
    );
  }

  Widget _buildDropdownGenero() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: _genero,
        items: const [
          DropdownMenuItem(value: 'Masculino', child: Text('Masculino')),
          DropdownMenuItem(value: 'Femenino', child: Text('Femenino')),
          DropdownMenuItem(value: 'Otro', child: Text('Otro')),
        ],
        onChanged: (value) => setState(() => _genero = value!),
        decoration: const InputDecoration(
          labelText: 'Género',
          border: OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _buildCampoEdad() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: TextEditingController(text: '$_edad años'),
        decoration: InputDecoration(
          labelText: 'Edad',
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: Colors.grey[200],
        ),
        enabled: false,
      ),
    );
  }

  Widget _buildSelectorFecha() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fecha de nacimiento',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          InkWell(
            onTap: _seleccionarFecha,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('dd/MM/yyyy').format(_fechaNacimiento)),
                  const Icon(Icons.calendar_today, size: 20),
                ],
              ),
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Selecciona tu fecha de nacimiento para calcular tu edad',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoIMC() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.monitor_weight, color: Color(0xFF004C91)),
          const SizedBox(width: 8),
          Text(
            'IMC: ${_imc?.toStringAsFixed(1) ?? '--'}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 16),
          if (_imc != null) ...[
            Text(
              _getClasificacionIMC(_imc!),
              style: TextStyle(
                color: _getColorIMC(_imc!),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _getClasificacionIMC(double imc) {
    if (imc < 18.5) return 'Bajo peso';
    if (imc < 25) return 'Normal';
    if (imc < 30) return 'Sobrepeso';
    return 'Obesidad';
  }

  Color _getColorIMC(double imc) {
    if (imc < 18.5) return Colors.orange;
    if (imc < 25) return Colors.green;
    if (imc < 30) return Colors.orange;
    return Colors.red;
  }

  Widget _buildConsumoAgua(int ml) {
    return Row(
      children: [
        Image.asset('assets/agua.png', width: 48),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Consumo diario recomendado de agua',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '$ml ml/día (aprox. ${(ml / 250).round()} vasos)',
                style: const TextStyle(color: Colors.blue, fontSize: 16),
              ),
              const SizedBox(height: 4),
              const Text(
                'Basado en tu peso actual (35ml por kg)',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBotonGuardar() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _guardarCambios,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF004C91),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isSaving
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: Colors.white,
          ),
        )
            : const Text(
          'GUARDAR CAMBIOS',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
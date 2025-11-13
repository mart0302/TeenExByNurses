import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'contrasena.dart';

class NombreUsuarioScreen extends StatefulWidget {
  final String email;
  final String selectedEdad;
  final String selectedPeso;
  final String selectedEstatura;
  final String selectedGenero;
  final String selectedHead;
  final String selectedBody;
  final String selectedOutfit;

  const NombreUsuarioScreen({
    Key? key,
    required this.email,
    required this.selectedEdad,
    required this.selectedPeso,
    required this.selectedEstatura,
    required this.selectedGenero,
    required this.selectedHead,
    required this.selectedBody,
    required this.selectedOutfit,
  }) : super(key: key);

  @override
  _NombreUsuarioScreenState createState() => _NombreUsuarioScreenState();
}

class _NombreUsuarioScreenState extends State<NombreUsuarioScreen> {
  final TextEditingController _usernameController = TextEditingController();
  bool _isValid = false;
  bool _checkingUsername = false;

  void _validateUsername(String value) {
    setState(() {
      _isValid = value.trim().length >= 4;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004C91),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Elige tu nombre de usuario',
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              Center(child: _buildAvatar()),
              const SizedBox(height: 32),
              _buildUsernameField(),
              const SizedBox(height: 32),
              _buildContinueButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return SizedBox(
      width: 160,
      height: 280,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 110,
            child: Image.asset(widget.selectedOutfit, width: 100),
          ),
          Positioned(
            top: 64,
            child: Image.asset(widget.selectedBody, width: 100),
          ),
          Positioned(
            top: 0,
            child: Image.asset(widget.selectedHead, width: 100),
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameField() {
    return Row(
      children: [
        const Icon(Icons.edit, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _usernameController,
            onChanged: _validateUsername,
            style: const TextStyle(
              color: Colors.orange,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              hintText: 'Tu Usuario',
              hintStyle: const TextStyle(color: Colors.white70),
              border: const UnderlineInputBorder(),
              suffixIcon: _isValid
                  ? const Icon(Icons.check_circle, color: Colors.green)
                  : null,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      onPressed: _isValid && !_checkingUsername ? _checkUsernameAndContinue : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E88E5),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _checkingUsername
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
      )
          : const Text(
        'Continuar',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Future<void> _checkUsernameAndContinue() async {
    final username = _usernameController.text.trim();

    setState(() {
      _checkingUsername = true;
    });

    try {
      final query = await FirebaseFirestore.instance
          .collection('usuarios')
          .where('nombre_usuario', isEqualTo: username)
          .get();

      if (query.docs.isNotEmpty) {
        _showUsernameExistsDialog();
      } else {
        final datosUsuario = {
          'correo': widget.email,
          'selectedEdad': widget.selectedEdad,
          'selectedPeso': widget.selectedPeso,
          'selectedEstatura': widget.selectedEstatura,
          'selectedGenero': widget.selectedGenero,
          'nombre_usuario': username,
          'selectedHead': widget.selectedHead,
          'selectedBody': widget.selectedBody,
          'selectedOutfit': widget.selectedOutfit,
        };

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ContrasenaScreen(datosUsuario: datosUsuario),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog("Ocurrió un error al verificar el nombre de usuario.");
    } finally {
      setState(() {
        _checkingUsername = false;
      });
    }
  }

  void _showUsernameExistsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Nombre de usuario no disponible"),
        content: const Text("Ese nombre ya está en uso. Intenta con otro."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }
}

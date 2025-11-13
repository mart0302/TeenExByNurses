import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'nombre_usuario.dart';
import '../iniciosesion/inisesion.dart';

class CorreoScreen extends StatefulWidget {
  final String selectedHead;
  final String selectedBody;
  final String selectedOutfit;
  final String selectedGenero;
  final String selectedEdad;
  final String selectedEstatura;
  final String selectedPeso;

  const CorreoScreen({
    super.key,
    required this.selectedHead,
    required this.selectedBody,
    required this.selectedOutfit,
    required this.selectedGenero,
    required this.selectedEdad,
    required this.selectedEstatura,
    required this.selectedPeso,
  });

  @override
  State<CorreoScreen> createState() => _CorreoScreenState();
}

class _CorreoScreenState extends State<CorreoScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _isValidEmail = false;
  bool _isChecking = false;

  void _validateEmail(String value) {
    const pattern = r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$";
    final regex = RegExp(pattern);
    setState(() {
      _isValidEmail = regex.hasMatch(value.trim());
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
                  '¿Cuál es tu correo electrónico?',
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
              _buildEmailField(),
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

  Widget _buildEmailField() {
    return Row(
      children: [
        const Icon(Icons.email, color: Colors.white),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            controller: _controller,
            onChanged: _validateEmail,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.done,
            style: const TextStyle(color: Colors.orange, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Tu correo electrónico',
              hintStyle: const TextStyle(color: Colors.white70),
              border: const UnderlineInputBorder(),
              suffixIcon: _isValidEmail
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
      onPressed: _isValidEmail && !_isChecking ? _checkEmailAndContinue : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E88E5),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: _isChecking
          ? const SizedBox(
        height: 20,
        width: 20,
        child: CircularProgressIndicator(
          color: Colors.white,
          strokeWidth: 2,
        ),
      )
          : const Text(
        'Continuar',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    );
  }

  Future<void> _checkEmailAndContinue() async {
    final email = _controller.text.trim();

    if (!_isValidEmail) return;

    setState(() {
      _isChecking = true;
    });

    try {
      final methods =
      await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);

      if (methods.isNotEmpty) {
        _showEmailExistsDialog();
      } else {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NombreUsuarioScreen(
              selectedHead: widget.selectedHead,
              selectedBody: widget.selectedBody,
              selectedOutfit: widget.selectedOutfit,
              selectedGenero: widget.selectedGenero,
              selectedEdad: widget.selectedEdad,
              selectedEstatura: widget.selectedEstatura,
              selectedPeso: widget.selectedPeso,
              email: email,
            ),
          ),
        );
      }
    } catch (e) {
      _showErrorDialog("Error al verificar el correo. Inténtalo nuevamente.");
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  void _showEmailExistsDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Correo ya registrado"),
        content: const Text("Ese correo ya está en uso. ¿Quieres iniciar sesión?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const InisesionScreen()),
              );
            },
            child: const Text("Ir a iniciar sesión"),
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
    _controller.dispose();
    super.dispose();
  }
}

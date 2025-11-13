import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class OlvidarContraScreen extends StatefulWidget {
  const OlvidarContraScreen({super.key});

  @override
  State<OlvidarContraScreen> createState() => _OlvidarContraScreenState();
}

class _OlvidarContraScreenState extends State<OlvidarContraScreen> {
  final TextEditingController _correoController = TextEditingController();
  bool _enviando = false;

  Future<void> _enviarRecuperacion() async {
    final correo = _correoController.text.trim();
    if (correo.isEmpty) {
      _mostrarMensaje('Por favor ingresa tu correo electrónico', isError: true);
      return;
    }

    setState(() => _enviando = true);

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: correo);
      _mostrarMensaje('Correo de recuperación enviado. Revisa tu bandeja de entrada.');
    } on FirebaseAuthException catch (e) {
      String msg = 'Error al enviar correo de recuperación';
      if (e.code == 'user-not-found') msg = 'No se encontró una cuenta con ese correo';
      _mostrarMensaje(msg, isError: true);
    } catch (e) {
      _mostrarMensaje('Ocurrió un error: ${e.toString()}', isError: true);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _mostrarMensaje(String mensaje, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  void dispose() {
    _correoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        backgroundColor: const Color(0xFF004C91),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Ingresa tu correo y te enviaremos un enlace para restablecer tu contraseña.',
              style: TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _correoController,
              decoration: InputDecoration(
                labelText: 'Correo electrónico',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _enviando ? null : _enviarRecuperacion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.lightGreen,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: _enviando
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text(
                'Enviar enlace',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

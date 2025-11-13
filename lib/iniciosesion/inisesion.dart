import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../principal/bienvenida_screen.dart';
import '../iniciosesion/olvidarcontra.dart'; // Asegúrate de que esta ruta sea correcta

class InisesionScreen extends StatefulWidget {
  const InisesionScreen({super.key});

  @override
  State<InisesionScreen> createState() => _InisesionScreenState();
}

class _InisesionScreenState extends State<InisesionScreen> {
  final TextEditingController _usuarioController = TextEditingController();
  final TextEditingController _contrasenaController = TextEditingController();
  bool _ocultarContrasena = true;
  bool _cargando = false;

  @override
  void dispose() {
    _usuarioController.dispose();
    _contrasenaController.dispose();
    super.dispose();
  }

  Future<void> _iniciarSesion() async {
    final input = _usuarioController.text.trim();
    final password = _contrasenaController.text.trim();

    if (input.isEmpty || password.isEmpty) {
      _mostrarError("Por favor ingresa correo o usuario y contraseña");
      return;
    }

    setState(() => _cargando = true);

    try {
      String correo = input;

      if (!input.contains('@')) {
        final query = await FirebaseFirestore.instance
            .collection('usuarios')
            .where('nombre_usuario', isEqualTo: input)
            .limit(1)
            .get();

        if (query.docs.isEmpty) throw Exception("Usuario no encontrado");

        correo = query.docs.first.data()['correo'];
      }

      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: correo,
        password: password,
      );

      final uid = cred.user!.uid;
      final doc = await FirebaseFirestore.instance.collection('usuarios').doc(uid).get();

      if (!doc.exists) throw Exception("Datos no encontrados");

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const BienvenidaScreen(),
        ),
      );
    } on FirebaseAuthException catch (e) {
      String msg = 'Error al iniciar sesión';
      if (e.code == 'user-not-found') msg = 'Usuario no encontrado';
      if (e.code == 'wrong-password') msg = 'Contraseña incorrecta';
      _mostrarError(msg);
    } catch (e) {
      _mostrarError("Error: ${e.toString()}");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3F2FD),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Container(
                width: 120,
                height: 120,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: Image.asset('assets/logo.png', fit: BoxFit.contain),
                ),
              ),
            ),
            const SizedBox(height: 32),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInputField(
                    controller: _usuarioController,
                    label: 'Correo o nombre de usuario',
                    hintText: 'Correo electrónico',
                    isPassword: false,
                  ),
                  const SizedBox(height: 24),
                  _buildInputField(
                    controller: _contrasenaController,
                    label: 'Contraseña',
                    hintText: 'Contraseña',
                    isPassword: true,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _cargando ? null : _iniciarSesion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightGreen,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: _cargando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Iniciar', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const OlvidarContraScreen(),
                          ),
                        );
                      },
                      child: const Text(
                        'Recordar contraseña',
                        style: TextStyle(color: Color(0xFF004C91)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    required bool isPassword,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                offset: const Offset(0, 3),
                blurRadius: 6,
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? _ocultarContrasena : false,
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: hintText,
              suffixIcon: isPassword
                  ? IconButton(
                icon: Icon(
                  _ocultarContrasena ? Icons.visibility_off : Icons.visibility,
                  color: Colors.grey,
                ),
                onPressed: () => setState(() => _ocultarContrasena = !_ocultarContrasena),
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
      ],
    );
  }
}

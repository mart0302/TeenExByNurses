import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_enfermeria/principal/bienvenida_screen.dart';

class ContrasenaScreen extends StatefulWidget {
  final Map<String, dynamic> datosUsuario;

  const ContrasenaScreen({
    Key? key,
    required this.datosUsuario,
  }) : super(key: key);

  @override
  _ContrasenaScreenState createState() => _ContrasenaScreenState();
}

class _ContrasenaScreenState extends State<ContrasenaScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repeatController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _cargando = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void dispose() {
    _passwordController.dispose();
    _repeatController.dispose();
    super.dispose();
  }

  Future<void> _registrarUsuario() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _cargando = true);

    try {
      final email = widget.datosUsuario['correo'];
      final password = _passwordController.text.trim();

      final String headAsset = widget.datosUsuario['selectedHead'];
      final String bodyAsset = widget.datosUsuario['selectedBody'];
      final String outfitAsset = widget.datosUsuario['selectedOutfit'];

      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user!;

      final datos = {
        'uid': user.uid,
        'correo': email,
        'edad': widget.datosUsuario['selectedEdad'],
        'estatura': widget.datosUsuario['selectedEstatura'],
        'peso': widget.datosUsuario['selectedPeso'],
        'genero': widget.datosUsuario['selectedGenero'],
        'nombre_usuario': widget.datosUsuario['nombre_usuario'],
        'head': headAsset,
        'body': bodyAsset,
        'outfit': outfitAsset,
        'fecha_registro': FieldValue.serverTimestamp(),
      };

      await _firestore.collection('usuarios').doc(user.uid).set(datos);

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => const BienvenidaScreen(), // ← Ya no se pasan los assets
        ),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      _mostrarError(_traducirError(e.code));
    } catch (e) {
      _mostrarError("Error durante el registro");
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  void _mostrarError(String mensaje) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  String _traducirError(String codigo) {
    switch (codigo) {
      case 'email-already-in-use':
        return "El correo ya está registrado";
      case 'invalid-email':
        return "Correo no válido";
      case 'weak-password':
        return "Contraseña muy débil";
      default:
        return "Error de registro";
    }
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
            child: Image.asset(widget.datosUsuario['selectedOutfit'], width: 100),
          ),
          Positioned(
            top: 64,
            child: Image.asset(widget.datosUsuario['selectedBody'], width: 100),
          ),
          Positioned(
            top: 0,
            child: Image.asset(widget.datosUsuario['selectedHead'], width: 100),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004C91),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  'Crea tu contraseña',
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Center(child: _buildAvatar()),
              const SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.orange),
                      decoration: const InputDecoration(
                        labelText: "Contraseña",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Ingresa una contraseña";
                        if (value.length < 6) return "Mínimo 6 caracteres";
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _repeatController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.orange),
                      decoration: const InputDecoration(
                        labelText: "Repetir contraseña",
                        labelStyle: TextStyle(color: Colors.white),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.white70),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.orange),
                        ),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) return "Repite tu contraseña";
                        if (value != _passwordController.text) return "Las contraseñas no coinciden";
                        return null;
                      },
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _cargando ? null : _registrarUsuario,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _cargando
                          ? const CircularProgressIndicator(color: Color(0xFF004C91))
                          : const Text(
                        "Registrarse",
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF004C91),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

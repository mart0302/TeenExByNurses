import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../principal/home_screen.dart';

class BienvenidaScreen extends StatefulWidget {
  const BienvenidaScreen({super.key});

  @override
  State<BienvenidaScreen> createState() => _BienvenidaScreenState();
}

class _BienvenidaScreenState extends State<BienvenidaScreen> {
  String head = '';
  String body = '';
  String outfit = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAvatar();
  }

  Future<void> _loadAvatar() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final doc = await FirebaseFirestore.instance.collection('usuarios').doc(user.uid).get();
    final data = doc.data();
    if (data != null) {
      setState(() {
        head = data['head'] ?? '';
        body = data['body'] ?? '';
        outfit = data['outfit'] ?? '';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black.withOpacity(0.6),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: isLoading
              ? const CircularProgressIndicator()
              : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                '¡Tu Ayuda Es Clave!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
              ),
              const SizedBox(height: 8),
              const Text(
                'Al usar esta aplicación, estás contribuyendo a la promoción de estrategias de salud innovadoras basadas en IE. '
                    'Tu participación es fundamental para mejorar el acceso a información de calidad sobre salud y bienestar.\n',
              ),
              const Text(
                'Juntos y juntas\nhacemos la diferencia',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              _buildAvatar(head, body, outfit),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.lightGreen.shade400,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'ENTENDIDO',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(String head, String body, String outfit) {
    return SizedBox(
      width: 160,
      height: 280,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: 110,
            child: Image.asset(outfit, width: 100),
          ),
          Positioned(
            top: 64,
            child: Image.asset(body, width: 100),
          ),
          Positioned(
            top: 0,
            child: Image.asset(head, width: 100),
          ),
        ],
      ),
    );
  }
}

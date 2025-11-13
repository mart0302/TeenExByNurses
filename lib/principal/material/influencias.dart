import 'package:flutter/material.dart';

class InfluenciasScreen extends StatelessWidget {
  const InfluenciasScreen({super.key});

  void _mostrarDialogo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF7FAFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text(
            'Influencias sociales y familiares/Tecnologías y actividad física',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF004C91),
              fontSize: 18,
            ),
          ),
        ),
        content: const SingleChildScrollView(
          child: Text(
            '''Las recomendaciones de amigos y familiares que practican ejercicio influyen positivamente en mi motivación para lucir bien físicamente al hacer ejercicio.

Cuando mi familia no apoya mi deseo de hacer ejercicio, puede resultar difícil mantener la motivación.

La influencia de las redes sociales afecta cómo percibo mi apariencia y cómo me siento.''',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        actions: [
          Center(
            child: IconButton(
              icon: const Icon(Icons.check_circle, size: 36, color: Colors.green),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE6F0FA),
      appBar: AppBar(
        title: const Text('Influencias'),
        backgroundColor: const Color(0xFF004C91),
        leading: const BackButton(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Image.asset('assets/influencias_banner.png', height: 180), // Puedes reemplazar por otra imagen
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _mostrarDialogo(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: const Color(0xFF004C91),
                side: const BorderSide(color: Color(0xFF004C91)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              ),
              child: const Text(
                'Ver influencias sociales, familiares y tecnología',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }
}

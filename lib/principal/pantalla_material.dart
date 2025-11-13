import 'package:flutter/material.dart';
import 'material/sedentarismo.dart';
import 'material/diferencias.dart';

class PantallaMaterial extends StatelessWidget {
  const PantallaMaterial({super.key});

  void _mostrarDialogoInfluencias(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF7FAFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Center(
          child: Text(
            'Influencias sociales y familiares / Tecnologías y actividad física',
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
      appBar: AppBar(
        title: const Text(
          'Material Educativo',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        backgroundColor: const Color(0xFF004C91),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 4,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE6F0FA), Color(0xFFF5F9FD)],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            children: [
              _buildMaterialCard(
                context: context,
                title: 'Sedentarismo y riesgo para la salud',
                subtitle: 'Conoce los peligros de la inactividad física',
                icon: Icons.health_and_safety,
                onTap: () => _navigateToScreen(context, const SedentarismoScreen()),
              ),
              const SizedBox(height: 16),
              _buildMaterialCard(
                context: context,
                title: 'Diferencia entre actividad física y ejercicio',
                subtitle: 'Hábitos de rutinas y ejercicio saludable',
                icon: Icons.directions_run,
                onTap: () => _navigateToScreen(context, const DiferenciasScreen()),
              ),
              const SizedBox(height: 16),
              _buildMaterialCard(
                context: context,
                title: 'Influencias sociales y familiares',
                subtitle: 'Tecnologías y actividad física',
                icon: Icons.group,
                onTap: () => _mostrarDialogoInfluencias(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMaterialCard({
    required BuildContext context,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF004C91).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 28, color: const Color(0xFF004C91)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: Color(0xFF004C91),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF004C91)),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToScreen(BuildContext context, Widget screen) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => screen,
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const begin = Offset(1.0, 0.0);
          const end = Offset.zero;
          const curve = Curves.easeInOut;
          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
          return SlideTransition(position: animation.drive(tween), child: child);
        },
      ),
    );
  }
}

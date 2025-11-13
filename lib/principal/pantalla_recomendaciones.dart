import 'package:flutter/material.dart';

class PantallaRecomendaciones extends StatelessWidget {
  const PantallaRecomendaciones({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildBody(context),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text(
        'Recomendaciones de Actividad Física',
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18, // Tamaño más adecuado para título
        ),
      ),
      backgroundColor: AppColors.primary,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
      centerTitle: true,
      elevation: 4,
      actions: [
        IconButton(
          icon: const Icon(Icons.info_outline),
          onPressed: () => _showAppInfo(context),
          tooltip: 'Información', // Mejor accesibilidad
        ),
      ],
    );
  }

  Widget _buildBody(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: AppColors.backgroundGradient,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildPlanCard(),
            const SizedBox(height: 16),
            Expanded(
              child: _buildRecommendationsList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Plan de 10 semanas',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '5 veces por semana • Comienza con 20 min • Aumenta a 40 min después de la 7ma semana\n\nReferencia: Landeros et al., 2022',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[700],
                height: 1.4, // Mejor interlineado
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationsList() {
    return ListView.separated(
      itemCount: recomendacionesPorEdad.entries.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final entry = recomendacionesPorEdad.entries.elementAt(index);
        return _buildAgeCategory(
          context,
          entry.key,
          _getCategoryIcon(entry.key),
          entry.value,
        );
      },
    );
  }

  IconData _getCategoryIcon(String category) {
    if (category.contains('Adolescentes')) {
      return Icons.emoji_people;
    } else if (category.contains('65')) {
      return Icons.accessible_forward;
    }
    return Icons.directions_run;
  }

  Widget _buildAgeCategory(
      BuildContext context,
      String title,
      IconData icon,
      List<Recommendation> recommendations,
      ) {
    return Card(
      margin: EdgeInsets.zero, // Mejor consistencia en el diseño
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showRecommendationsDialog(context, title, recommendations),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.primary, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.primary),
            ],
          ),
        ),
      ),
    );
  }

  void _showRecommendationsDialog(
      BuildContext context,
      String category,
      List<Recommendation> recommendations,
      ) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.all(16),
        child: RecommendationCarousel(title: category, recommendations: recommendations),
      ),
    );
  }

  void _showAppInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Información de la App',
          style: TextStyle(color: AppColors.primary),
        ),
        content: SingleChildScrollView(
          child: Text.rich(
            TextSpan(
              children: [
                const TextSpan(
                  text: 'Esta aplicación proporciona recomendaciones de actividad física basadas en:\n\n',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const TextSpan(
                  text: '- Recomendaciones mundiales sobre actividad física para la salud (Organización Mundial de la Salud, 2010).\n',
                ),
                const TextSpan(
                  text: '- Guía de dosis semanal sugerida para mujeres, adolescentes y adultos mayores (Landeros et al., 2022).\n',
                ),
                TextSpan(
                  text: '- Principios éticos y legales establecidos en la Constitución Política de los Estados Unidos Mexicanos, '
                      'la Ley General de Salud y la Ley Federal de Protección de Datos Personales en Posesión de los Particulares.',
                  style: TextStyle(color: Colors.grey[700]),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}

// Clase para manejar colores de manera consistente
class AppColors {
  static const Color primary = Color(0xFF004C91);
  static const List<Color> backgroundGradient = [
    Color(0xFFE6F0FA),
    Color(0xFFF5F9FD),
  ];
}

// Modelo para las recomendaciones
class Recommendation {
  final String title;
  final List<String> points;

  const Recommendation({required this.title, required this.points});
}

// Datos de recomendaciones (podría moverse a un archivo aparte)
final Map<String, List<Recommendation>> recomendacionesPorEdad = {
  'Adolescentes (hasta 17 años)': [
    Recommendation(
      title: 'Actividad diaria recomendada',
      points: [
        'Al menos 60 minutos de actividad moderada a intensa diariamente.',
        'La actividad física durante más de 60 minutos reporta beneficios adicionales para la salud.',
        'La actividad física diaria debería ser, en su mayor parte, aeróbica.',
        'Conviene incorporar actividades vigorosas, como mínimo tres veces a la semana.',
      ],
    ),
  ],
  'Adultos (18-64 años)': [
    Recommendation(
      title: 'Actividad aeróbica básica',
      points: [
        'Deberían acumular un mínimo de 150 minutos de AF aeróbica moderada.',
        'O 75 minutos semanales de actividad aeróbica vigorosa.',
        'O una combinación equivalente.',
        'La actividad aeróbica se realizará en sesiones de 10 minutos como mínimo.',
      ],
    ),
    Recommendation(
      title: 'Para mayores beneficios',
      points: [
        'Incrementar hasta 300 minutos de actividad aeróbica moderada.',
        'O 150 minutos de actividad aeróbica vigorosa.',
      ],
    ),
    Recommendation(
      title: 'Ejercicios de fuerza',
      points: [
        'Deberían realizar ejercicios de fortalecimiento muscular de los grandes grupos musculares dos o más días a la semana.',
      ],
    ),
  ],
  'Adultos mayores (65+ años)': [
    Recommendation(
      title: 'Actividad moderada con equilibrio',
      points: [
        'Actividad moderada + ejercicios de equilibrio para prevenir caídas.',
        '150 minutos moderada o 75 vigorosa o combinación equivalente.',
      ],
    ),
    Recommendation(
      title: 'Fortalecimiento muscular y adaptación por salud',
      points: [
        'Dos o más veces por semana fortalecer grandes grupos musculares.',
        'Si no pueden por salud, mantenerse activos hasta donde les sea posible.',
      ],
    ),
  ],
};

class RecommendationCarousel extends StatefulWidget {
  final String title;
  final List<Recommendation> recommendations;

  const RecommendationCarousel({
    super.key,
    required this.title,
    required this.recommendations,
  });

  @override
  State<RecommendationCarousel> createState() => _RecommendationCarouselState();
}

class _RecommendationCarouselState extends State<RecommendationCarousel> {
  late final PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 520,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              widget.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: AppColors.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.recommendations.length,
              onPageChanged: (index) => setState(() => _currentIndex = index),
              itemBuilder: (context, index) => RecommendationPage(
                recommendation: widget.recommendations[index],
              ),
            ),
          ),
          _buildPageIndicator(),
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: const Size(double.infinity, 48),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text('Cerrar', style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(
          widget.recommendations.length,
              (index) => AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 4),
            width: _currentIndex == index ? 16 : 8,
            height: 8,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(4),
              color: _currentIndex == index ? AppColors.primary : Colors.grey[300],
            ),
          ),
        ),
      ),
    );
  }
}

class RecommendationPage extends StatelessWidget {
  final Recommendation recommendation;

  const RecommendationPage({super.key, required this.recommendation});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            recommendation.title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ...recommendation.points.map(
                (point) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.circle, size: 8, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      point,
                      style: const TextStyle(fontSize: 14),
                      textAlign: TextAlign.start,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
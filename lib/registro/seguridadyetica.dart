import 'package:flutter/material.dart';
import 'elegir_avatar.dart';

class SeguridadEticaScreen extends StatefulWidget {
  const SeguridadEticaScreen({super.key});

  @override
  State<SeguridadEticaScreen> createState() => _SeguridadEticaScreenState();
}

class _SeguridadEticaScreenState extends State<SeguridadEticaScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.6, curve: Curves.easeInOut),
      ),
    );

    _slideAnimation = Tween<double>(begin: 50, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 1, curve: Curves.easeOut),
      ),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : const Color(0xFFDDEBF6),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20),
          child: Column(
            children: [
              FadeTransition(
                opacity: _fadeAnimation,
                child: Align(
                  alignment: Alignment.topLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back),
                    color: textColor,
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
              AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(0, _slideAnimation.value),
                    child: Opacity(
                      opacity: _fadeAnimation.value,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildAnimatedText(
                      text: 'Seguridad y Ética en el\nUso de la Aplicación',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                        height: 1.3,
                      ),
                      textAlign: TextAlign.center,
                      interval: const Interval(0.1, 0.5),
                    ),
                    const SizedBox(height: 30),

                    // ÍCONO ANIMADO CON CÍRCULO
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _controller.value > 0.4 ? 1 : 0,
                          child: Transform.scale(
                            scale: _controller.value > 0.4
                                ? 1 + (_controller.value - 0.4) * 0.1
                                : 0.8,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: isDarkMode ? Colors.grey[800] : Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.verified_user,
                          size: 60,
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    _buildAnimatedText(
                      text:
                      'Esta App ha sido diseñada con base en principios éticos y legales establecidos en la Constitución Política de los Estados Unidos Mexicanos (artículos: 4, 16 y 73), la Ley General de Salud (Título Segundo, Capítulo I, Artículo 14) y el Reglamento de la Ley General de Salud en Materia de Investigación para la Salud, en su actualización publicada en el Diario Oficial de la Federación en 2024 (Secretaría de Salud (SS), 2024).\n\nTu seguridad es nuestra prioridad. El uso de esta App no representa un riesgo para la salud y está orientado a motivar la actividad física.',
                      style: TextStyle(
                        fontSize: 14,
                        color: textColor.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.justify,
                      interval: const Interval(0.4, 0.8),
                    ),

                    const SizedBox(height: 30),

                    _buildAnimatedText(
                      text: 'Tu salud, tu decisión',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                      interval: const Interval(0.8, 1),
                    ),

                    const SizedBox(height: 30),

                    // BOTÓN CON ANIMACIÓN
                    AnimatedBuilder(
                      animation: _controller,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _controller.value > 0.85 ? 1 : 0,
                          child: Transform.scale(
                            scale: _controller.value > 0.85
                                ? 1 + (_controller.value - 0.85) * 0.1
                                : 0.9,
                            child: child,
                          ),
                        );
                      },
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                          shadowColor: Colors.green.withOpacity(0.3),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            PageRouteBuilder(
                              pageBuilder: (context, animation, secondaryAnimation) =>
                              const ElegirAvatarScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                final tween = Tween(begin: 0.0, end: 1.0).chain(
                                  CurveTween(curve: Curves.easeInOut),
                                );
                                return FadeTransition(
                                  opacity: animation.drive(tween),
                                  child: child,
                                );
                              },
                              transitionDuration: const Duration(milliseconds: 600),
                            ),
                          );
                        },
                        child: const Text(
                          'Siguiente',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedText({
    required String text,
    required TextStyle style,
    required Interval interval,
    TextAlign textAlign = TextAlign.left,
  }) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: interval.transform(_controller.value),
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - interval.transform(_controller.value))),
            child: child,
          ),
        );
      },
      child: Text(
        text,
        textAlign: textAlign,
        style: style,
      ),
    );
  }
}

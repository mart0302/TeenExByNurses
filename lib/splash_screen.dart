import 'package:flutter/material.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    _controller.forward();

    // Después de la animación, vamos a WelcomeScreen
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[900],
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return CustomPaint(
              painter: MPainter(progress: _animation.value),
              size: const Size(200, 200),
            );
          },
        ),
      ),
    );
  }
}

class MPainter extends CustomPainter {
  final double progress;
  MPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Dibujar una M cursiva simple usando líneas
    path.moveTo(size.width * 0.1, size.height * 0.8);
    path.lineTo(size.width * 0.3, size.height * 0.2);
    path.lineTo(size.width * 0.5, size.height * 0.8);
    path.lineTo(size.width * 0.7, size.height * 0.2);
    path.lineTo(size.width * 0.9, size.height * 0.8);

    // Extraer el PathMetrics para animar la escritura
    final pathMetrics = path.computeMetrics();
    final drawPath = Path();

    for (final metric in pathMetrics) {
      final length = metric.length * progress;
      drawPath.addPath(metric.extractPath(0, length), Offset.zero);
    }

    canvas.drawPath(drawPath, paint);

    // Opcional: agregar un círculo animado alrededor
    final circlePaint = Paint()
      ..color = Colors.blueAccent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      100 * progress,
      circlePaint,
    );
  }

  @override
  bool shouldRepaint(covariant MPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

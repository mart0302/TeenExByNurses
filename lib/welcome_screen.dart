import 'package:flutter/material.dart';
import '../registro/beneficios.dart';
import '../iniciosesion/inisesion.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mi Aplicación de Salud',
      theme: ThemeData(
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        pageTransitionsTheme: const PageTransitionsTheme(builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        }),
      ),
      home: const WelcomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('assets/logo.png'), context);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: const Color(0xFFDDEBF6),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 600),
              padding: EdgeInsets.all(isSmallScreen ? 24.0 : 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ScaleTransition(
                    scale: CurvedAnimation(
                      parent: _controller,
                      curve: Curves.elasticOut,
                    ),
                    child: FadeTransition(
                      opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
                        CurvedAnimation(
                          parent: _controller,
                          curve: const Interval(0.0, 0.3, curve: Curves.easeIn),
                        ),
                      ),
                      child: Container(
                        width: isSmallScreen ? 150 : 180,
                        height: isSmallScreen ? 150 : 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blue.withOpacity(0.2),
                              blurRadius: 20,
                              spreadRadius: 2,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          image: const DecorationImage(
                            image: AssetImage('assets/logo.png'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: isSmallScreen ? 40 : 60),

                  _buildAnimatedText(
                    start: 0.3,
                    end: 0.8,
                    text:
                    '¡Hola! 👋 Este va a ser el espacio para que aprendas a cuidar tu salud con actividad física',
                    isSmallScreen: isSmallScreen,
                    isBold: true,
                  ),
                  const SizedBox(height: 20),

                  _buildAnimatedText(
                    start: 0.4,
                    end: 0.9,
                    text:
                    'Te vamos a hacer algunas preguntas para personalizar tus registros y nuestras recomendaciones',
                    isSmallScreen: isSmallScreen,
                    isBold: false,
                  ),
                  SizedBox(height: isSmallScreen ? 40 : 60),

                  _buildAnimatedButton(
                    isSmallScreen: isSmallScreen,
                    onPressed: () {
                      Navigator.of(context).push(
                        PageRouteBuilder(
                          transitionDuration: const Duration(milliseconds: 500),
                          pageBuilder: (_, __, ___) =>
                          const BeneficiosScreen(),
                          transitionsBuilder: (_, animation, __, child) {
                            return FadeTransition(
                              opacity: animation,
                              child: SlideTransition(
                                position: Tween<Offset>(
                                  begin: const Offset(0, 0.1),
                                  end: Offset.zero,
                                ).animate(animation),
                                child: child,
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),

                  SizedBox(height: isSmallScreen ? 20 : 30),

                  _buildAccountText(
                    isSmallScreen: isSmallScreen,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const InisesionScreen(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedText({
    required double start,
    required double end,
    required String text,
    required bool isSmallScreen,
    bool isBold = false,
  }) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: Interval(
            start,
            (start + ((end - start) * 0.5)).clamp(0.0, 1.0),
            curve: Curves.easeIn,
          ),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.2),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _controller,
            curve: Interval(
              start,
              (start + ((end - start) * 0.7)).clamp(0.0, 1.0),
              curve: Curves.easeOut,
            ),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: isSmallScreen ? (isBold ? 18 : 16) : (isBold ? 20 : 18),
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            color: isBold ? Colors.grey[800] : Colors.grey[700],
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedButton({
    required bool isSmallScreen,
    required VoidCallback onPressed,
  }) {
    return ScaleTransition(
      scale: Tween<double>(begin: 0.7, end: 1.0).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.5, 0.8, curve: Curves.elasticOut),
        ),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4CAF50),
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: isSmallScreen ? 32 : 48,
            vertical: isSmallScreen ? 16 : 20,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 8,
          shadowColor: const Color(0xFF4CAF50).withOpacity(0.4),
          minimumSize: Size(
            isSmallScreen ? double.infinity : 300,
            50,
          ),
        ),
        onPressed: onPressed,
        child: const Text(
          '¡Empecemos!',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAccountText({
    required bool isSmallScreen,
    required VoidCallback onTap,
  }) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: _controller,
          curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
        ),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              'Ya tengo una cuenta',
              style: TextStyle(
                color: const Color(0xFF1976D2),
                fontSize: isSmallScreen ? 14 : 16,
                decoration: TextDecoration.underline,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

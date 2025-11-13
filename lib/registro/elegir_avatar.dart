import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart' show timeDilation;
import 'genero.dart';

class ElegirAvatarScreen extends StatefulWidget {
  const ElegirAvatarScreen({super.key});

  @override
  State<ElegirAvatarScreen> createState() => _ElegirAvatarScreenState();
}

class _ElegirAvatarScreenState extends State<ElegirAvatarScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  int headIndex = 0;
  int bodyIndex = 0;
  int outfitIndex = 0;
  bool _isAnimating = false;

  final List<String> heads = [
    'assets/avatar/cabeza1.png',
    'assets/avatar/cabeza2.png',
    'assets/avatar/cabeza3.png',
  ];

  final List<String> bodies = [
    'assets/avatar/cuerpo1.png',
    'assets/avatar/cuerpo2.png',
    'assets/avatar/cuerpo3.png',
  ];

  final List<String> outfits = [
    'assets/avatar/pies1.png',
    'assets/avatar/pies2.png',
    'assets/avatar/pies3.png',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.5, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.9, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 1, curve: Curves.elasticOut),
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
    return Scaffold(
      backgroundColor: const Color(0xFF004C91),
      body: SafeArea(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 10),

                  // Botón de regreso
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Título con FadeTransition
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Text(
                      'Elige tu avatar',
                      style: TextStyle(
                        fontSize: 28,
                        color: Colors.orange,
                        fontWeight: FontWeight.bold,
                        shadows: [
                          Shadow(
                            blurRadius: 4,
                            color: Colors.black45,
                            offset: Offset(1, 1),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Subtítulo con FadeTransition
                  FadeTransition(
                    opacity: _fadeAnimation,
                    child: const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
                      child: Text(
                        'Personaliza tu avatar como prefieras\nPuedes cambiarlo cuando quieras',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  _buildSectionTitle('Cabeza', 0.4),
                  _buildAvatarCarousel(heads, headIndex, (i) => _changeSelection('head', i)),

                  _buildSectionTitle('Cuerpo', 0.5),
                  _buildAvatarCarousel(bodies, bodyIndex, (i) => _changeSelection('body', i)),

                  _buildSectionTitle('Pies', 0.6),
                  _buildAvatarCarousel(outfits, outfitIndex, (i) => _changeSelection('outfit', i)),

                  const SizedBox(height: 20),

                  // Botón continuar con tamaño más compacto
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 6,
                      shadowColor: Colors.blue.withOpacity(0.4),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        PageRouteBuilder(
                          pageBuilder: (context, animation, secondaryAnimation) => GeneroScreen(
                            selectedHead: heads[headIndex],
                            selectedBody: bodies[bodyIndex],
                            selectedOutfit: outfits[outfitIndex],
                          ),
                          transitionsBuilder: (context, animation, secondaryAnimation, child) {
                            const begin = Offset(0.0, 1.0);
                            const end = Offset.zero;
                            const curve = Curves.easeInOutQuart;
                            var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                            return SlideTransition(
                              position: animation.drive(tween),
                              child: child,
                            );
                          },
                          transitionDuration: const Duration(milliseconds: 700),
                        ),
                      );
                    },
                    child: const Text(
                      'Continuar',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, double startInterval) {
    return AnimatedOpacity(
      opacity: _controller.value > startInterval ? 1 : 0,
      duration: const Duration(milliseconds: 300),
      child: Padding(
        padding: const EdgeInsets.only(top: 10, bottom: 5),
        child: Text(
          title,
          style: const TextStyle(
            color: Colors.orange,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _changeSelection(String type, int newIndex) async {
    if (_isAnimating) return;
    _isAnimating = true;

    setState(() {
      switch (type) {
        case 'head':
          headIndex = newIndex;
          break;
        case 'body':
          bodyIndex = newIndex;
          break;
        case 'outfit':
          outfitIndex = newIndex;
          break;
      }
    });

    await Future.delayed(const Duration(milliseconds: 200));
    _isAnimating = false;
  }

  Widget _buildAvatarCarousel(List<String> parts, int selectedIndex, Function(int) onChange) {
    int prevIndex = (selectedIndex - 1 + parts.length) % parts.length;
    int nextIndex = (selectedIndex + 1) % parts.length;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_left, size: 32, color: Colors.orange),
            onPressed: () => onChange(prevIndex),
          ),
          SizedBox(
            width: 240,
            height: 120,
            child: Stack(
              alignment: Alignment.center,
              children: [
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  alignment: const Alignment(-0.8, 0),
                  curve: Curves.easeOut,
                  child: GestureDetector(
                    onTap: () => onChange(prevIndex),
                    child: Opacity(
                      opacity: 0.5,
                      child: Image.asset(parts[prevIndex], width: 60, filterQuality: FilterQuality.high),
                    ),
                  ),
                ),
                AnimatedScale(
                  duration: const Duration(milliseconds: 200),
                  scale: _isAnimating ? 1.1 : 1.0,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.orange.withOpacity(0.8), width: 3),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 10,
                          spreadRadius: 2,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(parts[selectedIndex], width: 90, filterQuality: FilterQuality.high),
                    ),
                  ),
                ),
                AnimatedAlign(
                  duration: const Duration(milliseconds: 300),
                  alignment: const Alignment(0.8, 0),
                  curve: Curves.easeOut,
                  child: GestureDetector(
                    onTap: () => onChange(nextIndex),
                    child: Opacity(
                      opacity: 0.5,
                      child: Image.asset(parts[nextIndex], width: 60, filterQuality: FilterQuality.high),
                    ),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_right, size: 32, color: Colors.orange),
            onPressed: () => onChange(nextIndex),
          ),
        ],
      ),
    );
  }
}

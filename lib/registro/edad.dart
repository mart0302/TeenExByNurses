import 'package:flutter/material.dart';
import 'estatura.dart';

class EdadScreen extends StatefulWidget {
  final String selectedHead;
  final String selectedBody;
  final String selectedOutfit;
  final String selectedGenero;

  const EdadScreen({
    super.key,
    required this.selectedHead,
    required this.selectedBody,
    required this.selectedOutfit,
    required this.selectedGenero,
  });

  @override
  State<EdadScreen> createState() => _EdadScreenState();
}

class _EdadScreenState extends State<EdadScreen> {
  static const int _minEdad = 1;
  static const int _maxEdad = 120;
  static const int _edadInicial = 18;

  int _edad = _edadInicial;

  void _cambiarEdad(int cambio) {
    setState(() {
      _edad = (_edad + cambio).clamp(_minEdad, _maxEdad);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004C91),
      body: SafeArea(
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
                '¿Cuál es tu edad?',
                style: TextStyle(
                  fontSize: 26,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Avatar con medidas específicas (160x280)
            Center(
              child: SizedBox(
                width: 160,
                height: 280,
                child: Stack(
                  alignment: Alignment.topCenter,
                  clipBehavior: Clip.none,
                  children: [
                    // Pies (parte más baja)
                    Positioned(
                      top: 110,
                      child: Image.asset(
                        widget.selectedOutfit,
                        width: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Cuerpo (parte media)
                    Positioned(
                      top: 64,
                      child: Image.asset(
                        widget.selectedBody,
                        width: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                    // Cabeza (parte superior)
                    Positioned(
                      top: 0,
                      child: Image.asset(
                        widget.selectedHead,
                        width: 100,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Selector de edad mejorado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left, size: 36, color: Colors.orange),
                      onPressed: () => _cambiarEdad(-1),
                    ),

                    // Edades adyacentes
                    Text(
                      '${_edad - 1}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white54,
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Edad actual
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '$_edad',
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(width: 16),

                    Text(
                      '${_edad + 1}',
                      style: const TextStyle(
                        fontSize: 20,
                        color: Colors.white54,
                      ),
                    ),

                    IconButton(
                      icon: const Icon(Icons.arrow_right, size: 36, color: Colors.orange),
                      onPressed: () => _cambiarEdad(1),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            const Center(
              child: Icon(Icons.cake, color: Colors.amber, size: 48),
            ),

            const Spacer(),

            // Botón de continuar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E88E5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 4,
                  ),
                  onPressed: _navigateToEstaturaScreen,
                  child: const Text(
                    'Continuar',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToEstaturaScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EstaturaScreen(
          selectedHead: widget.selectedHead,
          selectedBody: widget.selectedBody,
          selectedOutfit: widget.selectedOutfit,
          selectedGenero: widget.selectedGenero,
          selectedEdad: _edad.toString(),
        ),
      ),
    );
  }
}
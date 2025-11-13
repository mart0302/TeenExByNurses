import 'package:flutter/material.dart';
import 'edad.dart';

class GeneroScreen extends StatefulWidget {
  final String selectedHead;
  final String selectedBody;
  final String selectedOutfit;

  const GeneroScreen({
    super.key,
    required this.selectedHead,
    required this.selectedBody,
    required this.selectedOutfit,
  });

  @override
  State<GeneroScreen> createState() => _GeneroScreenState();
}

class _GeneroScreenState extends State<GeneroScreen> {
  final List<Map<String, dynamic>> generos = [
    {'icon': Icons.male, 'label': 'Masculino'},
    {'icon': Icons.female, 'label': 'Femenino'},
    {'icon': Icons.transgender, 'label': 'No binario'},
  ];

  int selectedIndex = 0;

  void _changeGenero(int direction) {
    setState(() {
      selectedIndex = (selectedIndex + direction + generos.length) % generos.length;
    });
  }

  void _navigateToEdadScreen(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EdadScreen(
          selectedHead: widget.selectedHead,
          selectedBody: widget.selectedBody,
          selectedOutfit: widget.selectedOutfit,
          selectedGenero: generos[selectedIndex]['label'],
        ),
      ),
    );
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
                '¿Cuál es tu género?',
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

            // Selector de género mejorado
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_left, size: 32, color: Colors.orange),
                      onPressed: () => _changeGenero(-1),
                    ),
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: List.generate(generos.length, (index) {
                          final isSelected = index == selectedIndex;
                          return _GenderOption(
                            icon: generos[index]['icon'],
                            label: generos[index]['label'],
                            isSelected: isSelected,
                            onTap: () => setState(() => selectedIndex = index),
                          );
                        }),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.arrow_right, size: 32, color: Colors.orange),
                      onPressed: () => _changeGenero(1),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Center(
              child: Text(
                generos[selectedIndex]['label'],
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Spacer(),

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
                  onPressed: () => _navigateToEdadScreen(context),
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
}

class _GenderOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderOption({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: isSelected ? 56 : 48,
            height: isSelected ? 56 : 48,
            decoration: BoxDecoration(
              color: isSelected ? Colors.white.withOpacity(0.1) : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: isSelected ? Colors.orange : Colors.white,
              size: isSelected ? 40 : 32,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? Colors.orange : Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
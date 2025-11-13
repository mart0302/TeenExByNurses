import 'package:flutter/material.dart';
import 'correo.dart';

class PesoScreen extends StatefulWidget {
  final String selectedHead;
  final String selectedBody;
  final String selectedOutfit;
  final String selectedGenero;
  final String selectedEdad;
  final String selectedEstatura;

  const PesoScreen({
    Key? key,
    required this.selectedHead,
    required this.selectedBody,
    required this.selectedOutfit,
    required this.selectedGenero,
    required this.selectedEdad,
    required this.selectedEstatura,
  }) : super(key: key);

  @override
  _PesoScreenState createState() => _PesoScreenState();
}

class _PesoScreenState extends State<PesoScreen> {
  static const _primaryColor = Color(0xFF004C91);
  static const _accentColor = Colors.orange;
  static const _buttonColor = Color(0xFF1E88E5);

  int _peso = 69;

  void _incrementarPeso() => setState(() => _peso++);
  void _decrementarPeso() => setState(() {
    if (_peso > 1) _peso--;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _primaryColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildAppBar(),
              const SizedBox(height: 8),
              _buildTitle(),
              const SizedBox(height: 12),
              _buildAvatar(),
              const SizedBox(height: 20),
              _buildWeightSelector(),
              const Spacer(),
              _buildContinueButton(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppBar() {
    return Align(
      alignment: Alignment.centerLeft,
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      '¿Cuál es tu peso?',
      style: TextStyle(
        fontSize: 26,
        color: _accentColor,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildAvatar() {
    return Center(
      child: SizedBox(
        width: 160,
        height: 280,
        child: Stack(
          alignment: Alignment.topCenter,
          children: [
            Positioned(
              top: 110,
              child: Image.asset(widget.selectedOutfit, width: 100),
            ),
            Positioned(
              top: 64,
              child: Image.asset(widget.selectedBody, width: 100),
            ),
            Positioned(
              top: 0,
              child: Image.asset(widget.selectedHead, width: 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildWeightRangeText(),
          const SizedBox(height: 10),
          _buildWeightControls(),
        ],
      ),
    );
  }

  Widget _buildWeightRangeText() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('${_peso - 1}',
            style: const TextStyle(color: Colors.white, fontSize: 20)),
        Text('${_peso + 1}',
            style: const TextStyle(color: Colors.white, fontSize: 20)),
      ],
    );
  }

  Widget _buildWeightControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildDecreaseButton(),
        const SizedBox(width: 16),
        _buildCurrentWeightDisplay(),
        const SizedBox(width: 16),
        _buildIncreaseButton(),
      ],
    );
  }

  Widget _buildDecreaseButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_left, color: _accentColor, size: 32),
      onPressed: _decrementarPeso,
    );
  }

  Widget _buildIncreaseButton() {
    return IconButton(
      icon: const Icon(Icons.arrow_right, color: _accentColor, size: 32),
      onPressed: _incrementarPeso,
    );
  }

  Widget _buildCurrentWeightDisplay() {
    return Column(
      children: [
        const Icon(Icons.monitor_weight, color: Colors.white, size: 48),
        Text(
          '$_peso Kg',
          style: const TextStyle(
            fontSize: 32,
            color: _accentColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildContinueButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: _buttonColor,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: _navigateToEmailScreen,
      child: const Text(
        'Continuar',
        style: TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }

  void _navigateToEmailScreen() {
    Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          final tween = Tween<Offset>(
            begin: const Offset(1.0, 0.0),
            end: Offset.zero,
          ).chain(CurveTween(curve: Curves.easeInOut));
          return SlideTransition(
            position: animation.drive(tween),
            child: child,
          );
        },
        pageBuilder: (context, animation, secondaryAnimation) => CorreoScreen(
          selectedHead: widget.selectedHead,
          selectedBody: widget.selectedBody,
          selectedOutfit: widget.selectedOutfit,
          selectedGenero: widget.selectedGenero,
          selectedEdad: widget.selectedEdad,
          selectedEstatura: widget.selectedEstatura,
          selectedPeso: _peso.toString(),
        ),
      ),
    );
  }
}
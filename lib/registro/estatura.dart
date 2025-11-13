import 'package:flutter/material.dart';
import 'peso.dart';

class EstaturaScreen extends StatefulWidget {
  final String selectedHead;
  final String selectedBody;
  final String selectedOutfit;
  final String selectedGenero;
  final String selectedEdad;

  const EstaturaScreen({
    Key? key,
    required this.selectedHead,
    required this.selectedBody,
    required this.selectedOutfit,
    required this.selectedGenero,
    required this.selectedEdad,
  }) : super(key: key);

  @override
  _EstaturaScreenState createState() => _EstaturaScreenState();
}

class _EstaturaScreenState extends State<EstaturaScreen> {
  double _estatura = 1.65;
  final double _minEstatura = 1.20;
  final double _maxEstatura = 2.50;
  final double _incremento = 0.01;

  void _incrementar() {
    setState(() {
      if (_estatura < _maxEstatura) {
        _estatura += _incremento;
        _estatura = double.parse(_estatura.toStringAsFixed(2));
      }
    });
  }

  void _decrementar() {
    setState(() {
      if (_estatura > _minEstatura) {
        _estatura -= _incremento;
        _estatura = double.parse(_estatura.toStringAsFixed(2));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF004C91),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Text(
              '¿Cuánto mides?',
              style: TextStyle(
                fontSize: 26,
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildHeightIndicator(),
            const SizedBox(height: 20),
            Expanded(child: _buildHeightSelector()),
            _buildContinueButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeightIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.orange,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        '${_estatura.toStringAsFixed(2)} Mts.',
        style: const TextStyle(
          fontSize: 24,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeightSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildHeightRuler(),
          _buildAvatar(),
        ],
      ),
    );
  }

  Widget _buildHeightRuler() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: _incrementar,
          icon: const Icon(Icons.add, size: 28, color: Colors.orange),
        ),
        const SizedBox(height: 4),
        Container(
          width: 50,
          height: 220,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Stack(
            children: [
              _buildRulerMarks(),
              _buildCurrentHeightIndicator(),
            ],
          ),
        ),
        const SizedBox(height: 4),
        IconButton(
          onPressed: _decrementar,
          icon: const Icon(Icons.remove, size: 28, color: Colors.orange),
        ),
      ],
    );
  }

  Widget _buildRulerMarks() {
    return Positioned(
      top: 0,
      bottom: 0,
      left: 8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(8, (index) {
          final heightMark = _maxEstatura - (index * 0.25);
          return Column(
            children: [
              Text(
                '${heightMark.toStringAsFixed(1)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
              Container(
                width: 25,
                height: 1,
                color: Colors.white,
                margin: const EdgeInsets.symmetric(vertical: 6),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildCurrentHeightIndicator() {
    return Positioned(
      top: ((_maxEstatura - _estatura) / (_maxEstatura - _minEstatura)) * 220,
      left: 0,
      right: 0,
      child: Container(
        height: 2,
        color: Colors.orange,
      ),
    );
  }

  Widget _buildAvatar() {
    return SizedBox(
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
    );
  }

  Widget _buildContinueButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(40, 16, 40, 24),
      child: ElevatedButton(
        onPressed: _navigateToPesoScreen,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E88E5),
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Continuar',
          style: TextStyle(fontSize: 16, color: Colors.white),
        ),
      ),
    );
  }

  void _navigateToPesoScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PesoScreen(
          selectedHead: widget.selectedHead,
          selectedBody: widget.selectedBody,
          selectedOutfit: widget.selectedOutfit,
          selectedGenero: widget.selectedGenero,
          selectedEdad: widget.selectedEdad,
          selectedEstatura: _estatura.toStringAsFixed(2),
        ),
      ),
    );
  }
}
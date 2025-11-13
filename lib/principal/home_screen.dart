import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../videos/video_widget.dart';
import 'pantalla_planificacion.dart';
import 'pantalla_material.dart';
import 'pantalla_recomendaciones.dart';
import 'pantalla_informacion.dart';
import '../welcome_screen.dart';
import 'configuracion.dart'; // 👈 Agregamos esta línea

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  double? _imc;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() {
          _errorMessage = 'Usuario no autenticado';
          _isLoading = false;
        });
        return;
      }

      final snapshot = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(user.uid)
          .get();

      if (!snapshot.exists) {
        setState(() {
          _errorMessage = 'Datos de usuario no encontrados';
          _isLoading = false;
        });
        return;
      }

      final data = snapshot.data()!;
      final peso = double.tryParse(data['peso']?.toString() ?? '');
      final estatura = double.tryParse(data['estatura']?.toString() ?? '');

      if (peso == null || estatura == null || estatura <= 0) {
        setState(() {
          _errorMessage = 'Datos de peso/estatura inválidos';
          _isLoading = false;
        });
        return;
      }

      final estaturaMetros = estatura > 3 ? estatura / 100 : estatura;
      final imc = peso / (estaturaMetros * estaturaMetros);

      setState(() {
        _imc = double.parse(imc.toStringAsFixed(1));
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error al cargar datos: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF004C91),
          title: const Text('Inicio', style: TextStyle(color: Colors.white)),
          automaticallyImplyLeading: false,
          actions: [
            _buildSettingsPopupMenu(),
          ],
        ),
        body: _isLoading
            ? _buildLoadingIndicator()
            : _errorMessage.isNotEmpty
            ? _buildErrorWidget()
            : _buildContent(),
        bottomNavigationBar: _buildBottomNavBar(context),
      ),
    );
  }

  Widget _buildSettingsPopupMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.settings, color: Colors.white),
      onSelected: (value) async {
        if (value == 'logout') {
          await _handleLogout();
        } else if (value == 'config') {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ConfiguracionScreen()),
          );
        }
      },
      itemBuilder: (BuildContext context) => [
        const PopupMenuItem<String>(
          value: 'config',
          child: Text('Configuración'),
        ),
        const PopupMenuItem<String>(
          value: 'logout',
          child: Text('Cerrar sesión'),
        ),
      ],
    );
  }

  Future<void> _handleLogout() async {
    try {
      await FirebaseAuth.instance.signOut();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
              (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al cerrar sesión: ${e.toString()}')),
        );
      }
    }
  }

  Widget _buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF004C91)),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            _errorMessage,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadUserData,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF004C91),
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildVideoSection(),
          const SizedBox(height: 24),
          _buildWaterConsumptionCard(),
          const SizedBox(height: 16),
          _buildBMICard(),
          const SizedBox(height: 24),
          _buildInfoReminder(),
        ],
      ),
    );
  }

  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manual de usuario',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: Color(0xFF004C91),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 200,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: const VideoWidget(),
          ),
        ),
      ],
    );
  }

  Widget _buildWaterConsumptionCard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Image.asset('assets/agua.png', width: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consumo diario de agua aproximado',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF004C91),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '1277 ml/día Equivale a\n5 vasos de agua diarios',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBMICard() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.fitness_center,
                color: Color(0xFFD3B88C), size: 48),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Índice de Masa Corporal (IMC)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: const Color(0xFF004C91),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Relación entre peso y estatura',
                    style: TextStyle(color: Colors.blue),
                  ),
                ],
              ),
            ),
            Text(
              _imc?.toString() ?? '--',
              style: const TextStyle(
                color: Colors.blue,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoReminder() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8.0),
      child: Text(
        'Recordá mantener tu información actualizada en 🧑‍💼 Mi información',
        style: TextStyle(fontSize: 12, color: Colors.grey),
      ),
    );
  }

  Widget _buildBottomNavBar(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItemColor: const Color(0xFF004C91),
      unselectedItemColor: Colors.grey,
      currentIndex: 0,
      onTap: (index) => _handleNavTap(context, index),
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Planificación'),
        BottomNavigationBarItem(icon: Icon(Icons.menu_book), label: 'Material'),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Recomendaciones'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Mi información'),
      ],
    );
  }

  void _handleNavTap(BuildContext context, int index) {
    if (index == 0) return;

    switch (index) {
      case 1:
        _navigateTo(context, const PantallaPlanificacion());
        break;
      case 2:
        _navigateTo(context, const PantallaMaterial());
        break;
      case 3:
        _navigateTo(context, const PantallaRecomendaciones());
        break;
      case 4:
        _navigateToUserInfo(context);
        break;
    }
  }

  void _navigateTo(BuildContext context, Widget page) {
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(1, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutQuart,
            )),
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  void _navigateToUserInfo(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PantallaInformacion(
          selectedHead: '',
          selectedBody: '',
          selectedOutfit: '',
        ),
      ),
    );
  }
}

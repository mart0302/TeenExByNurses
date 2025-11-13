import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:video_player/video_player.dart';
import 'pantalla_planificacion.dart';
import 'pantalla_material.dart';
import 'pantalla_recomendaciones.dart';
import 'pantalla_informacion.dart';
import '../welcome_screen.dart';
import 'configuracion.dart';

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
        'Recuerda mantener tu información actualizada en Mi información',
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

// VideoWidget incluido directamente en el mismo archivo
class VideoWidget extends StatefulWidget {
  const VideoWidget({super.key});

  @override
  State<VideoWidget> createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget> {
  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  bool _isLoading = false;

  // URL del video manual de usuario desde Cloudinary
  final String _videoUrl = 'https://res.cloudinary.com/dzgwm2jpc/video/upload/v1763071021/pruebavideo_reducido_gbn5j3.mp4';

  @override
  void initState() {
    super.initState();
    _initializeVideoController();
  }

  Future<void> _initializeVideoController() async {
    try {
      setState(() {
        _isLoading = true;
      });

      _controller = VideoPlayerController.networkUrl(Uri.parse(_videoUrl))
        ..addListener(() {
          if (mounted) setState(() {});
        });

      await _controller.initialize();

      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error cargando video: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isVideoInitialized = false;
        });
      }
    }
  }

  void _mostrarVideoCompleto() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.all(20),
        child: Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              // Header del diálogo
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFF004C91),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16),
                    topRight: Radius.circular(16),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.help_outline_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Manual de Usuario',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        if (_controller.value.isPlaying) {
                          _controller.pause();
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              // Video Player
              Expanded(
                child: _isVideoInitialized
                    ? ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_controller),
                      if (!_controller.value.isPlaying)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.play_arrow_rounded,
                              size: 50,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              setState(() {
                                _controller.play();
                              });
                            },
                          ),
                        ),
                    ],
                  ),
                )
                    : const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF004C91),
                  ),
                ),
              ),
              // Controles del video
              if (_isVideoInitialized)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _controller.value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: const Color(0xFF004C91),
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            _controller.value.isPlaying
                                ? _controller.pause()
                                : _controller.play();
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: VideoProgressIndicator(
                          _controller,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Color(0xFF004C91),
                            bufferedColor: Color(0xFFCCE4FF),
                            backgroundColor: Color(0xFFE6F0FA),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _mostrarVideoCompleto,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF004C91), width: 2),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Vista previa del video
            if (_isVideoInitialized)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: VideoPlayer(_controller),
              )
            else if (_isLoading)
              const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF004C91),
                ),
              )
            else
              const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.play_circle_filled_rounded,
                    color: Color(0xFF004C91),
                    size: 50,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Manual de Usuario',
                    style: TextStyle(
                      color: Color(0xFF004C91),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Toca para ver el video',
                    style: TextStyle(
                      color: Color(0xFF004C91),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

            // Overlay de play
            if (_isVideoInitialized && !_controller.value.isPlaying)
              Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SedentarismoScreen extends StatefulWidget {
  const SedentarismoScreen({super.key});

  @override
  State<SedentarismoScreen> createState() => _SedentarismoScreenState();
}

class _SedentarismoScreenState extends State<SedentarismoScreen> {
  final List<InfoButton> _infoButtons = [
    InfoButton(
      title: 'Causas del sedentarismo',
      content: '''El uso del celular y la computadora hace que pase mucho tiempo sentado, lo cual afecta mi salud si no me muevo lo suficiente.

La falta de parques y canchas seguras reduce mis opciones para hacer ejercicio al aire libre, aunque siempre puedo ejercitarme de otras formas.

Las ocupaciones diarias y responsabilidades reducen mi actividad física y el interés en hacer ejercicio.

Las redes sociales me muestran comerciales donde venden comida poco saludable y estilos de vida sedentarios.

La falta de dinero para pagar gimnasios o equipos deportivos puede hacer que no haga ejercicio.''',
    ),
    InfoButton(
      title: 'Factores contribuyentes al sedentarismo',
      content: '''El uso del celular y la computadora hace que pase mucho tiempo sentado, lo cual afecta mi salud si no me muevo lo suficiente.

Cuando hay menos tiempo para educación física en la escuela o para jugar en el recreo, se reduce la oportunidad de mantenerse activo.

La influencia de amigos que pasan mucho tiempo sentados puede hacer que siga su ejemplo.''',
    ),
    InfoButton(
      title: 'Consecuencias a largo plazo',
      content: '''Estar inactivo ahora podría afectar mi estado de ánimo en el futuro, causando tristeza o ansiedad.

Estar inactivo la mayor parte del tiempo puede provocar sobrepeso y ser causa de problemas graves del corazón y diabetes.

No moverte lo suficiente puede ser dañino para tus huesos y músculos, haciéndolos más débiles y aumentando el riesgo de lesiones.

Ser inactivo y sedentario en la juventud podría repercutir en mi incapacidad para realizar actividades básicas cuando sea adulto.

Entender cómo la actividad física mejora mi estado de ánimo y reduce el estrés me ayuda a sentirme mejor tanto física como emocionalmente.

Generar un ambiente donde la motivación y el apoyo me permitan sentirme cómodo y con ganas de mantenerme activo.''',
    ),
    InfoButton(
      title: 'Consejos y Estrategias para Combatir el Sedentarismo',
      content: '''Practicar deportes con amigos puede hacer que me sienta mejor conmigo mismo y me divierta más mientras hago ejercicio.

Salir a caminar o andar en bicicleta con amigos es una excelente manera de pasar el tiempo juntos mientras nos mantenemos activos y saludables.

Tener clases de ejercicio gratuitas o económicas en la escuela o en lugares cercanos puede darme opciones accesibles para mantenerme activo y saludable.''',
    ),
  ];

  // URL del video desde Cloudinary - CORREGIDA
  final String _videoUrl = 'https://res.cloudinary.com/dzgwm2jpc/video/upload/v1763071048/sedentarismo_hcjzns.mp4';

  late VideoPlayerController _controller;
  bool _isVideoInitialized = false;
  bool _isLoading = false;

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

  void _mostrarVideoDialog() {
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
                      Icons.play_circle_filled_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Video: Sedentarismo',
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
              // Video Player - CORREGIDO
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

  void _mostrarDialogo(String titulo, String contenido) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: const Color(0xFFF7FAFC),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Center(
          child: Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF004C91),
              fontSize: 18,
            ),
          ),
        ),
        content: SingleChildScrollView(
          child: Text(
            contenido,
            textAlign: TextAlign.justify,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
        actions: [
          Center(
            child: IconButton(
              icon: const Icon(Icons.check_circle, size: 36, color: Colors.green),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotonInfo(String titulo, String contenido) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: ElevatedButton(
        onPressed: () => _mostrarDialogo(titulo, contenido),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF004C91),
          side: const BorderSide(color: Color(0xFF004C91)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          elevation: 2,
        ),
        child: Text(
          titulo,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildVideoCard() {
    return GestureDetector(
      onTap: _mostrarVideoDialog,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header con título y descripción
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFF004C91),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.health_and_safety_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Video: Sedentarismo y sus consecuencias',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Ver video informativo sobre el sedentarismo',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // Contenido de la tarjeta del video
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Color(0xFFF7FAFC),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: const Color(0xFF004C91),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF004C91).withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.play_arrow_rounded,
                      size: 28,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Ver video demostrativo',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF004C91),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Toca para ver el video dentro de la aplicación',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[700],
                            height: 1.3,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFF004C91).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.play_circle_rounded,
                                size: 12,
                                color: const Color(0xFF004C91),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'Reproducir video',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: const Color(0xFF004C91).withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC),
      appBar: AppBar(
        title: const Text(
          'Sedentarismo y Salud',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF004C91),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header informativo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF004C91),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            'Consecuencias del Sedentarismo',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Descubre los riesgos de la inactividad física y cómo combatirla',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),

              // Botones de información
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: _infoButtons
                      .map((info) => _buildBotonInfo(info.title, info.content))
                      .toList(),
                ),
              ),

              // Título de sección de video
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFF004C91),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.video_library_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Video Demonstrativo',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        '1 video',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Tarjeta del video
              _buildVideoCard(),

              const SizedBox(height: 16),

              // Footer informativo
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F0FA),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.play_circle_filled_rounded,
                      color: const Color(0xFF004C91),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'El video se reproduce de forma nativa en la aplicación',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey[700],
                          height: 1.3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class InfoButton {
  final String title;
  final String content;

  InfoButton({
    required this.title,
    required this.content,
  });
}
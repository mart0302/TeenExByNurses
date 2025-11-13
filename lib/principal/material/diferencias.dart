import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DiferenciasScreen extends StatefulWidget {
  const DiferenciasScreen({super.key});

  @override
  State<DiferenciasScreen> createState() => _DiferenciasScreenState();
}

class _DiferenciasScreenState extends State<DiferenciasScreen> {
  // Lista de videos actualizada con Cloudinary
  final List<VideoContent> _videoContents = [
    VideoContent(
      title: 'Calentamiento',
      videoPath: 'https://res.cloudinary.com/dzgwm2jpc/video/upload/v1763071061/calentamiento_mgu02y.mp4',
      description: 'Ejercicios de calentamiento para preparar el cuerpo',
    ),
    VideoContent(
      title: 'Actividad Física de bajo impacto',
      videoPath: 'https://res.cloudinary.com/dzgwm2jpc/video/upload/v1763071489/bajo_impacto_l70dl6.mp4',
      description: 'Actividades suaves para todas las edades',
    ),
    VideoContent(
      title: 'Ejercicios de cardio en casa',
      videoPath: 'https://res.cloudinary.com/dzgwm2jpc/video/upload/v1763071861/cardio_en_casa_pqhdrf.mp4',
      description: 'Rutinas cardiovasculares sin necesidad de equipo',
    ),
    VideoContent(
      title: 'Rutina de ejercicios',
      videoPath: 'https://res.cloudinary.com/dzgwm2jpc/video/upload/v1763071051/rutina_ejercicios_mce92o.mp4',
      description: 'Secuencia completa de ejercicios',
    ),
    VideoContent(
      title: 'Enfriamiento',
      videoPath: 'https://res.cloudinary.com/dzgwm2jpc/video/upload/v1763071060/enfriamiento_oxd9d7.mp4',
      description: 'Ejercicios para finalizar la actividad física',
    ),
    VideoContent(
      title: 'Sedentarismo',
      videoPath: 'https://res.cloudinary.com/dzgwm2jpc/video/upload/v1763071048/sedentarismo_hcjzns.mp4',
      description: 'Información sobre el sedentarismo',
    ),
  ];

  final List<InfoButton> _infoButtons = [
    InfoButton(
      title: 'Tipos de actividad física y ejercicio',
      content: '''Los ejercicios aeróbicos como correr, nadar o andar en bicicleta son ejemplos de actividades cardiovasculares que benefician la salud del corazón.

Ejemplos de ejercicios anaeróbicos, como el levantamiento de pesas, las flexiones de brazos o las sentadillas, pueden mejorar la fuerza y la masa muscular.''',
    ),
    InfoButton(
      title: 'Diferencia entre actividad física y ejercicio y los beneficios para la salud',
      content: '''Mantenernos activos es importante, y no es lo mismo hacer actividad física que hacer ejercicio. Ambos son beneficiosos para la salud y nos ayudan a sentirnos mejor.

Hacer actividades físicas como caminar, correr o bailar ayuda a fortalecer el corazón, aumentando nuestra resistencia y reduciendo el riesgo de enfermedades.

Cuando hacemos ejercicio, como levantar pesas o hacer flexiones, fortalecemos nuestros músculos y mejoramos nuestra resistencia. También nos hace sentir mejor emocionalmente, porque reduce los niveles de estrés y de ansiedad, y mejora nuestro estado de ánimo.

Entender la diferencia entre actividad física y ejercicio es importante para crear rutinas de entrenamiento adecuadas a nuestras necesidades y metas.

Comprender las diferencias entre actividad física y ejercicio es fundamental para mejorar nuestra salud y bienestar general.''',
    ),
  ];

  // Controladores para los diálogos de video
  late List<VideoPlayerController?> _controllers;
  late List<bool> _isVideoInitialized;
  late List<bool> _isLoadingVideo;

  @override
  void initState() {
    super.initState();
    _controllers = List<VideoPlayerController?>.filled(_videoContents.length, null);
    _isVideoInitialized = List<bool>.filled(_videoContents.length, false);
    _isLoadingVideo = List<bool>.filled(_videoContents.length, false);
  }

  Future<void> _initializeVideo(int index) async {
    try {
      if (mounted) {
        setState(() {
          _isLoadingVideo[index] = true;
        });
      }

      _controllers[index] = VideoPlayerController.networkUrl(
        Uri.parse(_videoContents[index].videoPath),
      )..addListener(() {
        if (mounted) setState(() {});
      });

      await _controllers[index]!.initialize();

      if (mounted) {
        setState(() {
          _isVideoInitialized[index] = true;
          _isLoadingVideo[index] = false;
        });
      }
    } catch (e) {
      debugPrint("❌ Error cargando video $index: $e");
      if (mounted) {
        setState(() {
          _isLoadingVideo[index] = false;
          _isVideoInitialized[index] = false;
        });
      }
      _mostrarErrorDialog('Error al cargar el video', 'No se pudo cargar el video. Verifica tu conexión a internet.');
    }
  }

  void _mostrarVideoDialog(int index) {
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
                    Expanded(
                      child: Text(
                        'Video: ${_videoContents[index].title}',
                        style: const TextStyle(
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
                        if (_controllers[index] != null && _controllers[index]!.value.isPlaying) {
                          _controllers[index]!.pause();
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ],
                ),
              ),
              // Video Player
              Expanded(
                child: _isVideoInitialized[index] && _controllers[index] != null
                    ? ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      VideoPlayer(_controllers[index]!),
                      if (!_controllers[index]!.value.isPlaying)
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
                                _controllers[index]!.play();
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
              if (_isVideoInitialized[index] && _controllers[index] != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(
                          _controllers[index]!.value.isPlaying
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: const Color(0xFF004C91),
                          size: 30,
                        ),
                        onPressed: () {
                          setState(() {
                            _controllers[index]!.value.isPlaying
                                ? _controllers[index]!.pause()
                                : _controllers[index]!.play();
                          });
                        },
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: VideoProgressIndicator(
                          _controllers[index]!,
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

  void _iniciarVideo(int index) async {
    await _initializeVideo(index);
    if (_isVideoInitialized[index]) {
      _mostrarVideoDialog(index);
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller?.dispose();
    }
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
            textAlign: TextAlign.center,
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

  void _mostrarErrorDialog(String titulo, String mensaje) {
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
              color: Colors.red,
              fontSize: 18,
            ),
          ),
        ),
        content: Text(
          mensaje,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16, color: Colors.black87),
        ),
        actions: [
          Center(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Aceptar'),
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

  Widget _buildVideoCard(VideoContent content, int index) {
    return GestureDetector(
      onTap: () => _iniciarVideo(index),
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
                          Icons.sports_gymnastics_rounded,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          content.title,
                          style: const TextStyle(
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
                  Text(
                    content.description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.9),
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
                          'Toca para ver el video en pantalla completa',
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
          'Actividad - Ejercicio - Rutina',
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

              // Título de sección de videos
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
                        'Videos Demonstrativos',
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
                      child: Text(
                        '${_videoContents.length} videos',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Lista de videos
              ...List.generate(
                _videoContents.length,
                    (index) => _buildVideoCard(_videoContents[index], index),
              ),

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
                        'Los videos se reproducen en pantalla completa',
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

class VideoContent {
  final String title;
  final String videoPath;
  final String description;

  VideoContent({
    required this.title,
    required this.videoPath,
    required this.description,
  });
}

class InfoButton {
  final String title;
  final String content;

  InfoButton({
    required this.title,
    required this.content,
  });
}
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class DiferenciasScreen extends StatefulWidget {
  const DiferenciasScreen({super.key});

  @override
  State<DiferenciasScreen> createState() => _DiferenciasScreenState();
}

class _DiferenciasScreenState extends State<DiferenciasScreen> {
  final List<VideoContent> _videoContents = [
    VideoContent(
      title: 'Calentamiento',
      videoPath: 'assets/videos/calentamiento.mp4',
      description: 'Ejercicios de calentamiento para preparar el cuerpo',
    ),
    VideoContent(
      title: 'Actividad Física de bajo impacto',
      videoPath: 'assets/videos/bajo_impacto.mp4',
      description: 'Actividades suaves para todas las edades',
    ),
    VideoContent(
      title: 'Ejercicios de cardio en casa',
      videoPath: 'assets/videos/cardio_en_casa.mp4',
      description: 'Rutinas cardiovasculares sin necesidad de equipo',
    ),
    VideoContent(
      title: 'Rutina de ejercicios',
      videoPath: 'assets/videos/rutina_ejercicios.mp4',
      description: 'Secuencia completa de ejercicios',
    ),
    VideoContent(
      title: 'Enfriamiento',
      videoPath: 'assets/videos/enfriamiento.mp4',
      description: 'Ejercicios para finalizar la actividad física',
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

  late List<VideoPlayerController?> _controllers;
  late List<bool> _isVideoInitialized;

  @override
  void initState() {
    super.initState();
    _controllers = List<VideoPlayerController?>.filled(_videoContents.length, null);
    _isVideoInitialized = List<bool>.filled(_videoContents.length, false);
  }

  Future<void> _initializeVideo(int index) async {
    if (_controllers[index] != null && _isVideoInitialized[index]) return;

    try {
      _controllers[index] = VideoPlayerController.asset(_videoContents[index].videoPath);
      await _controllers[index]!.initialize();

      if (mounted) {
        setState(() {
          _isVideoInitialized[index] = true;
        });
      }
    } catch (e) {
      debugPrint("❌ Error cargando video $index: $e");
      if (mounted) {
        setState(() {
          _isVideoInitialized[index] = true;
        });
      }
    }
  }

  void _pauseOtherVideos(int currentIndex) {
    for (int i = 0; i < _controllers.length; i++) {
      if (i != currentIndex && _controllers[i] != null && _controllers[i]!.value.isPlaying) {
        _controllers[i]!.pause();
      }
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

  Widget _buildVideoPlayer(VideoContent content, int index) {
    final controller = _controllers[index];
    final isInitialized = _isVideoInitialized[index];

    return Container(
      margin: const EdgeInsets.only(bottom: 16), // Reducido el margen
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8, // Reducido el blur
            offset: const Offset(0, 2), // Reducido el offset
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // IMPORTANTE: Evita overflow
        children: [
          // Header con título y descripción
          Container(
            padding: const EdgeInsets.all(16), // Reducido el padding
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
                        size: 18, // Tamaño reducido
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        content.title,
                        style: const TextStyle(
                          fontSize: 16, // Tamaño reducido
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        maxLines: 2, // Limitar líneas
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  content.description,
                  style: TextStyle(
                    fontSize: 13, // Tamaño reducido
                    color: Colors.white.withOpacity(0.9),
                    height: 1.3,
                  ),
                  maxLines: 2, // Limitar líneas
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Video o placeholder
          if (isInitialized && controller != null)
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                  child: AspectRatio(
                    aspectRatio: controller.value.aspectRatio,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        VideoPlayer(controller),
                        if (!controller.value.isPlaying)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.4),
                              shape: BoxShape.circle,
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.play_arrow_rounded,
                                  size: 40, color: Colors.white), // Tamaño reducido
                              onPressed: () {
                                setState(() {
                                  controller.play();
                                  _pauseOtherVideos(index);
                                });
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(12), // Padding reducido
                  child: Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          controller.value.isPlaying
                              ? Icons.pause_circle_filled_rounded
                              : Icons.play_circle_fill_rounded,
                          size: 28, // Tamaño reducido
                          color: const Color(0xFF004C91),
                        ),
                        onPressed: () {
                          setState(() {
                            if (controller.value.isPlaying) {
                              controller.pause();
                            } else {
                              controller.play();
                              _pauseOtherVideos(index);
                            }
                          });
                        },
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: VideoProgressIndicator(
                          controller,
                          allowScrubbing: true,
                          colors: const VideoProgressColors(
                            playedColor: Color(0xFF004C91),
                            bufferedColor: Color(0xFFCCE4FF),
                            backgroundColor: Color(0xFFE6F0FA),
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      IconButton(
                        icon: Icon(
                          controller.value.isLooping
                              ? Icons.repeat_on_rounded
                              : Icons.repeat_rounded,
                          color: const Color(0xFF004C91),
                          size: 22, // Tamaño reducido
                        ),
                        onPressed: () {
                          setState(() {
                            controller.setLooping(!controller.value.isLooping);
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ],
            )
          else
            _buildVideoPlaceholder(content, index),
        ],
      ),
    );
  }

  Widget _buildVideoPlaceholder(VideoContent content, int index) {
    return GestureDetector(
      onTap: () {
        _initializeVideo(index).then((_) {
          if (mounted) {
            setState(() {});
          }
        });
      },
      child: Container(
        height: 140, // Altura reducida
        padding: const EdgeInsets.all(16), // Padding reducido
        decoration: BoxDecoration(
          color: const Color(0xFFF7FAFC),
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
          border: Border.all(
            color: const Color(0xFFE6F0FA),
            width: 1, // Ancho reducido
          ),
        ),
        child: Row( // Cambiado a Row para mejor uso del espacio
          children: [
            // Icono principal
            Container(
              width: 60, // Tamaño reducido
              height: 60, // Tamaño reducido
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
                size: 28, // Tamaño reducido
                color: Colors.white,
              ),
            ),

            const SizedBox(width: 16),

            // Contenido textual
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Ver video demostrativo',
                    style: const TextStyle(
                      fontSize: 14, // Tamaño reducido
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF004C91),
                    ),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    content.description,
                    style: TextStyle(
                      fontSize: 12, // Tamaño reducido
                      color: Colors.grey[700],
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 6),

                  // Badge de optimización
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
                          Icons.bolt_rounded,
                          size: 12,
                          color: const Color(0xFF004C91),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Toca para cargar',
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
            fontSize: 16, // Tamaño reducido
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
      body: SafeArea( // IMPORTANTE: Evita overlap con notches
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16), // Padding reducido
          child: Column(
            mainAxisSize: MainAxisSize.min, // IMPORTANTE: Previene overflow
            children: [
              // Botones de información
              Container(
                padding: const EdgeInsets.all(12), // Padding reducido
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
                padding: const EdgeInsets.all(12), // Padding reducido
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
                        size: 20, // Tamaño reducido
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Videos Demonstrativos',
                        style: TextStyle(
                          fontSize: 16, // Tamaño reducido
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
                    (index) => _buildVideoPlayer(_videoContents[index], index),
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
                      Icons.info_outline_rounded,
                      color: const Color(0xFF004C91),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Los videos se cargan bajo demanda para optimizar el rendimiento',
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

              const SizedBox(height: 20), // Espacio extra al final
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
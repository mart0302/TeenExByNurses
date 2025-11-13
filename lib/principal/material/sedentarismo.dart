import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class SedentarismoScreen extends StatefulWidget {
  const SedentarismoScreen({super.key});

  @override
  State<SedentarismoScreen> createState() => _SedentarismoScreenState();
}

class _SedentarismoScreenState extends State<SedentarismoScreen> {
  late VideoPlayerController _controller;
  bool _isVideoExpanded = false;
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

      _controller = VideoPlayerController.asset('assets/videos/sedentarismo.mp4');
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
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showInfoDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.all(20), // MARGEN DE SEGURIDAD
        child: ConstrainedBox( // EVITA OVERFLOW
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8, // ALTURA MÁXIMA
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // TÍTULO
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF004C91),
                    fontSize: 18, // REDUCIDO
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 16),

                // CONTENIDO CON SCROLL
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      content,
                      textAlign: TextAlign.justify,
                      style: const TextStyle(
                        fontSize: 15, // REDUCIDO
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // BOTÓN
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF004C91),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    child: const Text(
                      'Entendido',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showInfoDialog(title, content),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF004C91).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.info_outline,
                  color: Color(0xFF004C91),
                  size: 22, // REDUCIDO
                ),
              ),
              const SizedBox(width: 12), // REDUCIDO
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, // SEMIBOLD
                    color: Color(0xFF004C91),
                    fontSize: 15, // REDUCIDO
                  ),
                ),
              ),
              const Icon(
                Icons.chevron_right,
                color: Color(0xFF004C91),
                size: 20, // REDUCIDO
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVideoPlayer() {
    return Column(
      children: [
        // VIDEO CONTAINER
        GestureDetector(
          onTap: () {
            if (_isVideoInitialized) {
              setState(() {
                _isVideoExpanded = !_isVideoExpanded;
              });
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            height: _isVideoExpanded
                ? MediaQuery.of(context).size.height * 0.35 // REDUCIDO
                : MediaQuery.of(context).size.height * 0.22, // REDUCIDO
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2), // MÁS SUAVE
                  blurRadius: 6, // REDUCIDO
                  offset: const Offset(0, 2), // REDUCIDO
                ),
              ],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // VIDEO O LOADING
                if (_isVideoInitialized)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: _controller.value.aspectRatio,
                      child: VideoPlayer(_controller),
                    ),
                  )
                else if (_isLoading)
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        color: Color(0xFF004C91),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Cargando video...',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  )
                else
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.videocam_off_rounded,
                        color: Colors.grey[400],
                        size: 40,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Video no disponible',
                        style: TextStyle(
                          color: Colors.grey[400],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                // BOTÓN PLAY OVERLAY
                if (_isVideoInitialized && !_controller.value.isPlaying)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                        size: 36, // REDUCIDO
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
          ),
        ),

        // CONTROLES DEL VIDEO
        if (_isVideoInitialized)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                IconButton(
                  icon: Icon(
                    _controller.value.isPlaying ?
                    Icons.pause_rounded : Icons.play_arrow_rounded,
                    color: const Color(0xFF004C91),
                    size: 24, // REDUCIDO
                  ),
                  onPressed: () {
                    setState(() {
                      _controller.value.isPlaying
                          ? _controller.pause()
                          : _controller.play();
                    });
                  },
                ),
                IconButton(
                  icon: Icon(
                    _isVideoExpanded ?
                    Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
                    color: const Color(0xFF004C91),
                    size: 22, // REDUCIDO
                  ),
                  onPressed: () {
                    setState(() {
                      _isVideoExpanded = !_isVideoExpanded;
                    });
                  },
                ),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7FAFC), // COLOR MÁS CLARO
      appBar: AppBar(
        title: const Text(
          'Sedentarismo y Salud',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 18, // REDUCIDO
            color: Colors.white,
          ),
        ),
        backgroundColor: const Color(0xFF004C91),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: Colors.white,
            size: 22, // REDUCIDO
          ),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 2, // REDUCIDO
      ),
      body: SafeArea( // IMPORTANTE: EVITA OVERLAP CON NOTCH
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Consecuencias del Sedentarismo',
                    style: TextStyle(
                      fontSize: 17, // REDUCIDO
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF004C91),
                    ),
                  ),
                  SizedBox(height: 6), // REDUCIDO
                  Text(
                    'Descubre los riesgos de la inactividad física y cómo combatirla',
                    style: TextStyle(
                      fontSize: 13, // REDUCIDO
                      color: Colors.grey,
                      height: 1.3,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // VIDEO
              _buildVideoPlayer(),

              const SizedBox(height: 20), // REDUCIDO

              // TARJETAS DE INFORMACIÓN
              const Text(
                'Información importante:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF004C91),
                ),
              ),

              const SizedBox(height: 12),

              _buildInfoCard(
                'Causas del sedentarismo',
                '''El uso del celular y la computadora hace que pase mucho tiempo sentado, lo cual afecta mi salud si no me muevo lo suficiente.

La falta de parques y canchas seguras reduce mis opciones para hacer ejercicio al aire libre, aunque siempre puedo ejercitarme de otras formas.

Las ocupaciones diarias y responsabilidades reducen mi actividad física y el interés en hacer ejercicio.

Las redes sociales me muestran comerciales donde venden comida poco saludable y estilos de vida sedentarios.

La falta de dinero para pagar gimnasios o equipos deportivos puede hacer que no haga ejercicio.''',
              ),

              _buildInfoCard(
                'Factores contribuyentes al sedentarismo',
                '''El uso del celular y la computadora hace que pase mucho tiempo sentado, lo cual afecta mi salud si no me muevo lo suficiente.

Cuando hay menos tiempo para educación física en la escuela o para jugar en el recreo, se reduce la oportunidad de mantenerse activo.

La influencia de amigos que pasan mucho tiempo sentados puede hacer que siga su ejemplo.''',
              ),

              _buildInfoCard(
                'Consecuencias a largo plazo',
                '''Estar inactivo ahora podría afectar mi estado de ánimo en el futuro, causando tristeza o ansiedad.

Estar inactivo la mayor parte del tiempo puede provocar sobrepeso y ser causa de problemas graves del corazón y diabetes.

No moverte lo suficiente puede ser dañino para tus huesos y músculos, haciéndolos más débiles y aumentando el riesgo de lesiones.

Ser inactivo y sedentario en la juventud podría repercutir en mi incapacidad para realizar actividades básicas cuando sea adulto.

Entender cómo la actividad física mejora mi estado de ánimo y reduce el estrés me ayuda a sentirme mejor tanto física como emocionalmente.

Generar un ambiente donde la motivación y el apoyo me permitan sentirme cómodo y con ganas de mantenerme activo.''',
              ),

              _buildInfoCard(
                'Consejos y Estrategias para Combatir el Sedentarismo',
                '''Practicar deportes con amigos puede hacer que me sienta mejor conmigo mismo y me divierta más mientras hago ejercicio.

Salir a caminar o andar en bicicleta con amigos es una excelente manera de pasar el tiempo juntos mientras nos mantenemos activos y saludables.

Tener clases de ejercicio gratuitas o económicas en la escuela o en lugares cercanos puede darme opciones accesibles para mantenerme activo y saludable.''',
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../welcome_screen.dart';

class ConfiguracionScreen extends StatefulWidget {
  const ConfiguracionScreen({super.key});

  @override
  State<ConfiguracionScreen> createState() => _ConfiguracionScreenState();
}

class _ConfiguracionScreenState extends State<ConfiguracionScreen> {
  // Constantes para estilos y assets
  static const _backgroundColor = Color(0xFFE3F2FD);
  static const _appBarColor = Color(0xFF004C91);
  static const _avatarSize = 80.0;
  static const _buttonPadding = EdgeInsets.symmetric(horizontal: 40, vertical: 12);

  // Controladores y estado
  final User? _user = FirebaseAuth.instance.currentUser;
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  // Datos del avatar
  int _headIndex = 0;
  int _bodyIndex = 0;
  int _outfitIndex = 0;
  String _nombreUsuario = 'Cargando...';

  // Listas de assets del avatar
  static const _heads = [
    'assets/avatar/cabeza1.png',
    'assets/avatar/cabeza2.png',
    'assets/avatar/cabeza3.png',
  ];

  static const _bodies = [
    'assets/avatar/cuerpo1.png',
    'assets/avatar/cuerpo2.png',
    'assets/avatar/cuerpo3.png',
  ];

  static const _outfits = [
    'assets/avatar/pies1.png',
    'assets/avatar/pies2.png',
    'assets/avatar/pies3.png',
  ];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    setState(() => _isLoading = true);

    try {
      final uid = _user?.uid;
      if (uid == null) {
        setState(() => _nombreUsuario = 'Usuario no autenticado');
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('usuarios')
          .doc(uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        setState(() {
          _nombreUsuario = data['nombre_usuario'] ?? 'Sin nombre';
          _headIndex = _getIndexFromAsset(_heads, data['head']);
          _bodyIndex = _getIndexFromAsset(_bodies, data['body']);
          _outfitIndex = _getIndexFromAsset(_outfits, data['outfit']);
        });
      } else {
        setState(() => _nombreUsuario = 'Usuario no encontrado');
      }
    } catch (e) {
      setState(() => _nombreUsuario = 'Error al cargar datos');
      _showSnackBar('Error al cargar datos del usuario: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  int _getIndexFromAsset(List<String> list, String? asset) {
    if (asset == null) return 0;
    final index = list.indexOf(asset);
    return index >= 0 ? index : 0;
  }

  void _logout() async {
    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const WelcomeScreen()),
            (route) => false,
      );
    } catch (e) {
      _showSnackBar('Error al cerrar sesión: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _guardarAvatar() async {
    setState(() => _isLoading = true);
    try {
      final uid = _user?.uid;
      if (uid != null) {
        await FirebaseFirestore.instance.collection('usuarios').doc(uid).update({
          'head': _heads[_headIndex],
          'body': _bodies[_bodyIndex],
          'outfit': _outfits[_outfitIndex],
        });
        _showSnackBar('Avatar actualizado con éxito');
      }
    } catch (e) {
      _showSnackBar('Error al actualizar avatar: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _guardarPassword() async {
    if (_newPasswordController.text.isEmpty) {
      _showSnackBar('Por favor ingresa una nueva contraseña');
      return;
    }

    setState(() => _isLoading = true);
    try {
      // Verificar contraseña actual antes de cambiar
      if (_currentPasswordController.text.isNotEmpty) {
        final cred = EmailAuthProvider.credential(
          email: _user!.email!,
          password: _currentPasswordController.text,
        );
        await _user!.reauthenticateWithCredential(cred);
      }

      await _user!.updatePassword(_newPasswordController.text);
      _showSnackBar('Contraseña actualizada con éxito');
      _currentPasswordController.clear();
      _newPasswordController.clear();
    } on FirebaseAuthException catch (e) {
      _showSnackBar('Error: ${e.message ?? 'Error desconocido'}');
    } catch (e) {
      _showSnackBar('Error inesperado: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        title: const Text('Configuración'),
        centerTitle: true,
        backgroundColor: _appBarColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildAvatarSection(),
            const SizedBox(height: 24),
            _buildUsernameSection(),
            const SizedBox(height: 24),
            _buildPasswordSection(),
            const SizedBox(height: 24),
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarSection() {
    return Column(
      children: [
        const Text(
          'Tu avatar',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _buildAvatarPartRow('Cabeza', _heads, _headIndex, (i) => setState(() => _headIndex = i)),
        _buildAvatarPartRow('Cuerpo', _bodies, _bodyIndex, (i) => setState(() => _bodyIndex = i)),
        _buildAvatarPartRow('Vestimenta', _outfits, _outfitIndex, (i) => setState(() => _outfitIndex = i)),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: _guardarAvatar,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: _buttonPadding,
          ),
          child: const Text('Guardar Avatar', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildAvatarPartRow(String label, List<String> parts, int index, ValueChanged<int> onChange) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_left),
                onPressed: () => onChange((index - 1 + parts.length) % parts.length),
              ),
              Image.asset(parts[index], width: _avatarSize),
              IconButton(
                icon: const Icon(Icons.arrow_right),
                onPressed: () => onChange((index + 1) % parts.length),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildUsernameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tu nombre de usuario',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
        const SizedBox(height: 4),
        SelectableText(
          _nombreUsuario,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordSection() {
    return Column(
      children: [
        TextFormField(
          controller: _currentPasswordController,
          obscureText: !_isPasswordVisible,
          decoration: InputDecoration(
            labelText: 'Contraseña actual',
            suffixIcon: IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _newPasswordController,
          obscureText: !_isPasswordVisible,
          decoration: const InputDecoration(
            labelText: 'Nueva contraseña',
          ),
          validator: (value) {
            if (value != null && value.length < 6) {
              return 'La contraseña debe tener al menos 6 caracteres';
            }
            return null;
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _guardarPassword,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            padding: _buttonPadding,
          ),
          child: const Text('Guardar Contraseña', style: TextStyle(fontSize: 16)),
        ),
      ],
    );
  }

  Widget _buildLogoutButton() {
    return Center(
      child: TextButton(
        onPressed: _logout,
        child: const Text(
          'Cerrar sesión',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
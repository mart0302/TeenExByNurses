import 'package:flutter/material.dart';

class AgregarNotaScreen extends StatefulWidget {
  final DateTime selectedDay;
  const AgregarNotaScreen({super.key, required this.selectedDay});

  @override
  State<AgregarNotaScreen> createState() => _AgregarNotaScreenState();
}

class _AgregarNotaScreenState extends State<AgregarNotaScreen> {
  final TextEditingController _controller = TextEditingController();

  void _guardarNota() {
    final nota = _controller.text.trim();
    if (nota.isNotEmpty) {
      Navigator.pop(context, nota); // Regresa la nota como resultado
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Agregar Nota"),
        backgroundColor: const Color(0xFF004C91),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              "Agregar nota para: ${widget.selectedDay.day}/${widget.selectedDay.month}/${widget.selectedDay.year}",
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _controller,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: "Escribe la nota aquí...",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _guardarNota,
              icon: const Icon(Icons.save),
              label: const Text("Guardar Nota"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            )
          ],
        ),
      ),
    );
  }
}

// PantallaPlanificacion.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';

class PantallaPlanificacion extends StatefulWidget {
  const PantallaPlanificacion({super.key});

  @override
  State<PantallaPlanificacion> createState() => _PantallaPlanificacionState();
}

class _PantallaPlanificacionState extends State<PantallaPlanificacion> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<String, List<String>> _notasPorDia = {};
  final _controller = TextEditingController();
  bool _isLoading = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadNotas();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadNotas() async {
    setState(() => _isLoading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('planificaciones')
          .doc(uid)
          .get();

      if (snapshot.exists) {
        final data = snapshot.data()!;
        setState(() {
          _notasPorDia = Map<String, List<String>>.from(
            data.map((key, value) => MapEntry(key, List<String>.from(value))),
          );
        });
      }
    } catch (e) {
      _showSnackBar('Error cargando notas: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _guardarNotas() async {
    setState(() => _isLoading = true);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('planificaciones')
          .doc(uid)
          .set(_notasPorDia);
    } catch (e) {
      _showSnackBar('Error guardando notas: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  void _mostrarBurbujaNotas(String fecha) {
    final notas = _notasPorDia[fecha] ?? [];

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Notas del $fecha',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Color(0xFF004C91),
                ),
              ),
              const SizedBox(height: 16),
              if (notas.isEmpty)
                const Text(
                  'No hay notas para este día',
                  style: TextStyle(color: Colors.grey),
                )
              else
                ...notas.map((nota) => ListTile(
                  leading: const Icon(Icons.circle, size: 8, color: Color(0xFF004C91)),
                  title: Text(nota),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                    onPressed: () => _confirmarEliminarNota(fecha, nota),
                  ),
                )),
              const Divider(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton.icon(
                    icon: const Icon(Icons.add, color: Color(0xFF004C91)),
                    label: const Text('Agregar', style: TextStyle(color: Color(0xFF004C91))),
                    onPressed: () {
                      Navigator.pop(context);
                      _agregarNota(fecha);
                    },
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.close, color: Colors.grey),
                    label: const Text('Cerrar', style: TextStyle(color: Colors.grey)),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmarEliminarNota(String fecha, String nota) async {
    final confirm = await showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar nota'),
        content: const Text('¿Estás seguro de eliminar esta nota?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() {
        _notasPorDia[fecha]!.remove(nota);
        if (_notasPorDia[fecha]!.isEmpty) {
          _notasPorDia.remove(fecha);
        }
      });
      await _guardarNotas();
      await _loadNotas(); // 🔁 Actualiza para reflejar cambios
      if (mounted) {
        Navigator.pop(context);
        _mostrarBurbujaNotas(fecha);
      }
    }
  }

  void _agregarNota(String fecha) {
    _controller.clear();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Nueva Nota'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _controller,
                  maxLines: 3,
                  decoration: InputDecoration(
                    hintText: 'Ej: Rutina de cardio a las 7am',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey[50],
                  ),
                  onChanged: (value) => setState(() {}),
                ),
                const SizedBox(height: 8),
                if (_controller.text.isEmpty)
                  const Text(
                    'Ingresa una nota para guardar',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF004C91),
                ),
                onPressed: _controller.text.trim().isEmpty
                    ? null
                    : () async {
                  final texto = _controller.text.trim();
                  setState(() {
                    _notasPorDia.putIfAbsent(fecha, () => []).add(texto);
                  });
                  await _guardarNotas();
                  await _loadNotas(); // 🔁 Actualiza lista
                  if (mounted) {
                    Navigator.pop(context);
                    _mostrarBurbujaNotas(fecha);
                  }
                },
                child: const Text('Guardar'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Buscar en notas',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Color(0xFF004C91),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Escribe tu búsqueda...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() => _searchQuery = value);
                    },
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 300,
                    child: ListView(
                      children: _notasPorDia.entries
                          .expand((entry) => entry.value
                          .where((nota) => nota.toLowerCase().contains(_searchQuery.toLowerCase()))
                          .map((nota) => ListTile(
                        title: Text(nota),
                        subtitle: Text(entry.key),
                        onTap: () {
                          final dateParts = entry.key.split('-');
                          final date = DateTime(
                            int.parse(dateParts[0]),
                            int.parse(dateParts[1]),
                            int.parse(dateParts[2]),
                          );
                          setState(() {
                            _selectedDay = date;
                            _focusedDay = date;
                            _searchQuery = '';
                          });
                          Navigator.pop(context);
                          _mostrarBurbujaNotas(entry.key);
                        },
                      )))
                          .toList(),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() => _searchQuery = '');
                      Navigator.pop(context);
                    },
                    child: const Text('Cerrar'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificación de Actividades'),
        backgroundColor: const Color(0xFF004C91),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: _showSearchDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay;
                });

                final fechaKey =
                    "${selectedDay.year}-${selectedDay.month.toString().padLeft(2, '0')}-${selectedDay.day.toString().padLeft(2, '0')}";
                _mostrarBurbujaNotas(fechaKey);
              },
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final dateKey =
                      "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
                  final hasNotes = _notasPorDia.containsKey(dateKey);

                  return hasNotes
                      ? Positioned(
                    bottom: 1,
                    child: Container(
                      width: 16,
                      height: 4,
                      decoration: const BoxDecoration(
                        color: Color(0xFF004C91),
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                      : null;
                },
              ),
              calendarStyle: CalendarStyle(
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.blueAccent),
                ),
                selectedDecoration: BoxDecoration(
                  color: const Color(0xFF004C91).withOpacity(0.5),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF004C91)),
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  color: Color(0xFF004C91),
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon:
                Icon(Icons.chevron_left, color: Color(0xFF004C91)),
                rightChevronIcon:
                Icon(Icons.chevron_right, color: Color(0xFF004C91)),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Selecciona un día para ver o agregar notas de planificación",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF004C91),
        onPressed: () {
          if (_selectedDay != null) {
            final fechaKey =
                "${_selectedDay!.year}-${_selectedDay!.month.toString().padLeft(2, '0')}-${_selectedDay!.day.toString().padLeft(2, '0')}";
            _agregarNota(fechaKey);
          } else {
            _showSnackBar('Selecciona un día primero');
          }
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

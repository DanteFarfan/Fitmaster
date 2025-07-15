import 'package:flutter/material.dart';
// import 'package:myapp/model/usuario.dart';
import 'package:myapp/view/add_exercise.dart';
import 'package:myapp/view/exercise_detail_screen.dart';
import 'package:intl/intl.dart';
import 'package:myapp/database/db_helper.dart';
import 'package:myapp/model/datos_entrenamiento.dart';
import 'package:myapp/view/plan_nutricion.dart';
// import 'package:myapp/view/usuario_screen.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:myapp/view/seguimiento_screen.dart';
import 'package:myapp/view/seguimiento_medidas.dart';
import 'package:myapp/view/crear_plantilla_ejercicio.dart';
import 'package:myapp/model/notas.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<DatosEntrenamiento> entrenamientosDelDia = [];
  DateTime _fechaSeleccionada = DateTime.now();
  Map<DateTime, List<DatosEntrenamiento>> _eventosPorFecha = {};
  bool mostrarCalendario = false;
  List<NotaDia> notasDelDia = [];

  @override
  void initState() {
    super.initState();
    cargarEntrenamientosDelDia();
    cargarEventosCalendario();
    cargarNotasDelDia();
  }

  Future<void> cargarEventosCalendario() async {
    final entrenamientos = await DBHelper.getEntrenamientosUsuarioActivo();
    final Map<DateTime, List<DatosEntrenamiento>> agrupados = {};

    for (final e in entrenamientos) {
      final fecha = DateTime(e.fecha.year, e.fecha.month, e.fecha.day);
      agrupados.putIfAbsent(fecha, () => []).add(e);
    }

    setState(() {
      _eventosPorFecha = agrupados;
    });
  }

  Future<void> cargarEntrenamientosDelDia() async {
    final datos = await DBHelper.getEntrenamientosDelDiaUsuarioActivo(
      _fechaSeleccionada,
    );
    setState(() {
      entrenamientosDelDia = datos;
    });
  }

  Future<void> cargarNotasDelDia() async {
    final usuario = await DBHelper.getUsuarioActivo();
    if (usuario == null) return;
    final notas = await DBHelper.getNotasPorUsuarioYFecha(
      usuario.id,
      _fechaSeleccionada,
    );
    setState(() {
      notasDelDia = notas;
    });
  }

  void _showOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 30.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Opciones',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const Icon(Icons.show_chart, color: Colors.deepPurple),
                title: const Text('Seguimiento'),
                onTap: () {
                  Navigator.pop(context); // Cierra el modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SeguimientoScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.deepPurple,
                ),
                title: const Text('Plan de nutrición'),
                onTap: () {
                  Navigator.pop(context); // Cierra el modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PlanNutricionScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.fitness_center,
                  color: Colors.deepPurple,
                ),
                title: const Text('Plantillas de ejercicio'),
                onTap: () {
                  Navigator.pop(context); // Cierra el modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CrearPlantillaScreen(),
                    ),
                  );
                },
              ),
              ListTile(
                leading: const Icon(Icons.straighten, color: Colors.deepPurple),
                title: const Text('Seguimiento medidas'),
                onTap: () {
                  Navigator.pop(context); // Cierra el modal
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SeguimientoMedidasScreen(),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEntrenamientoTile(DatosEntrenamiento e) {
    List<Widget> detalles = [];
    if (e.series != null) {
      detalles.add(
        Row(
          children: [
            const Icon(Icons.looks_3, size: 18, color: Colors.deepPurple),
            const SizedBox(width: 4),
            Text(
              'Series: ${e.series}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
    if (e.reps != null) {
      detalles.add(
        Row(
          children: [
            const Icon(Icons.repeat, size: 18, color: Colors.deepPurple),
            const SizedBox(width: 4),
            Text(
              'Reps: ${e.reps}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
    if (e.peso != null) {
      detalles.add(
        Row(
          children: [
            const Icon(Icons.line_weight, size: 18, color: Colors.deepPurple),
            const SizedBox(width: 4),
            Text(
              'Peso: ${e.peso} kg',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
    if (e.tiempo != null && e.tiempo!.isNotEmpty) {
      detalles.add(
        Row(
          children: [
            const Icon(Icons.timer, size: 18, color: Colors.deepPurple),
            const SizedBox(width: 4),
            Text(
              'Tiempo: ${e.tiempo} min',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }
    if (e.distancia != null) {
      detalles.add(
        Row(
          children: [
            const Icon(
              Icons.directions_run,
              size: 18,
              color: Colors.deepPurple,
            ),
            const SizedBox(width: 4),
            Text(
              'Distancia: ${e.distancia} km',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.deepPurple),
        title: Text(
          e.titulo,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              e.descripcion,
              style: const TextStyle(fontSize: 15, color: Colors.black87),
            ),
            const SizedBox(height: 6),
            if (detalles.isNotEmpty)
              Wrap(spacing: 12, runSpacing: 4, children: detalles)
            else
              const Text(
                'Sin detalles registrados',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
        isThreeLine: true,
        onTap: () async {
          final resultado = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ExerciseDetailScreen(entrenamiento: e),
            ),
          );
          if (resultado == true) {
            await cargarEntrenamientosDelDia();
            await cargarEventosCalendario();
          }
        },
      ),
    );
  }

  Future<void> _agregarOEditarNota({NotaDia? notaEditar}) async {
    final usuario = await DBHelper.getUsuarioActivo();
    if (usuario == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para agregar o editar notas.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }
    final controller = TextEditingController(text: notaEditar?.texto ?? '');
    String? errorTexto;
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: Text(
                    notaEditar == null ? 'Agregar nota' : 'Editar nota',
                  ),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: controller,
                        maxLines: 5,
                        decoration: const InputDecoration(
                          labelText: 'Escribe tu nota del día',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      if (errorTexto != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            errorTexto ?? '',
                            style: const TextStyle(color: Colors.red),
                          ),
                        ),
                    ],
                  ),
                  actions: [
                    if (notaEditar != null)
                      TextButton(
                        onPressed: () async {
                          final confirmDelete = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Eliminar nota'),
                                  content: const Text(
                                    '¿Seguro que deseas eliminar esta nota? Esta acción no se puede deshacer.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed:
                                          () => Navigator.pop(context, false),
                                      child: const Text('Cancelar'),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.red,
                                      ),
                                      onPressed:
                                          () => Navigator.pop(context, true),
                                      child: const Text('Eliminar'),
                                    ),
                                  ],
                                ),
                          );
                          if (confirmDelete == true) {
                            await DBHelper.deleteNota(notaEditar.id!);
                            Navigator.pop(context, false);
                            await cargarNotasDelDia();
                          }
                        },
                        child: const Text(
                          'Eliminar',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        if (controller.text.trim().isEmpty) {
                          setStateDialog(() {
                            errorTexto =
                                'La nota no puede estar vacía ni contener solo espacios.';
                          });
                          return;
                        }
                        if (notaEditar == null) {
                          await DBHelper.insertNota(
                            NotaDia(
                              idUsuario: usuario.id,
                              texto: controller.text.trim(),
                              fecha: DateTime(
                                _fechaSeleccionada.year,
                                _fechaSeleccionada.month,
                                _fechaSeleccionada.day,
                              ),
                            ),
                          );
                        } else {
                          await DBHelper.updateNota(
                            NotaDia(
                              id: notaEditar.id,
                              idUsuario: usuario.id,
                              texto: controller.text.trim(),
                              fecha: notaEditar.fecha,
                            ),
                          );
                        }
                        Navigator.pop(context, true);
                        await cargarNotasDelDia();
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
          ),
    );
    if (confirm == true) {
      await cargarNotasDelDia();
    }
  }

  @override
  Widget build(BuildContext context) {
    final fechaFormateada = DateFormat('dd/MM/yyyy').format(_fechaSeleccionada);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 2,
        title: const Text(
          'FitMaster',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.black),
            tooltip: 'Iniciar sesión',
            onPressed: () async {
              final usuario = await DBHelper.getUsuarioActivo();
              if (usuario != null) {
                Navigator.pushNamed(context, '/usuario', arguments: usuario);
              } else {
                Navigator.pushNamed(context, '/login');
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black),
            onPressed: () => _showOptions(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  mostrarCalendario = !mostrarCalendario;
                });
              },
              icon: Icon(
                mostrarCalendario ? Icons.expand_less : Icons.expand_more,
                color: Colors.white,
              ),
              label: Text(
                mostrarCalendario ? 'Ocultar Calendario' : 'Mostrar Calendario',
                style: const TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple.shade400,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (mostrarCalendario)
              TableCalendar(
                locale: 'es_ES',
                firstDay: DateTime(2000),
                lastDay: DateTime(2100),
                focusedDay: _fechaSeleccionada,
                selectedDayPredicate:
                    (day) => isSameDay(_fechaSeleccionada, day),
                onDaySelected: (selectedDay, focusedDay) async {
                  setState(() {
                    _fechaSeleccionada = selectedDay;
                  });
                  await cargarEntrenamientosDelDia();
                  await cargarNotasDelDia(); // <-- Agrega esta línea
                },
                eventLoader: (day) {
                  final key = DateTime(day.year, day.month, day.day);
                  return _eventosPorFecha[key] ?? [];
                },
                calendarStyle: const CalendarStyle(
                  todayDecoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                  selectedDecoration: BoxDecoration(
                    color: Colors.deepPurpleAccent,
                    shape: BoxShape.circle,
                  ),
                  markerDecoration: BoxDecoration(
                    color: Colors.deepPurple,
                    shape: BoxShape.circle,
                  ),
                ),
                availableCalendarFormats: const {CalendarFormat.month: 'Mes'},
              ),
            const SizedBox(height: 10),
            Text(
              'Entrenamientos del ${fechaFormateada}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            entrenamientosDelDia.isEmpty
                ? const Text(
                  'No se registraron entrenamientos hoy.',
                  style: TextStyle(color: Colors.grey),
                )
                : Expanded(
                  child: ListView.builder(
                    itemCount: entrenamientosDelDia.length,
                    itemBuilder: (context, index) {
                      final e = entrenamientosDelDia[index];
                      return _buildEntrenamientoTile(e);
                    },
                  ),
                ),
            const SizedBox(height: 20),
            if (notasDelDia.isNotEmpty)
              Card(
                color: Colors.yellow[50],
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  leading: const Icon(Icons.note, color: Colors.deepPurple),
                  title: Text(
                    notasDelDia.length == 1
                        ? notasDelDia.first.texto
                        : 'Ver todas las notas del día',
                    style: const TextStyle(fontSize: 16),
                  ),
                  subtitle: Text(
                    notasDelDia.length == 1
                        ? 'Nota del día'
                        : '${notasDelDia.length} notas registradas',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  trailing: IconButton(
                    icon: Icon(
                      notasDelDia.length == 1 ? Icons.edit : Icons.list,
                      color: Colors.deepPurple,
                    ),
                    onPressed: () {
                      if (notasDelDia.length == 1) {
                        _agregarOEditarNota(notaEditar: notasDelDia.first);
                      } else {
                        showDialog(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text('Notas del día'),
                                content: SizedBox(
                                  width: double.maxFinite,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: notasDelDia.length,
                                    itemBuilder: (context, i) {
                                      final nota = notasDelDia[i];
                                      return ListTile(
                                        leading: const Icon(
                                          Icons.note,
                                          color: Colors.deepPurple,
                                        ),
                                        title: Text(nota.texto),
                                        trailing: IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.deepPurple,
                                          ),
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _agregarOEditarNota(
                                              notaEditar: nota,
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cerrar'),
                                  ),
                                ],
                              ),
                        );
                      }
                    },
                  ),
                  onTap: () {
                    if (notasDelDia.length > 1) {
                      showDialog(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Notas del día'),
                              content: SizedBox(
                                width: double.maxFinite,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: notasDelDia.length,
                                  itemBuilder: (context, i) {
                                    final nota = notasDelDia[i];
                                    return ListTile(
                                      leading: const Icon(
                                        Icons.note,
                                        color: Colors.deepPurple,
                                      ),
                                      title: Text(nota.texto),
                                      trailing: IconButton(
                                        icon: const Icon(
                                          Icons.edit,
                                          color: Colors.deepPurple,
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                          _agregarOEditarNota(notaEditar: nota);
                                        },
                                      ),
                                    );
                                  },
                                ),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cerrar'),
                                ),
                              ],
                            ),
                      );
                    }
                  },
                ),
              ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.note_add, color: Colors.white),
                label: const Text(
                  'Agregar nota del día',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _agregarOEditarNota(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Añadir ejercicio',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade500,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                onPressed: () async {
                  final resultado = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) => AddExerciseScreen(
                            fechaSeleccionada: _fechaSeleccionada,
                          ),
                    ),
                  );
                  if (resultado == true) {
                    await cargarEntrenamientosDelDia();
                    await cargarEventosCalendario();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

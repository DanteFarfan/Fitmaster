import 'package:flutter/material.dart';
import 'package:myapp/database/db_helper.dart';
import 'package:myapp/model/datos_entrenamiento.dart';
import 'package:myapp/model/seguimiento.dart';
import 'package:myapp/model/plantilla_ejercicio.dart';

class AddExerciseScreen extends StatefulWidget {
  final DateTime? fechaSeleccionada;

  const AddExerciseScreen({super.key, this.fechaSeleccionada});

  @override
  _AddExerciseScreenState createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _seriesController = TextEditingController();
  final _distanceController = TextEditingController();
  final _timeController = TextEditingController();

  List<PlantillaEjercicio> _plantillas = [];
  PlantillaEjercicio? _plantillaSeleccionada;

  // Controla si los campos se muestran (solo si hay plantilla seleccionada)
  bool get _usarPlantilla => _plantillaSeleccionada != null;

  @override
  void initState() {
    super.initState();
    _cargarPlantillas();
  }

  Future<void> _cargarPlantillas() async {
    final plantillas = await DBHelper.getPlantillas();
    setState(() {
      _plantillas = plantillas;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _weightController.dispose();
    _repsController.dispose();
    _seriesController.dispose();
    _distanceController.dispose();
    _timeController.dispose();
    super.dispose();
  }

  void _seleccionarPlantilla() async {
    final seleccionada = await showDialog<PlantillaEjercicio>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Seleccionar plantilla'),
          content: SizedBox(
            width: double.maxFinite,
            child:
                _plantillas.isEmpty
                    ? const Text('No hay plantillas registradas.')
                    : ListView.builder(
                      shrinkWrap: true,
                      itemCount: _plantillas.length,
                      itemBuilder: (context, index) {
                        final plantilla = _plantillas[index];
                        return ListTile(
                          leading: const Icon(
                            Icons.list_alt,
                            color: Colors.deepPurple,
                          ),
                          title: Text(plantilla.nombre),
                          onTap: () => Navigator.pop(context, plantilla),
                        );
                      },
                    ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
          ],
        );
      },
    );
    if (seleccionada != null) {
      setState(() {
        _plantillaSeleccionada = seleccionada;
        _nameController.text = seleccionada.nombre;
        _seriesController.clear();
        _repsController.clear();
        _weightController.clear();
        _distanceController.clear();
        _timeController.clear();
      });
    }
  }

  void _saveExercise() async {
    if (_formKey.currentState!.validate()) {
      final usuario = await DBHelper.getUsuarioActivo();
      if (usuario == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No hay usuario activo')),
        );
        return;
      }

      // Validar nombre y descripción
      if (_nameController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'El nombre no puede estar vacío o solo contener espacios.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_descriptionController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La descripción no puede estar vacía o solo contener espacios.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final errors = <String>[];
      bool algunDatoValido = false;
      bool empiezaConCero(String s) =>
          s.length > 1 &&
          s.trim().startsWith('0') &&
          !s.trim().startsWith('0.');

      // Series
      final seriesRaw = _seriesController.text;
      final seriesTrim = seriesRaw.trim();
      final series = seriesTrim.isEmpty ? null : int.tryParse(seriesTrim);
      if (seriesRaw.isNotEmpty) {
        if (seriesTrim.isEmpty) {
          errors.add('El campo "Series" no puede ser solo espacios.');
        } else if (empiezaConCero(seriesTrim)) {
          errors.add('El campo "Series" tiene un valor inválido.');
        } else if (series == null) {
          errors.add('El campo "Series" debe ser un número entero.');
        } else if (series <= 0) {
          errors.add('El campo "Series" debe ser mayor que cero.');
        } else if (series < 1) {
          errors.add('El campo "Series" debe ser al menos 1.');
        } else {
          algunDatoValido = true;
        }
      }

      // Repeticiones
      final repsRaw = _repsController.text;
      final repsTrim = repsRaw.trim();
      final reps = repsTrim.isEmpty ? null : int.tryParse(repsTrim);
      if (repsRaw.isNotEmpty) {
        if (repsTrim.isEmpty) {
          errors.add('El campo "Repeticiones" no puede ser solo espacios.');
        } else if (empiezaConCero(repsTrim)) {
          errors.add('El campo "Repeticiones" tiene un valor inválido.');
        } else if (reps == null) {
          errors.add('El campo "Repeticiones" debe ser un número entero.');
        } else if (reps <= 0) {
          errors.add('El campo "Repeticiones" debe ser mayor que cero.');
        } else if (reps < 1) {
          errors.add('El campo "Repeticiones" debe ser al menos 1.');
        } else {
          algunDatoValido = true;
        }
      }

      // Peso (permitir decimales mayores a 0)
      final pesoRaw = _weightController.text;
      final pesoTrim = pesoRaw.trim();
      final peso = pesoTrim.isEmpty ? null : double.tryParse(pesoTrim);
      if (pesoRaw.isNotEmpty) {
        if (pesoTrim.isEmpty) {
          errors.add('El campo "Peso" no puede ser solo espacios.');
        } else if (empiezaConCero(pesoTrim)) {
          errors.add('El campo "Peso" tiene un valor inválido.');
        } else if (peso == null) {
          errors.add('El campo "Peso" debe ser un número.');
        } else if (peso <= 0) {
          errors.add('El campo "Peso" debe ser mayor que cero.');
        } else {
          algunDatoValido = true;
        }
      }

      // Tiempo (permitir decimales mayores a 0)
      final tiempoRaw = _timeController.text;
      final tiempoTrim = tiempoRaw.trim();
      final tiempo = tiempoTrim.isEmpty ? null : tiempoTrim;
      final tiempoDouble = tiempo != null ? double.tryParse(tiempo) : null;
      if (tiempoRaw.isNotEmpty) {
        if (tiempoTrim.isEmpty) {
          errors.add('El campo "Tiempo" no puede ser solo espacios.');
        } else if (empiezaConCero(tiempoTrim)) {
          errors.add('El campo "Tiempo" tiene un valor inválido.');
        } else if (tiempoDouble == null) {
          errors.add('El campo "Tiempo" debe ser un número.');
        } else if (tiempoDouble <= 0) {
          errors.add('El campo "Tiempo" debe ser mayor que cero.');
        } else if (tiempoDouble < 1) {
          errors.add('El campo "Tiempo" debe ser al menos 1 minuto.');
        } else {
          algunDatoValido = true;
        }
      }

      // Distancia
      final distanciaRaw = _distanceController.text;
      final distanciaTrim = distanciaRaw.trim();
      final distancia =
          distanciaTrim.isEmpty ? null : double.tryParse(distanciaTrim);
      if (distanciaRaw.isNotEmpty) {
        if (distanciaTrim.isEmpty) {
          errors.add('El campo "Distancia" no puede ser solo espacios.');
        } else if (empiezaConCero(distanciaTrim)) {
          errors.add('El campo "Distancia" tiene un valor inválido.');
        } else if (distancia == null) {
          errors.add('El campo "Distancia" debe ser un número.');
        } else if (distancia <= 0) {
          errors.add('El campo "Distancia" debe ser mayor que cero.');
        } else {
          algunDatoValido = true;
        }
      }

      // Validación adicional: si algún campo obligatorio de la plantilla está vacío
      if (_usarPlantilla && _plantillaSeleccionada != null) {
        final plantilla = _plantillaSeleccionada!;
        if (plantilla.trackSeries && _seriesController.text.trim().isEmpty) {
          errors.add('Debes ingresar el número de series.');
        }
        if (plantilla.trackReps && _repsController.text.trim().isEmpty) {
          errors.add('Debes ingresar el número de repeticiones.');
        }
        if (plantilla.trackPeso && _weightController.text.trim().isEmpty) {
          errors.add('Debes ingresar el peso.');
        }
        if (plantilla.trackDistancia && _distanceController.text.trim().isEmpty) {
          errors.add('Debes ingresar la distancia.');
        }
        if (plantilla.trackTiempo && _timeController.text.trim().isEmpty) {
          errors.add('Debes ingresar el tiempo.');
        }
      }

      if (!algunDatoValido) {
        errors.add(
          'Debes ingresar al menos un dato válido en los detalles del entrenamiento.',
        );
      }

      if (errors.isNotEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Errores en el formulario'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: errors.map((e) => Text('• $e')).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cerrar'),
              ),
            ],
          ),
        );
        return;
      }

      // Permitir múltiples ejercicios con el mismo nombre en el mismo día,
      // pero solo si la hora es diferente (o simplemente permitir duplicados)
      // Por lo tanto, eliminamos la validación de unicidad por nombre y fecha.

      final nuevo = DatosEntrenamiento(
        idUsuario: usuario.id,
        titulo: _nameController.text.trim(),
        descripcion: _descriptionController.text.trim(),
        fecha: widget.fechaSeleccionada ?? DateTime.now(),
        series: series,
        reps: reps,
        peso: peso,
        tiempo: tiempo,
        distancia: distancia,
        idPlantilla: _plantillaSeleccionada?.id,
      );

      // Inserta el ejercicio y obtén su ID
      final ejercicioId = await DBHelper.insert(nuevo);

      // Crear registros de seguimiento para los campos relevantes
      final now = DateTime.now().toIso8601String();
      if (nuevo.series != null) {
        await DBHelper.insertSeguimiento(
          Seguimiento(
            idUsuario: usuario.id,
            idEntrenamiento: ejercicioId,
            fechaEntrenamiento: now,
            tipoRecord: 'series',
            valorRecord: nuevo.series!.toDouble(),
          ),
        );
      }
      if (nuevo.reps != null) {
        await DBHelper.insertSeguimiento(
          Seguimiento(
            idUsuario: usuario.id,
            idEntrenamiento: ejercicioId,
            fechaEntrenamiento: now,
            tipoRecord: 'reps',
            valorRecord: nuevo.reps!.toDouble(),
          ),
        );
      }
      if (nuevo.peso != null) {
        await DBHelper.insertSeguimiento(
          Seguimiento(
            idUsuario: usuario.id,
            idEntrenamiento: ejercicioId,
            fechaEntrenamiento: now,
            tipoRecord: 'peso',
            valorRecord: nuevo.peso!,
          ),
        );
      }
      if (nuevo.tiempo != null && double.tryParse(nuevo.tiempo!) != null) {
        await DBHelper.insertSeguimiento(
          Seguimiento(
            idUsuario: usuario.id,
            idEntrenamiento: ejercicioId,
            fechaEntrenamiento: now,
            tipoRecord: 'tiempo',
            valorRecord: double.parse(nuevo.tiempo!),
          ),
        );
      }
      if (nuevo.distancia != null) {
        await DBHelper.insertSeguimiento(
          Seguimiento(
            idUsuario: usuario.id,
            idEntrenamiento: ejercicioId,
            fechaEntrenamiento: now,
            tipoRecord: 'distancia',
            valorRecord: nuevo.distancia!,
          ),
        );
      }

      Navigator.pop(context, true);
    }
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
      filled: true,
      fillColor: Colors.grey[100],
    );
  }

  @override
  Widget build(BuildContext context) {
    final plantilla = _plantillaSeleccionada;

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Añadir Ejercicio',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Información del ejercicio',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: _buildInputDecoration(
                  'Nombre',
                  Icons.fitness_center,
                ),
                enabled: false, // No editable
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Este campo es obligatorio'
                            : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: _buildInputDecoration('Descripción', Icons.notes),
              ),
              const SizedBox(height: 30),
              const Text(
                'Detalles del entrenamiento',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              // Eliminar campo de orden:
              // TextFormField(
              //   controller: _orderController,
              //   decoration: _buildInputDecoration(
              //     'Orden',
              //     Icons.format_list_numbered,
              //   ),
              //   keyboardType: TextInputType.number,
              // ),
              // const SizedBox(height: 16),

              // Botón para seleccionar plantilla
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.view_list, color: Colors.white),
                  label: Text(
                    plantilla == null
                        ? 'Usar plantilla'
                        : 'Plantilla: ${plantilla.nombre}',
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade300,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _seleccionarPlantilla,
                ),
              ),
              const SizedBox(height: 16),

              // Solo muestra los campos si hay plantilla seleccionada, según la plantilla
              if (_usarPlantilla && plantilla!.trackSeries) ...[
                TextFormField(
                  controller: _seriesController,
                  decoration: _buildInputDecoration('Series', Icons.looks_3),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],
              if (_usarPlantilla && plantilla!.trackReps) ...[
                TextFormField(
                  controller: _repsController,
                  decoration: _buildInputDecoration(
                    'Repeticiones',
                    Icons.repeat,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],
              if (_usarPlantilla && plantilla!.trackPeso) ...[
                TextFormField(
                  controller: _weightController,
                  decoration: _buildInputDecoration(
                    'Peso (kg)',
                    Icons.line_weight,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],
              if (_usarPlantilla && plantilla!.trackDistancia) ...[
                TextFormField(
                  controller: _distanceController,
                  decoration: _buildInputDecoration(
                    'Distancia (km)',
                    Icons.directions_run,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],
              if (_usarPlantilla && plantilla!.trackTiempo) ...[
                TextFormField(
                  controller: _timeController,
                  decoration: _buildInputDecoration(
                    'Tiempo (min)',
                    Icons.timer,
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
              ],

              // Si no hay plantilla seleccionada, no muestra ningún campo extra
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Guardar ejercicio',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _saveExercise,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

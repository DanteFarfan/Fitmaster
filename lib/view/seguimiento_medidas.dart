import 'package:flutter/material.dart';
import 'package:myapp/model/seguimiento_medidas.dart';
import 'package:myapp/database/db_helper.dart';
import 'package:myapp/model/usuario.dart';

class SeguimientoMedidasScreen extends StatefulWidget {
  const SeguimientoMedidasScreen({super.key});

  @override
  State<SeguimientoMedidasScreen> createState() =>
      _SeguimientoMedidasScreenState();
}

enum TipoMedida { peso, longitud }

class _SeguimientoMedidasScreenState extends State<SeguimientoMedidasScreen> {
  List<MedidaPeso> historialPeso = [];
  List<MedidaLongitud> historialLongitud = [];
  TipoMedida? _tipoSeleccionado;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration.zero, _mostrarSelectorTipo);
  }

  Future<void> _mostrarSelectorTipo() async {
    final seleccion = await showDialog<TipoMedida>(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => WillPopScope(
            onWillPop: () async {
              Navigator.of(context).pop(); // Cierra el diálogo
              Navigator.of(context).maybePop(); // Regresa al HomeScreen
              return false; // Evita el cierre automático del diálogo
            },
            child: AlertDialog(
              title: const Text('Selecciona el tipo de medida'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    icon: const Icon(Icons.monitor_weight),
                    label: const Text('Medidas de peso'),
                    onPressed: () => Navigator.pop(context, TipoMedida.peso),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.straighten),
                    label: const Text('Medidas de longitud'),
                    onPressed:
                        () => Navigator.pop(context, TipoMedida.longitud),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    Navigator.of(context).maybePop();
                  },
                  child: const Text('Cancelar'),
                ),
              ],
            ),
          ),
    );
    if (seleccion != null) {
      setState(() {
        _tipoSeleccionado = seleccion;
      });
      _cargarHistorial();
    }
  }

  Future<void> _cargarHistorial() async {
    if (_tipoSeleccionado == TipoMedida.peso) {
      final medidasPeso = await DBHelper.getMedidasPesoUsuarioActivo();
      setState(() {
        historialPeso = medidasPeso;
      });
    } else if (_tipoSeleccionado == TipoMedida.longitud) {
      final medidasLongitud = await DBHelper.getMedidasLongitudUsuarioActivo();
      setState(() {
        historialLongitud = medidasLongitud;
      });
    }
  }

  Future<void> _agregarMedidaPeso({MedidaPeso? medidaEditar}) async {
    final usuario = await DBHelper.getUsuarioActivo();
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para agregar medidas.'),
        ),
      );
      return;
    }
    final nombreController = TextEditingController(
      text: medidaEditar?.nombre ?? '',
    );
    final descripcionController = TextEditingController(
      text: medidaEditar?.descripcion ?? '',
    );
    final valorController = TextEditingController(
      text: medidaEditar != null ? medidaEditar.valor.toString() : '',
    );
    String unidad = medidaEditar?.unidad ?? 'kg'; // default a kg

    String? errorNombre;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: Text(
                    medidaEditar == null ? 'Nueva medida' : 'Actualizar medida',
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre',
                            errorText: errorNombre,
                          ),
                          enabled: medidaEditar == null,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descripcionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: valorController,
                          decoration: const InputDecoration(labelText: 'Valor'),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: unidad,
                          items: const [
                            DropdownMenuItem(
                              value: 'kg',
                              child: Text('Kilogramos (kg)'),
                            ),
                            DropdownMenuItem(
                              value: 'lb',
                              child: Text('Libras (lb)'),
                            ),
                          ],
                          onChanged:
                              medidaEditar == null
                                  ? (value) {
                                    if (value != null)
                                      setStateDialog(() => unidad = value);
                                  }
                                  : null, // Deshabilita si es edición
                          decoration: const InputDecoration(
                            labelText: 'Unidad',
                          ),
                          disabledHint: Text(
                            unidad == 'kg'
                                ? 'Kilogramos (kg)'
                                : unidad == 'lb'
                                ? 'Libras (lb)'
                                : unidad,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    if (medidaEditar != null)
                      TextButton(
                        onPressed: () async {
                          final confirmDelete = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Eliminar medida'),
                                  content: const Text(
                                    '¿Seguro que deseas eliminar esta medida y todo su historial? Esta acción no se puede deshacer.',
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
                            final usuario = await DBHelper.getUsuarioActivo();
                            if (usuario != null) {
                              await DBHelper.deleteMedidasPesoPorNombre(
                                usuario.id,
                                medidaEditar.nombre,
                              );
                              Navigator.pop(context, false);
                              _cargarHistorial();
                            }
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
                        final nombre = nombreController.text.trim();
                        final valor = valorController.text.trim();
                        double? valorNum = double.tryParse(valor);

                        if (nombre.isEmpty || valor.isEmpty) {
                          setStateDialog(() {
                            errorNombre =
                                nombre.isEmpty ? 'Campo requerido' : null;
                          });
                          return;
                        }
                        if (valorNum == null || valorNum < 0) {
                          setStateDialog(() {
                            errorNombre = null;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'El valor no puede ser negativo ni estar vacío.',
                              ),
                            ),
                          );
                          return;
                        }
                        if (medidaEditar == null) {
                          final existe = historialPeso.any(
                            (m) =>
                                m.nombre.toLowerCase() == nombre.toLowerCase(),
                          );
                          if (existe) {
                            setStateDialog(() {
                              errorNombre =
                                  'Ya existe una medida con ese nombre';
                            });
                            return;
                          }
                        }
                        Navigator.pop(context, true);
                      },
                      child: Text(
                        medidaEditar == null ? 'Guardar' : 'Actualizar',
                      ),
                    ),
                  ],
                ),
          ),
    );

    if (confirm == true) {
      final nuevaMedida = MedidaPeso(
        id: null,
        idUsuario: usuario.id,
        nombre: nombreController.text.trim(),
        descripcion: descripcionController.text.trim(),
        valor: double.tryParse(valorController.text.trim()) ?? 0,
        unidad: unidad,
        fecha: DateTime.now(),
      );
      await DBHelper.insertMedidaPeso(nuevaMedida);
      await _cargarHistorial();
      setState(() {});
    }
  }

  Future<void> _agregarMedidaLongitud({MedidaLongitud? medidaEditar}) async {
    final usuario = await DBHelper.getUsuarioActivo();
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para agregar medidas.'),
        ),
      );
      return;
    }
    final nombreController = TextEditingController(
      text: medidaEditar?.nombre ?? '',
    );
    final descripcionController = TextEditingController(
      text: medidaEditar?.descripcion ?? '',
    );
    final valorController = TextEditingController(
      text: medidaEditar != null ? medidaEditar.valor.toString() : '',
    );
    String unidad = medidaEditar?.unidad ?? 'cm'; // default a cm

    String? errorNombre;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: Text(
                    medidaEditar == null ? 'Nueva medida' : 'Actualizar medida',
                  ),
                  content: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextField(
                          controller: nombreController,
                          decoration: InputDecoration(
                            labelText: 'Nombre',
                            errorText: errorNombre,
                          ),
                          enabled: medidaEditar == null,
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: descripcionController,
                          decoration: const InputDecoration(
                            labelText: 'Descripción',
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextField(
                          controller: valorController,
                          decoration: const InputDecoration(labelText: 'Valor'),
                          keyboardType: TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<String>(
                          value: unidad,
                          items: const [
                            DropdownMenuItem(
                              value: 'cm',
                              child: Text('Centímetros (cm)'),
                            ),
                            DropdownMenuItem(
                              value: 'in',
                              child: Text('Pulgadas (in)'),
                            ),
                          ],
                          onChanged:
                              medidaEditar == null
                                  ? (value) {
                                    if (value != null)
                                      setStateDialog(() => unidad = value);
                                  }
                                  : null, // Deshabilita si es edición
                          decoration: const InputDecoration(
                            labelText: 'Unidad',
                          ),
                          disabledHint: Text(
                            unidad == 'cm'
                                ? 'Centímetros (cm)'
                                : unidad == 'in'
                                ? 'Pulgadas (in)'
                                : unidad,
                          ),
                        ),
                      ],
                    ),
                  ),
                  actions: [
                    if (medidaEditar != null)
                      TextButton(
                        onPressed: () async {
                          final confirmDelete = await showDialog<bool>(
                            context: context,
                            builder:
                                (context) => AlertDialog(
                                  title: const Text('Eliminar medida'),
                                  content: const Text(
                                    '¿Seguro que deseas eliminar esta medida y todo su historial? Esta acción no se puede deshacer.',
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
                            final usuario = await DBHelper.getUsuarioActivo();
                            if (usuario != null) {
                              await DBHelper.deleteMedidasLongitudPorNombre(
                                usuario.id,
                                medidaEditar.nombre,
                              );
                              Navigator.pop(context, false);
                              _cargarHistorial();
                            }
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
                        final nombre = nombreController.text.trim();
                        final valor = valorController.text.trim();
                        double? valorNum = double.tryParse(valor);

                        if (nombre.isEmpty || valor.isEmpty) {
                          setStateDialog(() {
                            errorNombre =
                                nombre.isEmpty ? 'Campo requerido' : null;
                          });
                          return;
                        }
                        if (valorNum == null || valorNum < 0) {
                          setStateDialog(() {
                            errorNombre = null;
                          });
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'El valor no puede ser negativo ni estar vacío.',
                              ),
                            ),
                          );
                          return;
                        }
                        if (medidaEditar == null) {
                          final existe = historialLongitud.any(
                            (m) =>
                                m.nombre.toLowerCase() == nombre.toLowerCase(),
                          );
                          if (existe) {
                            setStateDialog(() {
                              errorNombre =
                                  'Ya existe una medida con ese nombre';
                            });
                            return;
                          }
                        }
                        Navigator.pop(context, true);
                      },
                      child: Text(
                        medidaEditar == null ? 'Guardar' : 'Actualizar',
                      ),
                    ),
                  ],
                ),
          ),
    );

    if (confirm == true) {
      final nuevaMedida = MedidaLongitud(
        id: null,
        idUsuario: usuario.id,
        nombre: nombreController.text.trim(),
        descripcion: descripcionController.text.trim(),
        valor: double.tryParse(valorController.text.trim()) ?? 0,
        unidad: unidad,
        fecha: DateTime.now(),
      );
      await DBHelper.insertMedidaLongitud(nuevaMedida);
      await _cargarHistorial();
      setState(() {});
    }
  }

  Future<void> _mostrarHistorialMedidaPeso(MedidaPeso medida) async {
    final usuario = await DBHelper.getUsuarioActivo();
    if (usuario == null) return;

    // Obtén todas las versiones históricas de la medida desde la base de datos
    final db = await DBHelper.getDB();
    final maps = await db.query(
      DBHelper.tablaMedidasPeso,
      where: 'id_usuario = ? AND LOWER(nombre) = ?',
      whereArgs: [usuario.id, medida.nombre.toLowerCase()],
      orderBy: 'fecha DESC',
    );
    final historialMedida = maps.map((e) => MedidaPeso.fromMap(e)).toList();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Historial de "${medida.nombre}"'),
            content: SizedBox(
              width: double.maxFinite,
              child:
                  historialMedida.isEmpty
                      ? const Text('No hay historial para esta medida.')
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: historialMedida.length,
                        itemBuilder: (context, i) {
                          final m = historialMedida[i];
                          return ListTile(
                            title: Text('${m.valor} ${m.unidad}'),
                            subtitle: Text(
                              '${m.descripcion}\nFecha: ${m.fecha.day.toString().padLeft(2, '0')}/${m.fecha.month.toString().padLeft(2, '0')}/${m.fecha.year}',
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

  Future<void> _mostrarHistorialMedidaLongitud(MedidaLongitud medida) async {
    final usuario = await DBHelper.getUsuarioActivo();
    if (usuario == null) return;

    // Obtén todas las versiones históricas de la medida desde la base de datos
    final db = await DBHelper.getDB();
    final maps = await db.query(
      DBHelper.tablaMedidasLongitud,
      where: 'id_usuario = ? AND LOWER(nombre) = ?',
      whereArgs: [usuario.id, medida.nombre.toLowerCase()],
      orderBy: 'fecha DESC',
    );
    final historialMedida = maps.map((e) => MedidaLongitud.fromMap(e)).toList();

    await showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Historial de "${medida.nombre}"'),
            content: SizedBox(
              width: double.maxFinite,
              child:
                  historialMedida.isEmpty
                      ? const Text('No hay historial para esta medida.')
                      : ListView.builder(
                        shrinkWrap: true,
                        itemCount: historialMedida.length,
                        itemBuilder: (context, i) {
                          final m = historialMedida[i];
                          return ListTile(
                            title: Text('${m.valor} ${m.unidad}'),
                            subtitle: Text(
                              '${m.descripcion}\nFecha: ${m.fecha.day.toString().padLeft(2, '0')}/${m.fecha.month.toString().padLeft(2, '0')}/${m.fecha.year}',
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

  @override
  Widget build(BuildContext context) {
    // Colores igual que HomeScreen
    const fondo = Color(0xFFF4F4F4);
    const colorPrincipal = Colors.deepPurple;
    const colorTexto = Colors.black;

    Widget contenido;
    // Verifica si hay usuario activo
    final Future<Usuario?> usuarioActivoFuture = DBHelper.getUsuarioActivo();

    contenido = FutureBuilder<Usuario?>(
      future: usuarioActivoFuture,
      builder: (context, snapshot) {
        final usuarioActivo = snapshot.data;
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (usuarioActivo == null) {
          return const Center(
            child: Text(
              'Debes iniciar sesión para ver o registrar medidas.',
              style: TextStyle(color: Colors.grey),
            ),
          );
        }

        if (_tipoSeleccionado == TipoMedida.peso) {
          final Map<String, MedidaPeso> ultimasMedidasPeso = {};
          for (final m in historialPeso) {
            if (!ultimasMedidasPeso.containsKey(m.nombre) ||
                m.fecha.isAfter(ultimasMedidasPeso[m.nombre]!.fecha)) {
              ultimasMedidasPeso[m.nombre] = m;
            }
          }
          final medidasMostrarPeso =
              ultimasMedidasPeso.values.toList()
                ..sort((a, b) => b.fecha.compareTo(a.fecha));

          return Column(
            children: [
              ElevatedButton.icon(
                onPressed: () => _agregarMedidaPeso(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Agregar medida de peso',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child:
                    medidasMostrarPeso.isEmpty
                        ? const Center(
                          child: Text(
                            'No hay medidas de peso registradas.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                        : ListView.builder(
                          itemCount: medidasMostrarPeso.length,
                          itemBuilder: (context, i) {
                            final m = medidasMostrarPeso[i];
                            return Card(
                              color: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 6,
                              ),
                              child: ListTile(
                                title: Text(
                                  '${m.nombre} (${m.valor} ${m.unidad})',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${m.descripcion}\nFecha: ${m.fecha.day.toString().padLeft(2, '0')}/${m.fecha.month.toString().padLeft(2, '0')}/${m.fecha.year}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons
                                        .update, // Siempre mostrar el icono de actualizar
                                    color: Colors.deepPurple,
                                  ),
                                  onPressed:
                                      () => _agregarMedidaPeso(medidaEditar: m),
                                  tooltip: 'Actualizar',
                                ),
                                onTap: () => _mostrarHistorialMedidaPeso(m),
                              ),
                            );
                          },
                        ),
              ),
            ],
          );
        } else if (_tipoSeleccionado == TipoMedida.longitud) {
          final Map<String, MedidaLongitud> ultimasMedidasLongitud = {};
          for (final m in historialLongitud) {
            if (!ultimasMedidasLongitud.containsKey(m.nombre) ||
                m.fecha.isAfter(ultimasMedidasLongitud[m.nombre]!.fecha)) {
              ultimasMedidasLongitud[m.nombre] = m;
            }
          }
          final medidasMostrarLongitud =
              ultimasMedidasLongitud.values.toList()
                ..sort((a, b) => b.fecha.compareTo(a.fecha));

          return Column(
            children: [
              ElevatedButton.icon(
                onPressed: () => _agregarMedidaLongitud(),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Agregar medida de longitud',
                  style: TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child:
                    medidasMostrarLongitud.isEmpty
                        ? const Center(
                          child: Text(
                            'No hay medidas de longitud registradas.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                        : ListView.builder(
                          itemCount: medidasMostrarLongitud.length,
                          itemBuilder: (context, i) {
                            final m = medidasMostrarLongitud[i];
                            return Card(
                              color: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                              margin: const EdgeInsets.symmetric(
                                horizontal: 0,
                                vertical: 6,
                              ),
                              child: ListTile(
                                title: Text(
                                  '${m.nombre} (${m.valor} ${m.unidad})',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  '${m.descripcion}\nFecha: ${m.fecha.day.toString().padLeft(2, '0')}/${m.fecha.month.toString().padLeft(2, '0')}/${m.fecha.year}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    Icons
                                        .update, // Siempre mostrar el icono de actualizar
                                    color: Colors.deepPurple,
                                  ),
                                  onPressed:
                                      () => _agregarMedidaLongitud(
                                        medidaEditar: m,
                                      ),
                                  tooltip: 'Actualizar',
                                ),
                                onTap: () => _mostrarHistorialMedidaLongitud(m),
                              ),
                            );
                          },
                        ),
              ),
            ],
          );
        } else {
          return const SizedBox.shrink();
        }
      },
    );

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text(
          'Seguimiento de Medidas',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz),
            tooltip: 'Cambiar tipo de medida',
            onPressed: _mostrarSelectorTipo,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
        child: contenido,
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:myapp/database/db_helper.dart';
import 'package:myapp/model/categoria.dart';
import 'package:myapp/model/plantilla_ejercicio.dart';

// Pantalla visual de creación de plantilla de ejercicio (con funcionalidad)
class CrearPlantillaScreen extends StatefulWidget {
  const CrearPlantillaScreen({super.key});

  @override
  State<CrearPlantillaScreen> createState() => _CrearPlantillaScreenState();
}

class _CrearPlantillaScreenState extends State<CrearPlantillaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombreController = TextEditingController();

  bool _trackSeries = false;
  bool _trackReps = false;
  bool _trackPeso = false;
  bool _trackDistancia = false;
  bool _trackTiempo = false;

  List<PlantillaEjercicio> _plantillas = [];
  List<Categoria> _categorias = [];

  @override
  void initState() {
    super.initState();
    _cargarPlantillas();
    _cargarCategorias();
  }

  Future<void> _cargarPlantillas() async {
    final plantillas = await DBHelper.getPlantillas();
    setState(() {
      _plantillas = plantillas;
    });
  }

  Future<void> _cargarCategorias() async {
    final usuario = await DBHelper.getUsuarioActivo();
    if (usuario == null) {
      setState(() {
        _categorias = [];
      });
      return;
    }
    final cats = await DBHelper.getCategoriasPorUsuario(usuario.id!);
    setState(() {
      _categorias = cats;
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    super.dispose();
  }

  void _mostrarPopupPlantillas() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Plantillas existentes'),
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
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.deepPurple,
                            ),
                            tooltip: 'Editar plantilla',
                            onPressed: () async {
                              Navigator.pop(context); // Cierra el popup
                              await showDialog(
                                context: context,
                                builder: (context) {
                                  final nombreController =
                                      TextEditingController(
                                        text: plantilla.nombre,
                                      );
                                  bool trackSeries = plantilla.trackSeries;
                                  bool trackReps = plantilla.trackReps;
                                  bool trackPeso = plantilla.trackPeso;
                                  bool trackDistancia =
                                      plantilla.trackDistancia;
                                  bool trackTiempo = plantilla.trackTiempo;
                                  final editFormKey = GlobalKey<FormState>();

                                  return AlertDialog(
                                    title: const Text('Editar plantilla'),
                                    content: StatefulBuilder(
                                      builder: (context, setStateDialog) {
                                        return Form(
                                          key: editFormKey,
                                          child: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                TextFormField(
                                                  controller: nombreController,
                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: 'Nombre',
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                  validator:
                                                      (v) =>
                                                          (v == null ||
                                                                  v
                                                                      .trim()
                                                                      .isEmpty)
                                                              ? 'Ingresa un nombre'
                                                              : null,
                                                ),
                                                const SizedBox(height: 16),
                                                SwitchListTile(
                                                  title: const Text('Series'),
                                                  value: trackSeries,
                                                  onChanged:
                                                      (v) => setStateDialog(
                                                        () => trackSeries = v,
                                                      ),
                                                ),
                                                SwitchListTile(
                                                  title: const Text(
                                                    'Repeticiones',
                                                  ),
                                                  value: trackReps,
                                                  onChanged:
                                                      (v) => setStateDialog(
                                                        () => trackReps = v,
                                                      ),
                                                ),
                                                SwitchListTile(
                                                  title: const Text('Peso'),
                                                  value: trackPeso,
                                                  onChanged:
                                                      (v) => setStateDialog(
                                                        () => trackPeso = v,
                                                      ),
                                                ),
                                                SwitchListTile(
                                                  title: const Text(
                                                    'Distancia',
                                                  ),
                                                  value: trackDistancia,
                                                  onChanged:
                                                      (v) => setStateDialog(
                                                        () =>
                                                            trackDistancia = v,
                                                      ),
                                                ),
                                                SwitchListTile(
                                                  title: const Text('Tiempo'),
                                                  value: trackTiempo,
                                                  onChanged:
                                                      (v) => setStateDialog(
                                                        () => trackTiempo = v,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed: () async {
                                          // Confirmar eliminación
                                          final confirm = await showDialog<
                                            bool
                                          >(
                                            context: context,
                                            builder:
                                                (context) => AlertDialog(
                                                  title: const Text(
                                                    'Eliminar plantilla',
                                                  ),
                                                  content: const Text(
                                                    '¿Seguro que deseas eliminar esta plantilla?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                            false,
                                                          ),
                                                      child: const Text(
                                                        'Cancelar',
                                                      ),
                                                    ),
                                                    TextButton(
                                                      onPressed:
                                                          () => Navigator.pop(
                                                            context,
                                                            true,
                                                          ),
                                                      child: const Text(
                                                        'Eliminar',
                                                        style: TextStyle(
                                                          color: Colors.red,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                          );
                                          if (confirm == true) {
                                            await DBHelper.deletePlantilla(
                                              plantilla.id!,
                                            );
                                            await _cargarPlantillas();
                                            Navigator.pop(
                                              context,
                                            ); // Cierra el dialog de edición
                                            ScaffoldMessenger.of(
                                              this.context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Plantilla eliminada',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text(
                                          'Eliminar',
                                          style: TextStyle(color: Colors.red),
                                        ),
                                      ),
                                      ElevatedButton(
                                        onPressed: () async {
                                          if (editFormKey.currentState
                                                  ?.validate() ??
                                              false) {
                                            final nuevoNombre =
                                                nombreController.text.trim();
                                            if (!(trackSeries ||
                                                trackReps ||
                                                trackPeso ||
                                                trackDistancia ||
                                                trackTiempo)) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Selecciona al menos un tipo de dato a medir.',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            // Verifica si el nombre ya existe en otra plantilla
                                            final existeOtro = _plantillas.any(
                                              (p) =>
                                                  p.nombre.toLowerCase() ==
                                                      nuevoNombre
                                                          .toLowerCase() &&
                                                  p.id != plantilla.id,
                                            );
                                            if (existeOtro) {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Ya existe una plantilla con ese nombre.',
                                                  ),
                                                ),
                                              );
                                              return;
                                            }
                                            final actualizada = plantilla
                                                .copyWith(
                                                  nombre: nuevoNombre,
                                                  trackSeries: trackSeries,
                                                  trackReps: trackReps,
                                                  trackPeso: trackPeso,
                                                  trackDistancia:
                                                      trackDistancia,
                                                  trackTiempo: trackTiempo,
                                                );
                                            await DBHelper.updatePlantilla(
                                              actualizada,
                                            );
                                            await _cargarPlantillas();
                                            Navigator.pop(context);
                                            ScaffoldMessenger.of(
                                              this.context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  'Plantilla actualizada',
                                                ),
                                              ),
                                            );
                                          }
                                        },
                                        child: const Text('Guardar'),
                                      ),
                                    ],
                                  );
                                },
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
        );
      },
    );
  }

  Future<void> _guardarPlantilla() async {
    if (_formKey.currentState?.validate() ?? false) {
      if (!(_trackSeries ||
          _trackReps ||
          _trackPeso ||
          _trackDistancia ||
          _trackTiempo)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Selecciona al menos un tipo de dato a medir.'),
          ),
        );
        return;
      }
      final nombre = _nombreController.text.trim();
      // Verifica si ya existe una plantilla con ese nombre (case-insensitive)
      final existe = _plantillas.any(
        (p) => p.nombre.toLowerCase() == nombre.toLowerCase(),
      );
      if (existe) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ya existe una plantilla con ese nombre.'),
          ),
        );
        return;
      }
      final plantilla = PlantillaEjercicio(
        nombre: nombre,
        trackSeries: _trackSeries,
        trackReps: _trackReps,
        trackPeso: _trackPeso,
        trackDistancia: _trackDistancia,
        trackTiempo: _trackTiempo,
      );
      await DBHelper.insertPlantilla(plantilla);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Plantilla guardada correctamente')),
      );
      Navigator.pop(context, true);
    }
  }

  Future<void> _asociarPlantillaACategoria(
    PlantillaEjercicio plantilla, {
    Categoria? categoria,
  }) async {
    final usuario = await DBHelper.getUsuarioActivo();
    if (usuario == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debes iniciar sesión para asociar categorías.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    String? categoriaSeleccionada;
    String? errorCategoria;
    final nombreCategoriaController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: const Text('Selecciona o crea una categoría'),
                  content: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_categorias.isNotEmpty)
                        DropdownButtonFormField<String>(
                          value: categoriaSeleccionada,
                          items:
                              _categorias
                                  .map(
                                    (c) => DropdownMenuItem(
                                      value: c.nombre,
                                      child: Text(c.nombre),
                                    ),
                                  )
                                  .toList(),
                          onChanged: (v) {
                            setStateDialog(() {
                              categoriaSeleccionada = v;
                              errorCategoria = null;
                            });
                          },
                          decoration: const InputDecoration(
                            labelText: 'Categoría existente',
                          ),
                        ),
                      const SizedBox(height: 16),
                      const Text('O crea una nueva categoría:'),
                      TextField(
                        controller: nombreCategoriaController,
                        decoration: InputDecoration(
                          labelText: 'Nombre de la nueva categoría',
                          errorText: errorCategoria,
                        ),
                      ),
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        String nombreCat =
                            nombreCategoriaController.text.trim();
                        String? nombreFinal =
                            categoriaSeleccionada ??
                            (nombreCat.isNotEmpty ? nombreCat : null);

                        Categoria? categoriaToUse = categoria;

                        if (categoriaToUse == null) {
                          if (nombreFinal == null || nombreFinal.isEmpty) {
                            setStateDialog(() {
                              errorCategoria =
                                  'Debes seleccionar o escribir un nombre válido';
                            });
                            return;
                          }
                          // Validar duplicados solo si es nueva
                          if (_categorias.any(
                            (c) =>
                                c.nombre.toLowerCase() ==
                                nombreFinal!.toLowerCase(),
                          )) {
                            if (categoriaSeleccionada == null) {
                              setStateDialog(() {
                                errorCategoria =
                                    'Ya existe una categoría con ese nombre';
                              });
                              return;
                            }
                          }
                          // Si es nueva, la creamos
                          if (_categorias.any(
                            (c) =>
                                c.nombre.toLowerCase() ==
                                nombreFinal!.toLowerCase(),
                          )) {
                            categoriaToUse = _categorias.firstWhere(
                              (c) =>
                                  c.nombre.toLowerCase() ==
                                  nombreFinal!.toLowerCase(),
                            );
                          } else {
                            categoriaToUse = Categoria(
                              idUsuario: usuario.id!,
                              nombre: nombreFinal!,
                            );
                            await DBHelper.insertCategoria(categoriaToUse);
                            await _cargarCategorias();
                            categoriaToUse = _categorias.firstWhere(
                              (c) =>
                                  c.nombre.toLowerCase() ==
                                  nombreFinal!.toLowerCase(),
                            );
                          }
                        }
                        // Asociar plantilla a la categoría
                        await DBHelper.asociarPlantillaACategoria(
                          plantilla.id!,
                          categoriaToUse!.id!,
                        );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Plantilla asociada a la categoría "${categoriaToUse.nombre}"',
                            ),
                          ),
                        );
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
          ),
    );
  }

  // NUEVO: Eliminar categoría
  Future<void> _eliminarCategoria(Categoria categoria) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Eliminar categoría'),
            content: Text(
              '¿Seguro que deseas eliminar la categoría "${categoria.nombre}"?\n'
              'Se eliminará la asociación con las plantillas, pero NO las plantillas en sí.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
    if (confirm == true) {
      await DBHelper.deleteCategoriaYCascada(categoria.id!);
      await _cargarCategorias();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Categoría eliminada')));
    }
  }

  // NUEVO: Editar categoría
  Future<void> _editarCategoria(Categoria categoria) async {
    final controller = TextEditingController(text: categoria.nombre);
    String? error;
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: const Text('Editar categoría'),
                  content: TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Nuevo nombre',
                      errorText: error,
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final nuevoNombre = controller.text.trim();
                        if (nuevoNombre.isEmpty) {
                          setStateDialog(
                            () => error = 'El nombre no puede estar vacío',
                          );
                          return;
                        }
                        if (_categorias.any(
                          (c) =>
                              c.nombre.toLowerCase() ==
                                  nuevoNombre.toLowerCase() &&
                              c.id != categoria.id,
                        )) {
                          setStateDialog(
                            () =>
                                error =
                                    'Ya existe una categoría con ese nombre',
                          );
                          return;
                        }
                        await DBHelper.updateCategoria(
                          Categoria(
                            id: categoria.id,
                            idUsuario: categoria.idUsuario,
                            nombre: nuevoNombre,
                          ),
                        );
                        Navigator.pop(context, true);
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
          ),
    );
    if (confirm == true) {
      await _cargarCategorias();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Categoría actualizada')));
    }
  }

  // NUEVO: Ver categorías y sus plantillas asociadas
  Future<void> _mostrarCategoriasConPlantillas() async {
    final usuario = await DBHelper.getUsuarioActivo();
    if (usuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes iniciar sesión para ver las categorías.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final categorias = await DBHelper.getCategoriasPorUsuario(usuario.id!);
    final Map<int, List<PlantillaEjercicio>> catPlantillas = {};
    for (final cat in categorias) {
      catPlantillas[cat.id!] = await DBHelper.getPlantillasPorCategoria(
        cat.id!,
      );
    }

    String? errorNuevaCategoria;
    final nuevaCategoriaController = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (context) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: const Text('Categorías y plantillas'),
                  content: SizedBox(
                    width: double.maxFinite,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Botón para crear nueva categoría SIEMPRE visible arriba del listado
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: nuevaCategoriaController,
                                decoration: InputDecoration(
                                  labelText: 'Nombre de la nueva categoría',
                                  errorText: errorNuevaCategoria,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.add_circle,
                                color: Colors.deepPurple,
                              ),
                              tooltip: 'Crear categoría',
                              onPressed: () async {
                                final nombre =
                                    nuevaCategoriaController.text.trim();
                                if (nombre.isEmpty) {
                                  setStateDialog(() {
                                    errorNuevaCategoria =
                                        'El nombre no puede estar vacío';
                                  });
                                  return;
                                }
                                if (categorias.any(
                                  (c) =>
                                      c.nombre.toLowerCase() ==
                                      nombre.toLowerCase(),
                                )) {
                                  setStateDialog(() {
                                    errorNuevaCategoria =
                                        'Ya existe una categoría con ese nombre';
                                  });
                                  return;
                                }
                                await DBHelper.insertCategoria(
                                  Categoria(
                                    idUsuario: usuario.id!,
                                    nombre: nombre,
                                  ),
                                );
                                nuevaCategoriaController.clear();
                                setStateDialog(() {
                                  errorNuevaCategoria = null;
                                });
                                Navigator.pop(context);
                                _mostrarCategoriasConPlantillas();
                              },
                            ),
                          ],
                        ),
                        const Divider(height: 24),
                        if (categorias.isEmpty)
                          const Text('No hay categorías registradas.')
                        else
                          SizedBox(
                            height: 250,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: categorias.length,
                              itemBuilder: (context, i) {
                                final cat = categorias[i];
                                final plantillas = catPlantillas[cat.id!] ?? [];
                                return ExpansionTile(
                                  title: Text(cat.nombre),
                                  children: [
                                    if (plantillas.isEmpty)
                                      const ListTile(
                                        title: Text('Sin plantillas asignadas'),
                                      )
                                    else
                                      ...plantillas.map(
                                        (p) => ListTile(
                                          leading: const Icon(
                                            Icons.list_alt,
                                            color: Colors.deepPurple,
                                          ),
                                          title: Text(p.nombre),
                                        ),
                                      ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        IconButton(
                                          icon: const Icon(
                                            Icons.edit,
                                            color: Colors.deepPurple,
                                          ),
                                          tooltip: 'Editar categoría',
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _editarCategoria(cat);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          tooltip: 'Eliminar categoría',
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _eliminarCategoria(cat);
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.add,
                                            color: Colors.green,
                                          ),
                                          tooltip:
                                              'Asignar plantilla a esta categoría',
                                          onPressed: () async {
                                            final disponibles =
                                                _plantillas
                                                    .where(
                                                      (p) =>
                                                          !(catPlantillas[cat
                                                                      .id!]
                                                                  ?.any(
                                                                    (asig) =>
                                                                        asig.id ==
                                                                        p.id,
                                                                  ) ??
                                                              false),
                                                    )
                                                    .toList();

                                            String? errorAsignar;

                                            await showDialog(
                                              context: context,
                                              builder:
                                                  (context) => StatefulBuilder(
                                                    builder:
                                                        (
                                                          context,
                                                          setStateDialog,
                                                        ) => AlertDialog(
                                                          title: const Text(
                                                            'Selecciona una plantilla',
                                                          ),
                                                          content:
                                                              disponibles
                                                                      .isEmpty
                                                                  ? Text(
                                                                    'No hay plantillas disponibles para asignar a esta categoría.',
                                                                    style: const TextStyle(
                                                                      color:
                                                                          Colors
                                                                              .red,
                                                                    ),
                                                                  )
                                                                  : SizedBox(
                                                                    width:
                                                                        double
                                                                            .maxFinite,
                                                                    child: Column(
                                                                      mainAxisSize:
                                                                          MainAxisSize
                                                                              .min,
                                                                      children: [
                                                                        ...disponibles.map(
                                                                          (
                                                                            p,
                                                                          ) => ListTile(
                                                                            title: Text(
                                                                              p.nombre,
                                                                            ),
                                                                            onTap: () async {
                                                                              await DBHelper.asociarPlantillaACategoria(
                                                                                p.id!,
                                                                                cat.id!,
                                                                              );
                                                                              Navigator.pop(
                                                                                context,
                                                                              );
                                                                              Navigator.pop(
                                                                                context,
                                                                              ); // Cierra el popup principal
                                                                              _mostrarCategoriasConPlantillas();
                                                                              ScaffoldMessenger.of(
                                                                                this.context,
                                                                              ).showSnackBar(
                                                                                SnackBar(
                                                                                  content: Text(
                                                                                    'Plantilla asociada a la categoría "${cat.nombre}"',
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            },
                                                                          ),
                                                                        ),
                                                                        if (errorAsignar !=
                                                                            null)
                                                                          Padding(
                                                                            padding: const EdgeInsets.only(
                                                                              top:
                                                                                  8,
                                                                            ),
                                                                            child: Text(
                                                                              errorAsignar,
                                                                              style: const TextStyle(
                                                                                color:
                                                                                    Colors.red,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                          actions: [
                                                            TextButton(
                                                              onPressed:
                                                                  () =>
                                                                      Navigator.pop(
                                                                        context,
                                                                      ),
                                                              child: const Text(
                                                                'Cerrar',
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                  ),
                                            );
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cerrar'),
                    ),
                  ],
                ),
          ),
    );
  }

  // (Eliminado método duplicado _asociarPlantillaACategoria)

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F4),
      appBar: AppBar(
        title: const Text(
          'Crear Plantilla de Ejercicio',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          IconButton(
            icon: const Icon(Icons.list_alt, color: Colors.deepPurple),
            tooltip: 'Ver plantillas existentes',
            onPressed: _mostrarPopupPlantillas,
          ),
          IconButton(
            icon: const Icon(Icons.category, color: Colors.deepPurple),
            tooltip: 'Ver categorías',
            onPressed: _mostrarCategoriasConPlantillas,
          ),
        ],
      ), // <-- Close AppBar here
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Nombre de la plantilla',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _nombreController,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (v) =>
                        (v == null || v.trim().isEmpty)
                            ? 'Ingresa un nombre'
                            : null,
              ),
              const SizedBox(height: 30),
              const Text(
                '¿Qué vas a medir?',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              SwitchListTile(
                title: const Text('Series'),
                value: _trackSeries,
                onChanged: (v) => setState(() => _trackSeries = v),
              ),
              SwitchListTile(
                title: const Text('Repeticiones'),
                value: _trackReps,
                onChanged: (v) => setState(() => _trackReps = v),
              ),
              SwitchListTile(
                title: const Text('Peso'),
                value: _trackPeso,
                onChanged: (v) => setState(() => _trackPeso = v),
              ),
              SwitchListTile(
                title: const Text('Distancia'),
                value: _trackDistancia,
                onChanged: (v) => setState(() => _trackDistancia = v),
              ),
              SwitchListTile(
                title: const Text('Tiempo'),
                value: _trackTiempo,
                onChanged: (v) => setState(() => _trackTiempo = v),
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save, color: Colors.white),
                  label: const Text(
                    'Guardar Plantilla',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple.shade500,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: _guardarPlantilla,
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Volver'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade400,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

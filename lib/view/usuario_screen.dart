import 'package:flutter/material.dart';
import 'package:myapp/model/usuario.dart';
import 'package:myapp/database/db_helper.dart';
import 'package:intl/intl.dart';

class UsuarioScreen extends StatefulWidget {
  final Usuario usuario;

  const UsuarioScreen({super.key, required this.usuario});

  @override
  State<UsuarioScreen> createState() => _UsuarioScreenState();
}

class _UsuarioScreenState extends State<UsuarioScreen> {
  late Usuario _usuario;

  @override
  void initState() {
    super.initState();
    _usuario = widget.usuario;
  }

  void _cerrarSesion() async {
    await DBHelper.logoutUser();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
    }
  }

  void _editarUsuario() async {
    final nombreController = TextEditingController(text: _usuario.username);
    final correoController = TextEditingController(
      text: _usuario.correoElectronico,
    );
    final nacimientoController = TextEditingController(
      text: _usuario.fechaNacimiento,
    );
    final contrasenaActualController = TextEditingController();
    final contrasenaNuevaController = TextEditingController();

    bool cambiarContrasena = false;
    String? errorContrasena;
    String? errorUsuario;
    String? errorCorreo;
    String? errorNacimiento;

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setStateDialog) => AlertDialog(
                  title: const Text('Editar datos de usuario'),
                  content: SingleChildScrollView(
                    child: Column(
                      children: [
                        _campoTexto(nombreController, 'Nombre de usuario'),
                        if (errorUsuario != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              errorUsuario!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        _campoTexto(correoController, 'Correo electrónico'),
                        if (errorCorreo != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              errorCorreo!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        TextField(
                          controller: nacimientoController,
                          decoration: const InputDecoration(
                            labelText: 'Fecha de nacimiento (dd/mm/aaaa)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        if (errorNacimiento != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
                            child: Text(
                              errorNacimiento!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        const SizedBox(height: 16),
                        CheckboxListTile(
                          title: const Text('Cambiar contraseña'),
                          value: cambiarContrasena,
                          onChanged: (val) {
                            setStateDialog(() {
                              cambiarContrasena = val ?? false;
                              errorContrasena = null;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        if (cambiarContrasena) ...[
                          const SizedBox(height: 8),
                          TextField(
                            controller: contrasenaActualController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Contraseña actual',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextField(
                            controller: contrasenaNuevaController,
                            obscureText: true,
                            decoration: const InputDecoration(
                              labelText: 'Nueva contraseña',
                              border: OutlineInputBorder(),
                            ),
                          ),
                          if (errorContrasena != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                errorContrasena!,
                                style: const TextStyle(color: Colors.red),
                              ),
                            ),
                        ],
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('Cancelar'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        // Validaciones
                        setStateDialog(() {
                          errorUsuario = null;
                          errorCorreo = null;
                          errorNacimiento = null;
                          errorContrasena = null;
                        });

                        final nombre = nombreController.text.trim();
                        final correo = correoController.text.trim();
                        final nacimiento = nacimientoController.text.trim();

                        // Usuario: mínimo 3 caracteres
                        if (nombre.length < 3) {
                          setStateDialog(() {
                            errorUsuario =
                                'El usuario debe tener al menos 3 caracteres.';
                          });
                          return;
                        }

                        // Correo: validación similar a register_screen
                        final partes = correo.split('@');
                        if (partes.length != 2) {
                          setStateDialog(() {
                            errorCorreo = 'Debe contener un solo "@"';
                          });
                          return;
                        }
                        final nombreUsuario = partes[0];
                        final dominio = partes[1];
                        if (nombreUsuario.length < 6) {
                          setStateDialog(() {
                            errorCorreo =
                                'El usuario debe tener al menos 6 caracteres antes de la @';
                          });
                          return;
                        }
                        if (nombreUsuario.startsWith('.') ||
                            nombreUsuario.endsWith('.')) {
                          setStateDialog(() {
                            errorCorreo =
                                'El usuario no puede empezar o terminar con punto';
                          });
                          return;
                        }
                        if (RegExp(r'[._-]{2,}').hasMatch(nombreUsuario)) {
                          setStateDialog(() {
                            errorCorreo =
                                'No se permiten caracteres especiales consecutivos en el usuario';
                          });
                          return;
                        }
                        if (!RegExp(
                          r'^[a-zA-Z0-9._-]+$',
                        ).hasMatch(nombreUsuario)) {
                          setStateDialog(() {
                            errorCorreo =
                                'Solo letras, números, guion bajo (_), punto (.) y guion (-) en el usuario';
                          });
                          return;
                        }
                        if (RegExp(
                          r'[._-][^a-zA-Z0-9]',
                        ).hasMatch(nombreUsuario)) {
                          setStateDialog(() {
                            errorCorreo =
                                'Caracteres especiales deben ir seguidos de letra o número en el usuario';
                          });
                          return;
                        }
                        final dominioPartes = dominio.split('.');
                        if (dominioPartes.length < 2) {
                          setStateDialog(() {
                            errorCorreo =
                                'El dominio debe tener al menos un punto';
                          });
                          return;
                        }
                        if (dominioPartes.any((parte) => parte.isEmpty)) {
                          setStateDialog(() {
                            errorCorreo =
                                'El dominio no puede tener partes vacías';
                          });
                          return;
                        }
                        if (dominioPartes.any(
                          (parte) =>
                              !RegExp(r'^[a-zA-Z0-9-]+$').hasMatch(parte) ||
                              parte.startsWith('-') ||
                              parte.endsWith('-'),
                        )) {
                          setStateDialog(() {
                            errorCorreo =
                                'El dominio solo permite letras, números y guiones (no al inicio/fin)';
                          });
                          return;
                        }
                        if (dominioPartes.last.length < 2) {
                          setStateDialog(() {
                            errorCorreo =
                                'El dominio debe terminar con al menos 2 letras';
                          });
                          return;
                        }

                        // Fecha de nacimiento: formato y rango edad
                        DateTime? fechaNac;
                        try {
                          if (_esFechaISO(nacimiento)) {
                            fechaNac = DateTime.parse(nacimiento);
                          } else {
                            fechaNac = DateFormat(
                              'dd/MM/yyyy',
                            ).parseStrict(nacimiento);
                          }
                        } catch (_) {
                          setStateDialog(() {
                            errorNacimiento = 'Formato de fecha inválido';
                          });
                          return;
                        }
                        final hoy = DateTime.now();
                        int edad = hoy.year - fechaNac.year;
                        if (hoy.month < fechaNac.month ||
                            (hoy.month == fechaNac.month &&
                                hoy.day < fechaNac.day)) {
                          edad--;
                        }
                        if (edad < 3 || edad > 120) {
                          setStateDialog(() {
                            errorNacimiento =
                                'La edad debe ser entre 3 y 120 años.';
                          });
                          return;
                        }

                        // Contraseña (si se cambia)
                        if (cambiarContrasena) {
                          if (contrasenaActualController.text !=
                              _usuario.password) {
                            setStateDialog(() {
                              errorContrasena =
                                  'La contraseña actual es incorrecta';
                            });
                            return;
                          }
                          final nueva = contrasenaNuevaController.text;
                          if (nueva.length < 4) {
                            setStateDialog(() {
                              errorContrasena =
                                  'La nueva contraseña debe tener al menos 4 caracteres.';
                            });
                            return;
                          }
                          if (nueva.contains(' ')) {
                            setStateDialog(() {
                              errorContrasena =
                                  'La nueva contraseña no puede contener espacios.';
                            });
                            return;
                          }
                          if (nueva.trim().isEmpty) {
                            setStateDialog(() {
                              errorContrasena =
                                  'La nueva contraseña no puede estar vacía.';
                            });
                            return;
                          }
                        }

                        Navigator.pop(context, true);
                      },
                      child: const Text('Guardar'),
                    ),
                  ],
                ),
          ),
    );

    if (confirm == true) {
      final db = await DBHelper.getDB();

      // Calcula la edad correctamente al guardar
      int edadCalculada = 0;
      try {
        DateTime fechaNac;
        if (_esFechaISO(nacimientoController.text.trim())) {
          fechaNac = DateTime.parse(nacimientoController.text.trim());
        } else {
          fechaNac = DateFormat(
            'dd/MM/yyyy',
          ).parseStrict(nacimientoController.text.trim());
        }
        final hoy = DateTime.now();
        int edad = hoy.year - fechaNac.year;
        if (hoy.month < fechaNac.month ||
            (hoy.month == fechaNac.month && hoy.day < fechaNac.day)) {
          edad--;
        }
        edadCalculada = edad;
      } catch (_) {
        edadCalculada = 0;
      }

      final nuevosDatos = <String, Object>{
        'username': nombreController.text.trim(),
        'correo_electronico': correoController.text.trim(),
        'fecha_nacimiento': nacimientoController.text.trim(),
        'edad': edadCalculada,
      };

      // Si se cambia la contraseña, agrégala al update
      if (cambiarContrasena && contrasenaNuevaController.text.isNotEmpty) {
        nuevosDatos['password'] = contrasenaNuevaController.text;
      }

      await db.update(
        DBHelper.tablaUsuarios,
        nuevosDatos,
        where: 'id = ?',
        whereArgs: [_usuario.id],
      );

      setState(() {
        _usuario = Usuario(
          id: _usuario.id,
          username: nuevosDatos['username'] as String,
          correoElectronico: nuevosDatos['correo_electronico'] as String,
          fechaNacimiento: nuevosDatos['fecha_nacimiento'] as String,
          peso: _usuario.peso,
          edad: nuevosDatos['edad'] as int,
          fechaRegistro: _usuario.fechaRegistro,
          password: nuevosDatos['password'] as String? ?? _usuario.password,
          activo: _usuario.activo,
        );
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos actualizados exitosamente')),
      );
    }
  }

  void _eliminarCuenta() async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Eliminar cuenta'),
            content: const Text(
              '¿Estás seguro de que deseas eliminar tu cuenta? Esta acción no se puede deshacer.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );

    if (confirmacion == true) {
      final db = await DBHelper.getDB();
      await db.delete(
        DBHelper.tablaUsuarios,
        where: 'id = ?',
        whereArgs: [_usuario.id],
      );
      await DBHelper.logoutUser();
      if (mounted) {
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
      }
    }
  }

  void _handleMenu(String opcion) {
    switch (opcion) {
      case 'editar':
        _editarUsuario();
        break;
      case 'eliminar':
        _eliminarCuenta();
        break;
    }
  }

  Widget _campoTexto(
    TextEditingController controller,
    String label, {
    bool isNumber = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _info(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold)),
          Text(value ?? '-', style: const TextStyle(color: Colors.black87)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Formatea la fecha de registro a dd/mm/aaaa
    String fechaRegistroFormateada = '-';
    try {
      final fecha = DateTime.parse(_usuario.fechaRegistro);
      fechaRegistroFormateada = DateFormat('dd/MM/yyyy').format(fecha);
    } catch (_) {
      fechaRegistroFormateada = _usuario.fechaRegistro;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Perfil de Usuario',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _cerrarSesion),
          PopupMenuButton<String>(
            onSelected: _handleMenu,
            icon: const Icon(Icons.more_vert, color: Colors.white),
            itemBuilder:
                (_) => const [
                  PopupMenuItem(value: 'editar', child: Text('Editar usuario')),
                  PopupMenuItem(
                    value: 'eliminar',
                    child: Text('Eliminar cuenta'),
                  ),
                ],
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.deepPurple,
                ),
              ),
              const SizedBox(height: 20),
              _info('ID', _usuario.id.toString()),
              _info('Usuario', _usuario.username),
              _info('Correo', _usuario.correoElectronico),
              _info('Nacimiento', _usuario.fechaNacimiento),
              _info('Edad', _usuario.edad.toString()),
              _info('Registrado el', fechaRegistroFormateada),
            ],
          ),
        ),
      ),
    );
  }

  bool _esFechaISO(String fecha) {
    // Verifica si la fecha es tipo aaaa-mm-dd
    final isoReg = RegExp(r'^\d{4}-\d{2}-\d{2}');
    return isoReg.hasMatch(fecha);
  }
}

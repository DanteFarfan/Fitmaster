import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/datos_entrenamiento.dart';
import '../model/usuario.dart';
import '../model/seguimiento.dart';
import '../model/plan_nutricion.dart';
import '../model/seguimiento_medidas.dart';
import '../model/notas.dart';
import '../model/plantilla_ejercicio.dart';
import '../model/categoria.dart';

class DBHelper {
  static Database? _db;
  static const String tabla = 'DatosEntrenamiento';
  static const String tablaUsuarios = 'Usuarios';
  static const String tablaSeguimiento = 'Seguimiento';
  static const String tablaPlanNutricion = 'PlanNutricion';
  static const String tablaHistorialPlanNutricion = 'HistorialPlanNutricion';
  static const String tablaMedidas = 'Medidas';
  static const String tablaNotas = 'NotasDia';
  static const String tablaMedidasPeso = 'MedidasPeso';
  static const String tablaMedidasLongitud = 'MedidasLongitud';

  @Deprecated('Usar con precaución, solo para pruebas')
  static Future<void> borrarBaseDeDatos() async {
    final dbPath = await getDatabasesPath();
    final fullPath = join(dbPath, 'fitness.db');
    await deleteDatabase(fullPath);
  }

  static Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'fitness.db');

    return openDatabase(
      path,
      version: 11, // Aumenta la versión si es necesario
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE $tabla (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            titulo TEXT,
            descripcion TEXT,
            fecha TEXT,
            -- orden INTEGER, // eliminado
            series INTEGER,
            reps INTEGER,
            peso REAL,
            tiempo TEXT,
            distancia REAL,
            id_usuario INTEGER,
            id_plantilla INTEGER
          )
        ''');

        await db.execute('''
          CREATE TABLE $tablaUsuarios (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            username TEXT UNIQUE,
            password TEXT,
            correo_electronico TEXT,
            fecha_registro TEXT,
            fecha_nacimiento TEXT,
            peso REAL,
            edad INTEGER,
            activo INTEGER DEFAULT 0
          )
        ''');

        await db.execute('''
          CREATE TABLE $tablaSeguimiento (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_usuario INTEGER,
            id_entrenamiento INTEGER,
            fecha_entrenamiento TEXT,
            tipo_record TEXT,
            valor_record REAL
          )
        ''');

        await db.execute('''
          CREATE TABLE $tablaPlanNutricion (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_usuario INTEGER,
            peso REAL,
            altura REAL,
            edad INTEGER,
            sexo TEXT, -- Cambiado de genero a sexo
            objetivo TEXT,
            calorias REAL
          )
        ''');

        await db.execute('''
          CREATE TABLE $tablaHistorialPlanNutricion (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_usuario INTEGER,
            peso REAL,
            altura REAL,
            edad INTEGER,
            sexo TEXT, -- Cambiado de genero a sexo
            objetivo TEXT,
            calorias REAL,
            fecha_guardado TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE $tablaMedidas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_usuario INTEGER,
            nombre TEXT,
            descripcion TEXT,
            valor REAL,
            unidad TEXT,
            fecha TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE $tablaNotas (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_usuario INTEGER,
            texto TEXT,
            fecha TEXT
          )
        ''');
        await _createPlantillaTable(db); // Asegura crear la tabla de plantillas

        // Nuevas tablas para categorías y plantillas
        await db.execute('''
          CREATE TABLE IF NOT EXISTS Categoria (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_usuario INTEGER,
            nombre TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE IF NOT EXISTS PlantillaCategoria (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_plantilla INTEGER,
            id_categoria INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE $tablaMedidasPeso (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_usuario INTEGER,
            nombre TEXT,
            descripcion TEXT,
            valor REAL,
            unidad TEXT,
            fecha TEXT
          )
        ''');
        await db.execute('''
          CREATE TABLE $tablaMedidasLongitud (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            id_usuario INTEGER,
            nombre TEXT,
            descripcion TEXT,
            valor REAL,
            unidad TEXT,
            fecha TEXT
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        final columnasMap = await db.rawQuery(
          "PRAGMA table_info($tablaUsuarios)",
        );
        final columnas = columnasMap.map((c) => c['name'] as String).toList();

        if (oldVersion < 2) {
          await db.execute('ALTER TABLE $tabla ADD COLUMN orden INTEGER');
          await db.execute('ALTER TABLE $tabla ADD COLUMN series INTEGER');
          await db.execute('ALTER TABLE $tabla ADD COLUMN reps INTEGER');
          await db.execute('ALTER TABLE $tabla ADD COLUMN peso REAL');
          await db.execute('ALTER TABLE $tabla ADD COLUMN tiempo TEXT');
          await db.execute('ALTER TABLE $tabla ADD COLUMN distancia REAL');
          await db.execute('ALTER TABLE $tabla ADD COLUMN id_usuario  INTEGER');
        }

        if (oldVersion < 4) {
          if (!columnas.contains('activo')) {
            await db.execute(
              'ALTER TABLE $tablaUsuarios ADD COLUMN activo INTEGER DEFAULT 0',
            );
          }
        }

        if (oldVersion < 5) {
          if (!columnas.contains('correo_electronico')) {
            await db.execute(
              'ALTER TABLE $tablaUsuarios ADD COLUMN correo_electronico TEXT',
            );
          }
          if (!columnas.contains('fecha_registro')) {
            await db.execute(
              'ALTER TABLE $tablaUsuarios ADD COLUMN fecha_registro TEXT',
            );
          }
          if (!columnas.contains('fecha_nacimiento')) {
            await db.execute(
              'ALTER TABLE $tablaUsuarios ADD COLUMN fecha_nacimiento TEXT',
            );
          }
          if (!columnas.contains('peso')) {
            await db.execute('ALTER TABLE $tablaUsuarios ADD COLUMN peso REAL');
          }
          if (!columnas.contains('edad')) {
            await db.execute(
              'ALTER TABLE $tablaUsuarios ADD COLUMN edad INTEGER',
            );
          }
        }

        if (oldVersion < 6) {
          await db.execute('ALTER TABLE $tabla ADD COLUMN id_usuario INTEGER');
        }
        if (oldVersion < 7) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $tablaSeguimiento (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_usuario INTEGER,
              id_entrenamiento INTEGER,
              fecha_entrenamiento TEXT,
              tipo_record TEXT,
              valor_record REAL
            )
          ''');
        }
        if (oldVersion < 8) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $tablaHistorialPlanNutricion (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_usuario INTEGER,
              peso REAL,
              altura REAL,
              edad INTEGER,
              sexo TEXT, -- Cambiado de genero a sexo
              objetivo TEXT,
              calorias REAL,
              fecha_guardado TEXT
            )
          ''');
        }
        if (oldVersion < 9) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $tablaMedidas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_usuario INTEGER,
              nombre TEXT,
              descripcion TEXT,
              valor REAL,
              unidad TEXT,
              fecha TEXT
            )
          ''');
        }
        if (oldVersion < 10) {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $tablaNotas (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_usuario INTEGER,
              texto TEXT,
              fecha TEXT
            )
          ''');
        }
        if (oldVersion < 11) {
          await _createPlantillaTable(db);
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $tablaMedidasPeso (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_usuario INTEGER,
              nombre TEXT,
              descripcion TEXT,
              valor REAL,
              unidad TEXT,
              fecha TEXT
            )
          ''');
          await db.execute('''
            CREATE TABLE IF NOT EXISTS $tablaMedidasLongitud (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              id_usuario INTEGER,
              nombre TEXT,
              descripcion TEXT,
              valor REAL,
              unidad TEXT,
              fecha TEXT
            )
          ''');
        }
      },
    );
  }

  static Future<Database> getDB() async {
    _db ??= await _initDB();
    return _db!;
  }

  // MÉTODOS DE USUARIO

  static Future<bool> registerUser({
    required String username,
    required String password,
    required String correoElectronico,
    required String fechaRegistro,
    required String fechaNacimiento,
    required double peso,
    required int edad,
  }) async {
    final db = await getDB();
    final fechaRegistro = DateTime.now().toIso8601String();

    try {
      await db.insert(tablaUsuarios, {
        'username': username,
        'password': password,
        'correo_electronico': correoElectronico,
        'fecha_registro': fechaRegistro,
        'fecha_nacimiento': fechaNacimiento,
        'peso': peso,
        'edad': edad,
        'activo': 0,
      });
      return true;
    } catch (e) {
      return false;
    }
  }

  static Future<bool> loginUser(String username, String password) async {
    final db = await getDB();

    final result = await db.query(
      tablaUsuarios,
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isNotEmpty) {
      final userId = result.first['id'];

      await db.update(tablaUsuarios, {'activo': 0});
      await db.update(
        tablaUsuarios,
        {'activo': 1},
        where: 'id = ?',
        whereArgs: [userId],
      );

      return true;
    }

    return false;
  }

  static Future<void> logoutUser() async {
    final db = await getDB();
    await db.update(tablaUsuarios, {'activo': 0});
  }

  static Future<Usuario?> getUsuarioActivo() async {
    final db = await getDB();
    final result = await db.query(tablaUsuarios, where: 'activo = 1', limit: 1);
    if (result.isNotEmpty) {
      return Usuario.fromMap(result.first);
    }
    return null;
  }

  static Future<bool> existeUsuario(String username) async {
    final db = await getDB();
    final result = await db.query(
      tablaUsuarios,
      where: 'username = ?',
      whereArgs: [username],
    );
    return result.isNotEmpty;
  }

  // MÉTODOS DE ENTRENAMIENTO

  static Future<int> insert(DatosEntrenamiento datos) async {
    final db = await getDB();
    return await db.insert(tabla, datos.toMap());
  }

  static Future<List<DatosEntrenamiento>> getEntrenamientosDelDiaUsuarioActivo(
    DateTime fecha,
  ) async {
    final db = await DBHelper.getDB();

    final usuario = await getUsuarioActivo();
    if (usuario == null) return [];

    final inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final fin = inicio.add(const Duration(days: 1));

    final maps = await db.query(
      'DatosEntrenamiento',
      where: 'fecha >= ? AND fecha < ? AND id_usuario = ?',
      whereArgs: [inicio.toIso8601String(), fin.toIso8601String(), usuario.id],
    );

    return maps.map((map) => DatosEntrenamiento.fromMap(map)).toList();
  }

  static Future<List<DatosEntrenamiento>>
  getEntrenamientosUsuarioActivo() async {
    final usuario = await getUsuarioActivo();
    if (usuario == null) return [];

    final db = await DBHelper.getDB();
    final maps = await db.query(
      'DatosEntrenamiento',
      where: 'id_usuario = ?',
      whereArgs: [usuario.id],
    );

    return maps.map((e) => DatosEntrenamiento.fromMap(e)).toList();
  }

  static Future<List<DatosEntrenamiento>> getEntrenamientosDelUsuario(
    int idUsuario,
  ) async {
    final db = await getDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tabla,
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
      orderBy: 'fecha ASC', // quitar ', orden ASC'
    );
    return maps.map((e) => DatosEntrenamiento.fromMap(e)).toList();
  }

  static Future<int> update(DatosEntrenamiento datos) async {
    final db = await getDB();
    return await db.update(
      tabla,
      datos.toMap(),
      where: 'id = ?',
      whereArgs: [datos.id],
    );
  }

  static Future<int> delete(int id) async {
    final db = await getDB();
    return await db.delete(tabla, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<DatosEntrenamiento>> getAll() async {
    final db = await getDB();
    final List<Map<String, dynamic>> maps = await db.query(tabla);
    return maps.map((e) => DatosEntrenamiento.fromMap(e)).toList();
  }

  static Future<void> close() async {
    final db = await getDB();
    await db.close();
    _db = null;
  }

  // MÉTODOS DE SEGUIMIENTO

  // Insertar nuevo seguimiento
  static Future<int> insertSeguimiento(Seguimiento seguimiento) async {
    final db = await getDB();
    return await db.insert(tablaSeguimiento, seguimiento.toMap());
  }

  // Obtener seguimiento por usuario
  static Future<List<Seguimiento>> getSeguimientoPorUsuario(
    int idUsuario,
  ) async {
    final db = await getDB();
    final List<Map<String, dynamic>> maps = await db.query(
      tablaSeguimiento,
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
      orderBy: 'fecha_entrenamiento ASC',
    );
    return maps.map((e) => Seguimiento.fromMap(e)).toList();
  }

  // Actualizar seguimiento
  static Future<int> updateSeguimiento(Seguimiento seguimiento) async {
    final db = await getDB();
    return await db.update(
      tablaSeguimiento,
      seguimiento.toMap(),
      where: 'id = ?',
      whereArgs: [seguimiento.id],
    );
  }

  // Eliminar seguimiento
  static Future<int> deleteSeguimiento(int id) async {
    final db = await getDB();
    return await db.delete(tablaSeguimiento, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<Seguimiento>> getAllSeguimientos() async {
    final db = await getDB();
    final List<Map<String, dynamic>> maps = await db.query(tablaSeguimiento);
    return maps.map((e) => Seguimiento.fromMap(e)).toList();
  }

  // MÉTODOS DE NUTRICIÓN

  // Guarda un plan de nutrición para el usuario activo
  static Future<void> savePlanNutricion(PlanNutricion plan) async {
    final db = await getDB();
    final usuario = await getUsuarioActivo();
    if (usuario == null) return;
    // Elimina el plan anterior si existe (uno por usuario)
    await db.delete(
      tablaPlanNutricion,
      where: 'id_usuario = ?',
      whereArgs: [usuario.id],
    );
    await db.insert(tablaPlanNutricion, {
      'id_usuario': usuario.id,
      'peso': plan.peso,
      'altura': plan.altura,
      'edad': plan.edad,
      'sexo': plan.sexo, // Cambiado de genero a sexo
      'objetivo': plan.objetivo,
      'calorias': plan.calorias,
    });
  }

  // Obtiene el plan de nutrición del usuario activo
  static Future<PlanNutricion?> getPlanNutricionUsuarioActivo() async {
    final db = await getDB();
    final usuario = await getUsuarioActivo();
    if (usuario == null) return null;
    final result = await db.query(
      tablaPlanNutricion,
      where: 'id_usuario = ?',
      whereArgs: [usuario.id],
      limit: 1,
    );
    if (result.isNotEmpty) {
      return PlanNutricion.fromMap(result.first);
    }
    return null;
  }

  // Método para guardar en el historial
  static Future<void> saveHistorialPlanNutricion(PlanNutricion plan) async {
    final db = await getDB();
    final usuario = await getUsuarioActivo();
    if (usuario == null) return;
    await db.insert(tablaHistorialPlanNutricion, {
      'id_usuario': usuario.id,
      'peso': plan.peso,
      'altura': plan.altura,
      'edad': plan.edad,
      'sexo': plan.sexo, // Cambiado de genero a sexo
      'objetivo': plan.objetivo,
      'calorias': plan.calorias,
      'fecha_guardado': DateTime.now().toIso8601String(),
    });
  }

  // Método para obtener el historial del usuario activo
  static Future<List<Map<String, dynamic>>>
  getHistorialPlanNutricionUsuarioActivo() async {
    final db = await getDB();
    final usuario = await getUsuarioActivo();
    if (usuario == null) return [];
    return await db.query(
      tablaHistorialPlanNutricion,
      where: 'id_usuario = ?',
      whereArgs: [usuario.id],
      orderBy: 'fecha_guardado DESC',
    );
  }

  static Future<void> borrarHistorialPlanNutricionUsuarioActivo() async {
    final db = await getDB();
    final usuario = await getUsuarioActivo();
    if (usuario == null) return;
    await db.delete(
      tablaHistorialPlanNutricion,
      where: 'id_usuario = ?',
      whereArgs: [usuario.id],
    );
  }

  // MÉTODOS DE MEDIDAS

  // MÉTODOS DE MEDIDAS DE PESO

  static Future<void> insertMedidaPeso(MedidaPeso medida) async {
    final db = await getDB();
    await db.insert(tablaMedidasPeso, medida.toMap());
  }

  static Future<List<MedidaPeso>> getMedidasPesoUsuarioActivo() async {
    final usuario = await getUsuarioActivo();
    if (usuario == null) return [];
    final db = await getDB();
    final maps = await db.query(
      tablaMedidasPeso,
      where: 'id_usuario = ?',
      whereArgs: [usuario.id],
      orderBy: 'fecha DESC',
    );
    return maps.map((e) => MedidaPeso.fromMap(e)).toList();
  }

  static Future<void> deleteMedidasPesoPorNombre(
    int idUsuario,
    String nombre,
  ) async {
    final db = await getDB();
    await db.delete(
      tablaMedidasPeso,
      where: 'id_usuario = ? AND LOWER(nombre) = ?',
      whereArgs: [idUsuario, nombre.toLowerCase()],
    );
  }

  // MÉTODOS DE MEDIDAS DE LONGITUD

  static Future<void> insertMedidaLongitud(MedidaLongitud medida) async {
    final db = await getDB();
    await db.insert(tablaMedidasLongitud, medida.toMap());
  }

  static Future<List<MedidaLongitud>> getMedidasLongitudUsuarioActivo() async {
    final usuario = await getUsuarioActivo();
    if (usuario == null) return [];
    final db = await getDB();
    final maps = await db.query(
      tablaMedidasLongitud,
      where: 'id_usuario = ?',
      whereArgs: [usuario.id],
      orderBy: 'fecha DESC',
    );
    return maps.map((e) => MedidaLongitud.fromMap(e)).toList();
  }

  static Future<void> deleteMedidasLongitudPorNombre(
    int idUsuario,
    String nombre,
  ) async {
    final db = await getDB();
    await db.delete(
      tablaMedidasLongitud,
      where: 'id_usuario = ? AND LOWER(nombre) = ?',
      whereArgs: [idUsuario, nombre.toLowerCase()],
    );
  }

  // MÉTODOS DE NOTAS

  static Future<void> insertNota(NotaDia nota) async {
    final db = await getDB();
    await db.insert(tablaNotas, nota.toMap());
  }

  static Future<void> updateNota(NotaDia nota) async {
    final db = await getDB();
    await db.update(
      tablaNotas,
      nota.toMap(),
      where: 'id = ?',
      whereArgs: [nota.id],
    );
  }

  static Future<void> deleteNota(int id) async {
    final db = await getDB();
    await db.delete(tablaNotas, where: 'id = ?', whereArgs: [id]);
  }

  static Future<List<NotaDia>> getNotasPorUsuarioYFecha(
    int idUsuario,
    DateTime fecha,
  ) async {
    final db = await getDB();
    final inicio = DateTime(fecha.year, fecha.month, fecha.day);
    final fin = inicio.add(const Duration(days: 1));
    final maps = await db.query(
      tablaNotas,
      where: 'id_usuario = ? AND fecha >= ? AND fecha < ?',
      whereArgs: [idUsuario, inicio.toIso8601String(), fin.toIso8601String()],
      orderBy: 'fecha DESC',
    );
    return maps.map((e) => NotaDia.fromMap(e)).toList();
  }

  static Future<List<NotaDia>> getNotasPorUsuario(int idUsuario) async {
    final db = await getDB();
    final maps = await db.query(
      tablaNotas,
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
      orderBy: 'fecha DESC',
    );
    return maps.map((e) => NotaDia.fromMap(e)).toList();
  }

  // MÉTODOS DE PLANTILLA DE EJERCICIO

  static Future<void> insertPlantilla(PlantillaEjercicio plantilla) async {
    final db = await getDB();
    await db.insert(
      'PlantillaEjercicio',
      plantilla.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> updatePlantilla(PlantillaEjercicio plantilla) async {
    final db = await getDB();
    await db.update(
      'PlantillaEjercicio',
      plantilla.toMap(),
      where: 'id = ?',
      whereArgs: [plantilla.id],
    );
  }

  static Future<List<PlantillaEjercicio>> getPlantillas() async {
    final db = await getDB();
    final List<Map<String, dynamic>> maps = await db.query(
      'PlantillaEjercicio',
    );
    return maps.map((e) => PlantillaEjercicio.fromMap(e)).toList();
  }

  static Future<void> _createPlantillaTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS PlantillaEjercicio (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT,
        track_series INTEGER,
        track_reps INTEGER,
        track_peso INTEGER,
        track_distancia INTEGER,
        track_tiempo INTEGER
      )
    ''');
  }

  static Future<void> deletePlantilla(int id) async {
    final db = await getDB();
    await db.delete('PlantillaEjercicio', where: 'id = ?', whereArgs: [id]);
  }

  // NUEVOS MÉTODOS PARA CATEGORÍAS

  static Future<void> insertCategoria(Categoria categoria) async {
    final db = await getDB();
    await db.insert('Categoria', categoria.toMap());
  }

  static Future<List<Categoria>> getCategoriasPorUsuario(int idUsuario) async {
    final db = await getDB();
    final maps = await db.query(
      'Categoria',
      where: 'id_usuario = ?',
      whereArgs: [idUsuario],
      orderBy: 'nombre COLLATE NOCASE ASC',
    );
    return maps.map((e) => Categoria.fromMap(e)).toList();
  }

  static Future<void> asociarPlantillaACategoria(
    int idPlantilla,
    int idCategoria,
  ) async {
    final db = await getDB();
    // Evita duplicados
    final existe = await db.query(
      'PlantillaCategoria',
      where: 'id_plantilla = ? AND id_categoria = ?',
      whereArgs: [idPlantilla, idCategoria],
    );
    if (existe.isEmpty) {
      await db.insert('PlantillaCategoria', {
        'id_plantilla': idPlantilla,
        'id_categoria': idCategoria,
      });
    }
  }

  static Future<void> deleteCategoriaYCascada(int idCategoria) async {
    final db = await getDB();
    // Elimina asociaciones con plantillas
    await db.delete(
      'PlantillaCategoria',
      where: 'id_categoria = ?',
      whereArgs: [idCategoria],
    );
    // Elimina la categoría
    await db.delete('Categoria', where: 'id = ?', whereArgs: [idCategoria]);
  }

  static Future<void> updateCategoria(Categoria categoria) async {
    final db = await getDB();
    await db.update(
      'Categoria',
      categoria.toMap(),
      where: 'id = ?',
      whereArgs: [categoria.id],
    );
  }

  static Future<List<PlantillaEjercicio>> getPlantillasPorCategoria(
    int idCategoria,
  ) async {
    final db = await getDB();
    final result = await db.rawQuery(
      '''
      SELECT p.* FROM PlantillaEjercicio p
      INNER JOIN PlantillaCategoria pc ON pc.id_plantilla = p.id
      WHERE pc.id_categoria = ?
    ''',
      [idCategoria],
    );
    return result.map((e) => PlantillaEjercicio.fromMap(e)).toList();
  }
}

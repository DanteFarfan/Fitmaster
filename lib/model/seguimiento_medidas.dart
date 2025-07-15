// Modelo para medidas de peso
class MedidaPeso {
  final int? id;
  final int idUsuario;
  final String nombre;
  final String descripcion;
  final double valor;
  final String unidad; // 'kg'
  final DateTime fecha;

  MedidaPeso({
    this.id,
    required this.idUsuario,
    required this.nombre,
    required this.descripcion,
    required this.valor,
    required this.unidad,
    required this.fecha,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'id_usuario': idUsuario,
    'nombre': nombre,
    'descripcion': descripcion,
    'valor': valor,
    'unidad': unidad,
    'fecha': fecha.toIso8601String(),
  };

  factory MedidaPeso.fromMap(Map<String, dynamic> map) => MedidaPeso(
    id: map['id'],
    idUsuario: map['id_usuario'],
    nombre: map['nombre'],
    descripcion: map['descripcion'],
    valor: (map['valor'] as num).toDouble(),
    unidad: map['unidad'],
    fecha: DateTime.parse(map['fecha']),
  );
}

// Modelo para medidas de longitud
class MedidaLongitud {
  final int? id;
  final int idUsuario;
  final String nombre;
  final String descripcion;
  final double valor;
  final String unidad; // 'cm'
  final DateTime fecha;

  MedidaLongitud({
    this.id,
    required this.idUsuario,
    required this.nombre,
    required this.descripcion,
    required this.valor,
    required this.unidad,
    required this.fecha,
  });

  Map<String, dynamic> toMap() => {
    if (id != null) 'id': id,
    'id_usuario': idUsuario,
    'nombre': nombre,
    'descripcion': descripcion,
    'valor': valor,
    'unidad': unidad,
    'fecha': fecha.toIso8601String(),
  };

  factory MedidaLongitud.fromMap(Map<String, dynamic> map) => MedidaLongitud(
    id: map['id'],
    idUsuario: map['id_usuario'],
    nombre: map['nombre'],
    descripcion: map['descripcion'],
    valor: (map['valor'] as num).toDouble(),
    unidad: map['unidad'],
    fecha: DateTime.parse(map['fecha']),
  );
}

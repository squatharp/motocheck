import 'dart:convert';

/// Tipo de movimiento: la moto se ENTREGA al repartidor o se RECIBE de vuelta.
enum TipoInspeccion { entrega, recepcion }

/// Modelo de dominio: representa una inspección de una moto.
/// No sabe nada de SQLite ni de pantallas; solo describe los datos.
class Inspeccion {
  final int? id;               // null mientras no se ha guardado en la BD
  final String moto;           // placa o número económico
  final TipoInspeccion tipo;
  final String observaciones;  // texto dictado o escrito
  final List<String> fotos;    // rutas locales de las imágenes
  final double? latitud;       // null si no se pudo obtener el GPS
  final double? longitud;
  final DateTime fecha;

  const Inspeccion({
    this.id,
    required this.moto,
    required this.tipo,
    this.observaciones = '',
    this.fotos = const [],
    this.latitud,
    this.longitud,
    required this.fecha,
  });

  bool get tieneUbicacion => latitud != null && longitud != null;

  /// Serialización: objeto Dart -> Map que SQLite entiende.
  Map<String, dynamic> toMap() => {
    'id': id,
    'moto': moto,
    'tipo': tipo.name,                    // enum -> "entrega"
    'observaciones': observaciones,
    'fotos': jsonEncode(fotos),           // lista -> texto JSON
    'latitud': latitud,
    'longitud': longitud,
    'fecha': fecha.toIso8601String(),     // fecha -> "2026-11-16T11:45:00"
  };

  /// Deserialización: Map leído de SQLite -> objeto Dart.
  factory Inspeccion.fromMap(Map<String, dynamic> map) => Inspeccion(
    id: map['id'] as int?,
    moto: map['moto'] as String,
    tipo: TipoInspeccion.values.byName(map['tipo'] as String),
    observaciones: map['observaciones'] as String? ?? '',
    fotos: List<String>.from(jsonDecode(map['fotos'] as String? ?? '[]')),
    latitud: (map['latitud'] as num?)?.toDouble(),
    longitud: (map['longitud'] as num?)?.toDouble(),
    fecha: DateTime.parse(map['fecha'] as String),
  );

  /// Devuelve una copia con el id asignado (los objetos son inmutables).
  Inspeccion copyWith({int? id}) => Inspeccion(
    id: id ?? this.id,
    moto: moto,
    tipo: tipo,
    observaciones: observaciones,
    fotos: fotos,
    latitud: latitud,
    longitud: longitud,
    fecha: fecha,
  );
}
extension TipoInspeccionTexto on TipoInspeccion {
  String get etiqueta =>
      this == TipoInspeccion.entrega ? 'Entrega' : 'Recepción';
}
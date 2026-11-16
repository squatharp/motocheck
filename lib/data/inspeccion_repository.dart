import '../models/inspeccion.dart';

/// Contrato (interfaz) del repositorio.
/// Las pantallas dependen de ESTA abstracción, no de SQLite.
abstract class InspeccionRepository {
  Future<List<Inspeccion>> obtenerTodas();
  Future<Inspeccion?> obtenerPorId(int id);
  Future<Inspeccion> guardar(Inspeccion inspeccion);
  Future<void> eliminar(int id);
}

/// Error propio de la capa de datos, con un mensaje entendible para la UI.
class RepositoryException implements Exception {
  final String mensaje;
  final Object? causa;
  RepositoryException(this.mensaje, [this.causa]);

  @override
  String toString() => 'RepositoryException: $mensaje ($causa)';
}
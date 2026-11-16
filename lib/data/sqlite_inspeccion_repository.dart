import '../models/inspeccion.dart';
import 'database_helper.dart';
import 'inspeccion_repository.dart';

/// Implementación concreta del repositorio usando SQLite.
class SqliteInspeccionRepository implements InspeccionRepository {
  final DatabaseHelper _dbHelper;

  SqliteInspeccionRepository([DatabaseHelper? dbHelper])
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  @override
  Future<List<Inspeccion>> obtenerTodas() async {
    try {
      final db = await _dbHelper.database;
      final filas = await db.query(
        DatabaseHelper.tablaInspecciones,
        orderBy: 'fecha DESC',               // las más recientes primero
      );
      return filas.map(Inspeccion.fromMap).toList();
    } catch (e) {
      throw RepositoryException('No se pudieron cargar las inspecciones', e);
    }
  }

  @override
  Future<Inspeccion?> obtenerPorId(int id) async {
    try {
      final db = await _dbHelper.database;
      final filas = await db.query(
        DatabaseHelper.tablaInspecciones,
        where: 'id = ?',
        whereArgs: [id],                     // parámetro seguro (evita SQL injection)
        limit: 1,
      );
      return filas.isEmpty ? null : Inspeccion.fromMap(filas.first);
    } catch (e) {
      throw RepositoryException('No se pudo cargar la inspección $id', e);
    }
  }

  @override
  Future<Inspeccion> guardar(Inspeccion inspeccion) async {
    try {
      final db = await _dbHelper.database;
      final datos = inspeccion.toMap();

      if (inspeccion.id == null) {
        datos.remove('id');                  // SQLite genera el id solo
        final nuevoId = await db.insert(DatabaseHelper.tablaInspecciones, datos);
        return inspeccion.copyWith(id: nuevoId);
      } else {
        await db.update(
          DatabaseHelper.tablaInspecciones,
          datos,
          where: 'id = ?',
          whereArgs: [inspeccion.id],
        );
        return inspeccion;
      }
    } catch (e) {
      throw RepositoryException('No se pudo guardar la inspección', e);
    }
  }

  @override
  Future<void> eliminar(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        DatabaseHelper.tablaInspecciones,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw RepositoryException('No se pudo eliminar la inspección $id', e);
    }
  }
}
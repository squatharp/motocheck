import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Abre la base de datos SQLite y crea las tablas.
/// Es un Singleton: existe una sola instancia en toda la app,
/// para no abrir varias conexiones al mismo archivo.
class DatabaseHelper {
  DatabaseHelper._();                                   // constructor privado
  static final DatabaseHelper instance = DatabaseHelper._();

  static const _nombreDb = 'motocheck.db';
  static const _version = 1;
  static const tablaInspecciones = 'inspecciones';

  Database? _db;

  /// La primera vez abre la BD; las siguientes reutiliza la conexión.
  Future<Database> get database async {
    _db ??= await _abrir();
    return _db!;
  }

  Future<Database> _abrir() async {
    final ruta = join(await getDatabasesPath(), _nombreDb);
    return openDatabase(ruta, version: _version, onCreate: _crearTablas);
  }

  /// Se ejecuta solo la primera vez que se crea el archivo .db
  Future<void> _crearTablas(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tablaInspecciones (
        id            INTEGER PRIMARY KEY AUTOINCREMENT,
        moto          TEXT NOT NULL,
        tipo          TEXT NOT NULL,
        observaciones TEXT,
        fotos         TEXT,
        latitud       REAL,
        longitud      REAL,
        fecha         TEXT NOT NULL
      )
    ''');
  }
}
import 'package:flutter/material.dart';
import 'data/sqlite_inspeccion_repository.dart';
import 'models/inspeccion.dart';

Future<void> main() async {
  // Necesario antes de usar plugins (sqflite) antes de runApp
  WidgetsFlutterBinding.ensureInitialized();

  // --- PRUEBA TEMPORAL ETAPA 1 ---
  final repo = SqliteInspeccionRepository();
  final guardada = await repo.guardar(Inspeccion(
    moto: 'YUC-123',
    tipo: TipoInspeccion.entrega,
    observaciones: 'Prueba de guardado',
    fecha: DateTime.now(),
  ));
  final todas = await repo.obtenerTodas();
  debugPrint('✅ Guardada con id ${guardada.id}. Total en BD: ${todas.length}');
  // --- FIN PRUEBA ---

  runApp(const MotoCheckApp());
}
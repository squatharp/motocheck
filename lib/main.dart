import 'package:flutter/material.dart';

import 'data/inspeccion_repository.dart';
import 'data/sqlite_inspeccion_repository.dart';
import 'models/inspeccion.dart';
import 'rutas.dart';
import 'screens/detalle_inspeccion_screen.dart';
import 'screens/formulario_inspeccion_screen.dart';
import 'screens/lista_inspecciones_screen.dart';
import 'services/foto_service.dart';
import 'services/ubicacion_service.dart';
import 'services/voz_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Dependencias de la app: se crean una vez y se inyectan a las pantallas.
  final InspeccionRepository repositorio = SqliteInspeccionRepository();
  final fotoService = FotoService();
  final vozService = VozService();
  final ubicacionService = UbicacionService();

  runApp(MotoCheckApp(
    repositorio: repositorio,
    fotoService: fotoService,
    vozService: vozService,
    ubicacionService: ubicacionService,
  ));
}

class MotoCheckApp extends StatelessWidget {
  final InspeccionRepository repositorio;
  final FotoService fotoService;
  final VozService vozService;
  final UbicacionService ubicacionService;

  const MotoCheckApp({
    super.key,
    required this.repositorio,
    required this.fotoService,
    required this.vozService,
    required this.ubicacionService,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotoCheck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true),
      initialRoute: Rutas.lista,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case Rutas.lista:
            return MaterialPageRoute(
              builder: (_) => ListaInspeccionesScreen(repositorio: repositorio),
            );
          case Rutas.detalle:
            final inspeccion = settings.arguments as Inspeccion;
            return MaterialPageRoute<bool>(
              builder: (_) => DetalleInspeccionScreen(
                inspeccion: inspeccion,
                repositorio: repositorio,
                fotoService: fotoService,
                ubicacionService: ubicacionService,
              ),
            );
          case Rutas.formulario:
            return MaterialPageRoute<bool>(
              builder: (_) => FormularioInspeccionScreen(
                repositorio: repositorio,
                fotoService: fotoService,
                vozService: vozService,
                ubicacionService: ubicacionService,
              ),
            );
          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text('Ruta no encontrada')),
              ),
            );
        }
      },
    );
  }
}
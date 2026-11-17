import 'package:flutter/material.dart';

import 'data/inspeccion_repository.dart';
import 'data/sqlite_inspeccion_repository.dart';
import 'models/inspeccion.dart';
import 'rutas.dart';
import 'screens/detalle_inspeccion_screen.dart';
import 'screens/formulario_inspeccion_screen.dart';
import 'screens/lista_inspecciones_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Aquí se decide QUÉ implementación usar. Las pantallas solo
  // conocen la interfaz InspeccionRepository (inyección de dependencias).
  final InspeccionRepository repositorio = SqliteInspeccionRepository();

  runApp(MotoCheckApp(repositorio: repositorio));
}

class MotoCheckApp extends StatelessWidget {
  final InspeccionRepository repositorio;

  const MotoCheckApp({super.key, required this.repositorio});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MotoCheck',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(colorSchemeSeed: Colors.orange, useMaterial3: true),
      initialRoute: Rutas.lista,
      // Construye cada pantalla según el nombre de la ruta
      // y le pasa lo que necesita (repositorio y argumentos).
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
              ),
            );
          case Rutas.formulario:
            return MaterialPageRoute<bool>(
              builder: (_) => FormularioInspeccionScreen(repositorio: repositorio),
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
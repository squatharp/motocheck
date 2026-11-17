import 'package:flutter/material.dart';

import '../data/inspeccion_repository.dart';
import '../models/inspeccion.dart';
import '../rutas.dart';
import '../widgets/app_drawer.dart';
import '../widgets/inspeccion_card.dart';

/// Pantalla principal: lista de inspecciones guardadas.
class ListaInspeccionesScreen extends StatefulWidget {
  final InspeccionRepository repositorio;

  const ListaInspeccionesScreen({super.key, required this.repositorio});

  @override
  State<ListaInspeccionesScreen> createState() =>
      _ListaInspeccionesScreenState();
}

class _ListaInspeccionesScreenState extends State<ListaInspeccionesScreen> {
  late Future<List<Inspeccion>> _inspecciones;

  @override
  void initState() {
    super.initState();
    _inspecciones = widget.repositorio.obtenerTodas();
  }

  /// Vuelve a pedir los datos y redibuja la pantalla.
  void _recargar() {
    setState(() {
      _inspecciones = widget.repositorio.obtenerTodas();
    });
  }

  Future<void> _abrirFormulario() async {
    // pushNamed devuelve lo que la otra pantalla mande en pop()
    final guardado = await Navigator.pushNamed(context, Rutas.formulario);
    if (guardado == true) _recargar();
  }

  Future<void> _abrirDetalle(Inspeccion inspeccion) async {
    final huboCambios = await Navigator.pushNamed(
      context,
      Rutas.detalle,
      arguments: inspeccion,
    );
    if (huboCambios == true) _recargar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inspecciones')),
      drawer: AppDrawer(onNuevaInspeccion: _abrirFormulario),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _abrirFormulario,
        icon: const Icon(Icons.add),
        label: const Text('Nueva'),
      ),
      body: FutureBuilder<List<Inspeccion>>(
        future: _inspecciones,
        builder: (context, snapshot) {
          // 1) Cargando
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2) Error
          if (snapshot.hasError) {
            final error = snapshot.error;
            final mensaje = error is RepositoryException
                ? error.mensaje
                : 'Ocurrió un error inesperado';
            return _EstadoMensaje(
              icono: Icons.error_outline,
              mensaje: mensaje,
              accion: TextButton(
                onPressed: _recargar,
                child: const Text('Reintentar'),
              ),
            );
          }

          // 3) Sin datos
          final lista = snapshot.data ?? [];
          if (lista.isEmpty) {
            return const _EstadoMensaje(
              icono: Icons.two_wheeler,
              mensaje: 'Aún no hay inspecciones.\n'
                  'Toca "Nueva" para registrar la primera.',
            );
          }

          // 4) Con datos
          return RefreshIndicator(
            onRefresh: () async {
              _recargar();
              await _inspecciones;
            },
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(8, 8, 8, 88),
              itemCount: lista.length,
              itemBuilder: (_, i) => InspeccionCard(
                inspeccion: lista[i],
                onTap: () => _abrirDetalle(lista[i]),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Mensaje centrado con ícono (para estados vacío y error).
class _EstadoMensaje extends StatelessWidget {
  final IconData icono;
  final String mensaje;
  final Widget? accion;

  const _EstadoMensaje({
    required this.icono,
    required this.mensaje,
    this.accion,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icono, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(mensaje, textAlign: TextAlign.center),
            if (accion != null) ...[const SizedBox(height: 8), accion!],
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../data/inspeccion_repository.dart';
import '../models/inspeccion.dart';
import '../services/foto_service.dart';
import '../widgets/fotos_miniaturas.dart';
import '../widgets/inspeccion_imagen.dart';
import 'foto_completa_screen.dart';

/// Muestra toda la información de una inspección.
class DetalleInspeccionScreen extends StatelessWidget {
  final Inspeccion inspeccion;
  final InspeccionRepository repositorio;
  final FotoService fotoService;

  const DetalleInspeccionScreen({
    super.key,
    required this.inspeccion,
    required this.repositorio,
    required this.fotoService,
  });

  Future<void> _eliminar(BuildContext context) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar inspección'),
        content: const Text('¿Seguro? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmar != true) return;

    try {
      await repositorio.eliminar(inspeccion.id!);
      await fotoService.eliminarFotos(inspeccion.fotos); // borra los archivos
      if (!context.mounted) return;
      Navigator.pop(context, true);
    } on RepositoryException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.mensaje)));
    }
  }

  void _verFoto(BuildContext context, int indice) {
    // Navegación directa (sin ruta con nombre): pantalla simple de un solo uso
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FotoCompletaScreen(ruta: inspeccion.fotos[indice]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('dd/MM/yyyy HH:mm').format(inspeccion.fecha);

    return Scaffold(
      appBar: AppBar(
        title: Text(inspeccion.moto),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'Eliminar',
            onPressed: () => _eliminar(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Hero(
            tag: 'inspeccion-${inspeccion.id}',
            child: InspeccionImagen(
              inspeccion: inspeccion,
              ancho: double.infinity,
              alto: 250,
            ),
          ),
          if (inspeccion.fotos.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'Fotos (${inspeccion.fotos.length}) · toca para ampliar',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const SizedBox(height: 8),
            FotosMiniaturas(
              rutas: inspeccion.fotos,
              onTap: (i) => _verFoto(context, i),
            ),
          ],
          const SizedBox(height: 16),
          _Dato(
            icono: Icons.swap_horiz,
            titulo: 'Tipo',
            valor: inspeccion.tipo.etiqueta,
          ),
          _Dato(icono: Icons.calendar_today, titulo: 'Fecha', valor: fecha),
          _Dato(
            icono: Icons.notes,
            titulo: 'Observaciones',
            valor: inspeccion.observaciones.isEmpty
                ? 'Sin observaciones'
                : inspeccion.observaciones,
          ),
          _Dato(
            icono: Icons.location_on,
            titulo: 'Ubicación',
            valor: inspeccion.tieneUbicacion
                ? '${inspeccion.latitud!.toStringAsFixed(5)}, '
                '${inspeccion.longitud!.toStringAsFixed(5)}'
                : 'Sin ubicación registrada',
          ),
          // ETAPA 5: botón "Ver en Google Maps"
        ],
      ),
    );
  }
}

/// Renglón de información: ícono + título + valor.
class _Dato extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String valor;

  const _Dato({required this.icono, required this.titulo, required this.valor});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icono),
      title: Text(titulo, style: Theme.of(context).textTheme.labelLarge),
      subtitle: Text(valor),
    );
  }
}
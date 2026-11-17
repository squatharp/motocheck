import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/inspeccion.dart';
import 'inspeccion_imagen.dart';

/// Tarjeta de una inspección en la lista.
class InspeccionCard extends StatelessWidget {
  final Inspeccion inspeccion;
  final VoidCallback onTap;

  const InspeccionCard({
    super.key,
    required this.inspeccion,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final fecha = DateFormat('dd/MM/yyyy HH:mm').format(inspeccion.fecha);

    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(8),
        // Mismo tag que en el detalle -> Flutter anima la imagen entre pantallas
        leading: Hero(
          tag: 'inspeccion-${inspeccion.id}',
          child: InspeccionImagen(inspeccion: inspeccion),
        ),
        title: Text(
          inspeccion.moto,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('${inspeccion.tipo.etiqueta} · $fecha'),
        trailing: Icon(
          inspeccion.tieneUbicacion ? Icons.location_on : Icons.location_off,
          color: inspeccion.tieneUbicacion ? Colors.green : Colors.grey,
        ),
        onTap: onTap,
      ),
    );
  }
}
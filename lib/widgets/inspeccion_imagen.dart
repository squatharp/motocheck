import 'dart:io';

import 'package:flutter/material.dart';

import '../models/inspeccion.dart';

/// Muestra la primera foto de la inspección o un ícono de moto si no tiene.
/// Se usa dentro del Hero, tanto en la lista como en el detalle.
class InspeccionImagen extends StatelessWidget {
  final Inspeccion inspeccion;
  final double ancho;
  final double alto;

  const InspeccionImagen({
    super.key,
    required this.inspeccion,
    this.ancho = 56,
    this.alto = 56,
  });

  @override
  Widget build(BuildContext context) {
    final colores = Theme.of(context).colorScheme;
    final tieneFoto = inspeccion.fotos.isNotEmpty &&
        File(inspeccion.fotos.first).existsSync();

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(
        width: ancho,
        height: alto,
        child: tieneFoto
            ? Image.file(File(inspeccion.fotos.first), fit: BoxFit.cover)
            : ColoredBox(
          color: colores.primaryContainer,
          child: Icon(
            Icons.two_wheeler,
            size: alto * 0.5,
            color: colores.onPrimaryContainer,
          ),
        ),
      ),
    );
  }
}
import 'dart:io';

import 'package:flutter/material.dart';

/// Fila horizontal de miniaturas. Reutilizable:
/// - en el formulario, con botón para quitar (onEliminar)
/// - en el detalle, tocando para ver en grande (onTap)
class FotosMiniaturas extends StatelessWidget {
  final List<String> rutas;
  final void Function(int indice)? onEliminar;
  final void Function(int indice)? onTap;

  const FotosMiniaturas({
    super.key,
    required this.rutas,
    this.onEliminar,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (rutas.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: rutas.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, i) => Stack(
          children: [
            GestureDetector(
              onTap: onTap == null ? null : () => onTap!(i),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(rutas[i]),
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  // Si el archivo ya no existe, muestra un ícono en vez de tronar
                  errorBuilder: (context, error, stackTrace) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey.shade300,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
            ),
            if (onEliminar != null)
              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () => onEliminar!(i),
                  child: const CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.black54,
                    child: Icon(Icons.close, size: 16, color: Colors.white),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
import 'dart:io';

import 'package:flutter/material.dart';

/// Muestra una foto en pantalla completa con zoom (pellizcar).
class FotoCompletaScreen extends StatelessWidget {
  final String ruta;

  const FotoCompletaScreen({super.key, required this.ruta});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: InteractiveViewer(
          minScale: 1,
          maxScale: 4,
          child: Image.file(File(ruta)),
        ),
      ),
    );
  }
}
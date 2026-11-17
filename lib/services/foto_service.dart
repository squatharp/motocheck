import 'dart:io';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Error de la capa de servicios de fotos, con mensaje para el usuario.
class FotoException implements Exception {
  final String mensaje;
  FotoException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Encapsula todo lo relacionado con fotos: abrir cámara/galería
/// y guardar/borrar los archivos. Las pantallas no usan image_picker directo.
class FotoService {
  final ImagePicker _picker;

  FotoService([ImagePicker? picker]) : _picker = picker ?? ImagePicker();

  Future<String?> tomarFoto() => _obtener(ImageSource.camera);

  Future<String?> elegirDeGaleria() => _obtener(ImageSource.gallery);

  /// Devuelve la ruta donde quedó guardada la foto, o null si el usuario canceló.
  Future<String?> _obtener(ImageSource origen) async {
    try {
      final XFile? archivo = await _picker.pickImage(
        source: origen,
        imageQuality: 70, // compresión JPG (0-100)
        maxWidth: 1280,   // reduce resolución para no llenar el teléfono
      );
      if (archivo == null) return null; // canceló

      return await _guardarEnApp(archivo);
    } on PlatformException catch (e) {
      if (e.code == 'camera_access_denied') {
        throw FotoException('Permiso de cámara denegado. Actívalo en Ajustes.');
      }
      if (e.code == 'photo_access_denied') {
        throw FotoException('Permiso de galería denegado. Actívalo en Ajustes.');
      }
      throw FotoException('No se pudo obtener la imagen (${e.code}).');
    } on FileSystemException {
      throw FotoException('No se pudo guardar la imagen en el teléfono.');
    }
  }

  /// image_picker deja la foto en una carpeta temporal (caché) que Android
  /// puede borrar. La copiamos a la carpeta privada y permanente de la app.
  Future<String> _guardarEnApp(XFile archivo) async {
    final documentos = await getApplicationDocumentsDirectory();
    final carpeta = Directory(p.join(documentos.path, 'fotos'));
    if (!await carpeta.exists()) {
      await carpeta.create(recursive: true);
    }

    final extension =
    p.extension(archivo.path).isEmpty ? '.jpg' : p.extension(archivo.path);
    final nombre = 'foto_${DateTime.now().millisecondsSinceEpoch}$extension';
    final destino = p.join(carpeta.path, nombre);

    await File(archivo.path).copy(destino);
    return destino;
  }

  /// Borra archivos de fotos (al quitar una foto o eliminar una inspección).
  Future<void> eliminarFotos(List<String> rutas) async {
    for (final ruta in rutas) {
      try {
        final archivo = File(ruta);
        if (await archivo.exists()) await archivo.delete();
      } catch (_) {
        // Si una foto no se puede borrar, seguimos con las demás.
      }
    }
  }
}
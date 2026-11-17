import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

/// Error del servicio de ubicación, con mensaje para el usuario.
class UbicacionException implements Exception {
  final String mensaje;
  UbicacionException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Par latitud/longitud (objeto de valor simple).
class Coordenadas {
  final double latitud;
  final double longitud;
  const Coordenadas(this.latitud, this.longitud);
}

/// Encapsula el GPS y la apertura de mapas.
/// Las pantallas no usan geolocator ni url_launcher directamente.
class UbicacionService {
  /// Revisa GPS y permisos, y devuelve la ubicación actual.
  Future<Coordenadas> obtenerUbicacionActual() async {
    // 1) ¿El GPS del teléfono está encendido?
    final gpsActivo = await Geolocator.isLocationServiceEnabled();
    if (!gpsActivo) {
      throw UbicacionException(
          'El GPS está apagado. Actívalo para registrar la ubicación.');
    }

    // 2) ¿Tenemos permiso? Si no, se pide.
    var permiso = await Geolocator.checkPermission();
    if (permiso == LocationPermission.denied) {
      permiso = await Geolocator.requestPermission();
      if (permiso == LocationPermission.denied) {
        throw UbicacionException('Permiso de ubicación denegado.');
      }
    }
    if (permiso == LocationPermission.deniedForever) {
      throw UbicacionException(
          'El permiso de ubicación está bloqueado. Actívalo en Ajustes.');
    }

    // 3) Pedir la posición, con límite de tiempo
    try {
      final posicion = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      return Coordenadas(posicion.latitude, posicion.longitude);
    } on TimeoutException {
      // Plan B: la última ubicación que el teléfono conoce
      final ultima = await Geolocator.getLastKnownPosition();
      if (ultima != null) return Coordenadas(ultima.latitude, ultima.longitude);
      throw UbicacionException(
          'No se pudo obtener la ubicación a tiempo. Intenta en un lugar abierto.');
    } catch (_) {
      throw UbicacionException('No se pudo obtener la ubicación.');
    }
  }

  /// Abre Google Maps (app o navegador) en las coordenadas indicadas.
  Future<void> abrirEnMapas(double latitud, double longitud) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$latitud,$longitud',
    );
    try {
      final abierto =
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!abierto) throw UbicacionException('No se pudo abrir Google Maps.');
    } on UbicacionException {
      rethrow;
    } catch (_) {
      throw UbicacionException('No se pudo abrir Google Maps.');
    }
  }
}
import 'package:speech_to_text/speech_recognition_error.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Error del servicio de voz, con mensaje para el usuario.
class VozException implements Exception {
  final String mensaje;
  VozException(this.mensaje);

  @override
  String toString() => mensaje;
}

/// Encapsula el micrófono y la conversión de voz a texto.
/// Las pantallas no usan speech_to_text directamente.
class VozService {
  final SpeechToText _speech = SpeechToText();
  bool _inicializado = false;
  String? _idioma;
  void Function(bool escuchando)? _onEstado;
  void Function(String mensaje)? _onError;

  bool get escuchando => _speech.isListening;

  /// Pide permiso de micrófono y verifica que exista un motor de voz.
  /// Solo se hace la primera vez.
  Future<void> _inicializar() async {
    if (_inicializado) return;

    final disponible = await _speech.initialize(
      onStatus: (estado) => _onEstado?.call(estado == 'listening'),
      onError: (error) {
        _onEstado?.call(false);
        final mensaje = _traducirError(error);
        if (mensaje != null) _onError?.call(mensaje);
      },
    );

    if (!disponible) {
      throw VozException(
        'No se pudo usar el micrófono. Revisa el permiso en Ajustes '
            'o que tengas la app de Google instalada.',
      );
    }

    _idioma = await _elegirIdioma();
    _inicializado = true;
  }

  /// Convierte los códigos técnicos del motor de voz en mensajes entendibles.
  /// Devuelve null para errores que no vale la pena mostrar.
  String? _traducirError(SpeechRecognitionError error) {
    switch (error.errorMsg) {
      case 'error_network':
      case 'error_network_timeout':
      case 'error_server':
        return 'Sin conexión con el servicio de voz. Revisa tu internet '
            'o descarga el español sin conexión en la app de Google.';
      case 'error_no_match':
      case 'error_speech_timeout':
        return 'No se escuchó nada. Intenta de nuevo hablando más cerca.';
      case 'error_audio':
        return 'No se pudo acceder al micrófono.';
      case 'error_permission':
      case 'error_insufficient_permissions':
        return 'Permiso de micrófono denegado. Actívalo en Ajustes.';
      case 'error_busy':
        return 'El micrófono está ocupado. Intenta en unos segundos.';
      case 'error_language_not_supported':
      case 'error_language_unavailable':
        return 'El idioma español no está disponible en este teléfono.';
      default:
        return null;
    }
  }

  /// Busca español de México; si no está, cualquier español;
  /// si no hay, usa el idioma del teléfono.
  Future<String?> _elegirIdioma() async {
    final idiomas = await _speech.locales();
    final ids = idiomas.map((l) => l.localeId.replaceAll('-', '_')).toList();

    if (ids.contains('es_MX')) return 'es_MX';
    for (final id in ids) {
      if (id.startsWith('es')) return id;
    }
    return null;
  }

  /// Empieza a escuchar.
  /// [onResultado] recibe el texto reconocido hasta el momento y si ya es final.
  /// [onEstado] recibe true/false cuando empieza o termina de escuchar.
  /// [onError] recibe un mensaje entendible si algo falla mientras escucha.
  Future<void> escuchar({
    required void Function(String texto, bool esFinal) onResultado,
    required void Function(bool escuchando) onEstado,
    required void Function(String mensaje) onError,
  }) async {
    _onEstado = onEstado;
    _onError = onError;
    await _inicializar();

    await _speech.listen(
      onResult: (resultado) =>
          onResultado(resultado.recognizedWords, resultado.finalResult),
      localeId: _idioma,
      listenFor: const Duration(minutes: 1),  // máximo de dictado
      pauseFor: const Duration(seconds: 5),   // se detiene tras 5 s de silencio
      listenOptions: SpeechListenOptions(
        partialResults: true,                 // texto en vivo mientras hablas
        listenMode: ListenMode.dictation,     // optimizado para frases largas
        cancelOnError: true,
      ),
    );
  }

  Future<void> detener() => _speech.stop();

  Future<void> cancelar() => _speech.cancel();
}
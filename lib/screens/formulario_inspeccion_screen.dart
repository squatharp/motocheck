import 'package:flutter/material.dart';

import '../data/inspeccion_repository.dart';
import '../models/inspeccion.dart';
import '../services/foto_service.dart';
import '../widgets/fotos_miniaturas.dart';

/// Formulario para registrar una nueva inspección.
class FormularioInspeccionScreen extends StatefulWidget {
  final InspeccionRepository repositorio;
  final FotoService fotoService;

  const FormularioInspeccionScreen({
    super.key,
    required this.repositorio,
    required this.fotoService,
  });

  @override
  State<FormularioInspeccionScreen> createState() =>
      _FormularioInspeccionScreenState();
}

class _FormularioInspeccionScreenState
    extends State<FormularioInspeccionScreen> {
  static const _maxFotos = 6;

  final _formKey = GlobalKey<FormState>();
  final _motoCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();
  final List<String> _fotos = [];
  TipoInspeccion _tipo = TipoInspeccion.entrega;
  bool _guardando = false;
  bool _guardado = false;

  @override
  void dispose() {
    _motoCtrl.dispose();
    _observacionesCtrl.dispose();
    // Si el usuario salió sin guardar, borramos las fotos que tomó
    // para no dejar archivos huérfanos ocupando espacio.
    if (!_guardado) widget.fotoService.eliminarFotos(List.of(_fotos));
    super.dispose();
  }

  void _mostrarMensaje(String texto) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(texto)));
  }

  /// Recibe la función a usar (tomarFoto o elegirDeGaleria).
  Future<void> _agregarFoto(Future<String?> Function() obtener) async {
    if (_fotos.length >= _maxFotos) {
      _mostrarMensaje('Máximo $_maxFotos fotos por inspección');
      return;
    }
    try {
      final ruta = await obtener();
      if (ruta == null || !mounted) return; // canceló o salió de la pantalla
      setState(() => _fotos.add(ruta));
    } on FotoException catch (e) {
      if (!mounted) return;
      _mostrarMensaje(e.mensaje);
    }
  }

  void _quitarFoto(int indice) {
    final ruta = _fotos[indice];
    setState(() => _fotos.removeAt(indice));
    widget.fotoService.eliminarFotos([ruta]);
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    try {
      await widget.repositorio.guardar(Inspeccion(
        moto: _motoCtrl.text.trim().toUpperCase(),
        tipo: _tipo,
        observaciones: _observacionesCtrl.text.trim(),
        fotos: List.of(_fotos),
        fecha: DateTime.now(),
        // ETAPA 5: latitud y longitud
      ));
      _guardado = true;
      if (!mounted) return;
      Navigator.pop(context, true);
    } on RepositoryException catch (e) {
      if (!mounted) return;
      _mostrarMensaje(e.mensaje);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final estiloTitulo = Theme.of(context).textTheme.titleSmall;

    return Scaffold(
      appBar: AppBar(title: const Text('Nueva inspección')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _motoCtrl,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Placa o número económico',
                prefixIcon: Icon(Icons.two_wheeler),
                border: OutlineInputBorder(),
              ),
              validator: (valor) => (valor == null || valor.trim().isEmpty)
                  ? 'Escribe la placa o el número de la moto'
                  : null,
            ),
            const SizedBox(height: 16),
            Text('Tipo de movimiento', style: estiloTitulo),
            const SizedBox(height: 8),
            SegmentedButton<TipoInspeccion>(
              segments: const [
                ButtonSegment(
                  value: TipoInspeccion.entrega,
                  label: Text('Entrega'),
                  icon: Icon(Icons.logout),
                ),
                ButtonSegment(
                  value: TipoInspeccion.recepcion,
                  label: Text('Recepción'),
                  icon: Icon(Icons.login),
                ),
              ],
              selected: {_tipo},
              onSelectionChanged: (seleccion) =>
                  setState(() => _tipo = seleccion.first),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _observacionesCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Observaciones',
                hintText: 'Rayones, golpes, nivel de gasolina...',
                alignLabelWithHint: true,
                border: OutlineInputBorder(),
              ),
            ),
            // ETAPA 4: botón de micrófono para dictar observaciones
            const SizedBox(height: 16),
            Text('Fotos (${_fotos.length}/$_maxFotos)', style: estiloTitulo),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _guardando
                        ? null
                        : () => _agregarFoto(widget.fotoService.tomarFoto),
                    icon: const Icon(Icons.photo_camera),
                    label: const Text('Cámara'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _guardando
                        ? null
                        : () => _agregarFoto(widget.fotoService.elegirDeGaleria),
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galería'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            FotosMiniaturas(rutas: _fotos, onEliminar: _quitarFoto),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
                  : const Icon(Icons.save),
              label: Text(_guardando ? 'Guardando...' : 'Guardar inspección'),
            ),
          ],
        ),
      ),
    );
  }
}
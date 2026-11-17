import 'package:flutter/material.dart';

import '../data/inspeccion_repository.dart';
import '../models/inspeccion.dart';

/// Formulario para registrar una nueva inspección.
class FormularioInspeccionScreen extends StatefulWidget {
  final InspeccionRepository repositorio;

  const FormularioInspeccionScreen({super.key, required this.repositorio});

  @override
  State<FormularioInspeccionScreen> createState() =>
      _FormularioInspeccionScreenState();
}

class _FormularioInspeccionScreenState
    extends State<FormularioInspeccionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _motoCtrl = TextEditingController();
  final _observacionesCtrl = TextEditingController();
  TipoInspeccion _tipo = TipoInspeccion.entrega;
  bool _guardando = false;

  @override
  void dispose() {
    // Los controllers ocupan memoria: se liberan al cerrar la pantalla
    _motoCtrl.dispose();
    _observacionesCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    // Ejecuta todos los validator; si alguno falla, no guarda
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);
    try {
      await widget.repositorio.guardar(Inspeccion(
        moto: _motoCtrl.text.trim().toUpperCase(),
        tipo: _tipo,
        observaciones: _observacionesCtrl.text.trim(),
        fecha: DateTime.now(),
        // ETAPA 3: fotos
        // ETAPA 5: latitud y longitud
      ));
      if (!mounted) return;
      Navigator.pop(context, true); // regresa a la lista avisando que se guardó
    } on RepositoryException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(e.mensaje)));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            Text('Tipo de movimiento',
                style: Theme.of(context).textTheme.titleSmall),
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
            // ETAPA 3: botones de cámara / galería y miniaturas
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
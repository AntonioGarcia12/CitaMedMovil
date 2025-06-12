import 'package:CitaMed/infrastructures/models/medico.dart';
import 'package:CitaMed/infrastructures/models/usuario.dart';
import 'package:flutter/material.dart';

class HistorialFormWidget extends StatefulWidget {
  final Usuario? paciente;
  final Medico? medico;
  final String? initialDiagnostico;
  final String? initialTratamiento;
  final bool isLoading;
  final Function(String, String) onSave;
  final String buttonText;
  final String loadingText;

  const HistorialFormWidget({
    super.key,
    required this.paciente,
    required this.medico,
    this.initialDiagnostico,
    this.initialTratamiento,
    required this.isLoading,
    required this.onSave,
    required this.buttonText,
    required this.loadingText,
  });

  @override
  State<HistorialFormWidget> createState() => _HistorialFormWidgetState();
}

class _HistorialFormWidgetState extends State<HistorialFormWidget> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _diagnosticoController;
  late TextEditingController _tratamientoController;

  @override
  void initState() {
    super.initState();
    _diagnosticoController = TextEditingController(
      text: widget.initialDiagnostico ?? '',
    );
    _tratamientoController = TextEditingController(
      text: widget.initialTratamiento ?? '',
    );
  }

  @override
  void dispose() {
    _diagnosticoController.dispose();
    _tratamientoController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      widget.onSave(_diagnosticoController.text, _tratamientoController.text);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Información del Historial',
            style: theme.textTheme.titleLarge?.copyWith(
              color: const Color(0xFF00838F),
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),

          if (widget.paciente != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Paciente',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.paciente!.nombre} ${widget.paciente!.apellidos}',
                    style: theme.textTheme.titleMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          if (widget.medico != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Médico',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dr(a). ${widget.medico!.nombre} ${widget.medico!.apellidos}',
                    style: theme.textTheme.titleMedium,
                  ),
                  Text(
                    widget.medico!.especialidad,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          TextFormField(
            controller: _diagnosticoController,
            decoration: InputDecoration(
              labelText: 'Diagnóstico',
              hintText: 'Ingrese el diagnóstico médico',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el diagnóstico';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _tratamientoController,
            decoration: InputDecoration(
              labelText: 'Tratamiento',
              hintText: 'Ingrese el tratamiento prescrito',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
            maxLines: 4,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Por favor ingrese el tratamiento';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: widget.isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00838F),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child:
                widget.isLoading
                    ? Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.0,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(widget.loadingText),
                      ],
                    )
                    : Text(widget.buttonText),
          ),
        ],
      ),
    );
  }
}

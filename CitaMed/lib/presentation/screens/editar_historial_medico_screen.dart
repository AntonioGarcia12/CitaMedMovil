import 'package:CitaMed/infrastructures/models/historial_medico.dart';
import 'package:CitaMed/infrastructures/models/medico.dart';
import 'package:CitaMed/infrastructures/models/usuario.dart';
import 'package:CitaMed/presentation/widgets/historial_form_widget.dart';
import 'package:CitaMed/services/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditarHistorialMedicoScreen extends StatefulWidget {
  static const String name = 'EditarHistorialMedicoScreen';
  final int id;

  const EditarHistorialMedicoScreen({super.key, required this.id});

  @override
  State<EditarHistorialMedicoScreen> createState() =>
      _EditarHistorialMedicoScreenState();
}

class _EditarHistorialMedicoScreenState
    extends State<EditarHistorialMedicoScreen> {
  final HistorialMedicoServices _historialService = HistorialMedicoServices();
  String? _diagnostico;
  String? _tratamiento;
  Medico? _medico;
  Usuario? _paciente;
  HistorialMedico? _historial;
  bool _isLoading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _cargarHistorial();
  }

  Future<void> _cargarHistorial() async {
    try {
      final historiales = await _historialService.obtenerHistorialPaciente(
        widget.id,
      );
      if (historiales.isNotEmpty) {
        final historial = historiales.first;
        setState(() {
          _historial = historial;
          _diagnostico = historial.diagnostico;
          _tratamiento = historial.tratamiento;
          _medico = historial.medico;
          _paciente = historial.paciente;
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('No se encontró historial para este paciente'),
          ),
        );
        context.go('/historiales');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar el historial: $e')),
      );
      context.go('/historiales');
    }
  }

  Future<void> _editarHistorial(String diagnostico, String tratamiento) async {
    if (_medico == null || _paciente == null || _historial == null) return;

    final historialActualizado = HistorialMedico(
      id: _historial!.id,
      diagnostico: diagnostico,
      tratamiento: tratamiento,
      medico: _medico!,
      paciente: _paciente!,
    );

    setState(() => _saving = true);
    try {
      await _historialService.editarHistorial(
        _historial!.id!,
        historialActualizado,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Historial actualizado exitosamente')),
      );
      context.go('/historiales');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF00838F), Color(0xFF006064)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned(
                top: -50,
                right: -50,
                child: Container(
                  height: 200,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(100),
                  ),
                ),
              ),
              Positioned(
                bottom: -100,
                left: -50,
                child: Container(
                  height: 250,
                  width: 250,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    borderRadius: BorderRadius.circular(125),
                  ),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => context.go('/historiales'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Editar Historial Médico',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 56),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: Container(
                          width: min(size.width * 0.95, 500),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child:
                                _isLoading
                                    ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                    : HistorialFormWidget(
                                      paciente: _paciente,
                                      medico: _medico,
                                      initialDiagnostico: _diagnostico,
                                      initialTratamiento: _tratamiento,
                                      isLoading: _saving,
                                      onSave: _editarHistorial,
                                      buttonText: 'Guardar cambios',
                                      loadingText: 'Guardando...',
                                    ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  double min(double a, double b) => a < b ? a : b;
}

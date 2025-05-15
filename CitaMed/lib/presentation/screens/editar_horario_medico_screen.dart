import 'package:CitaMed/infrastructures/models/horario_medico.dart';
import 'package:CitaMed/infrastructures/models/medico.dart';
import 'package:CitaMed/presentation/widgets/horario_form_widget.dart';
import 'package:CitaMed/services/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class EditarHorarioMedicoScreen extends StatefulWidget {
  static const String name = 'EditarHorarioMedicoScreen';
  final int id;

  const EditarHorarioMedicoScreen({super.key, required this.id});

  @override
  State<EditarHorarioMedicoScreen> createState() =>
      _EditarHorarioMedicoScreenState();
}

class _EditarHorarioMedicoScreenState extends State<EditarHorarioMedicoScreen> {
  final HorarioMedicoServices _horarioService = HorarioMedicoServices();
  DateTime? _dia;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;
  Medico? _medico;
  HorarioMedico? _horario;
  bool _isLoading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _cargarHorario();
  }

  Future<void> _cargarHorario() async {
    try {
      final horario = await _horarioService.obtenerHorarioPorId(widget.id);
      setState(() {
        _horario = horario;
        _dia = horario.dia;
        _horaInicio = TimeOfDay.fromDateTime(horario.horaInicio);
        _horaFin = TimeOfDay.fromDateTime(horario.horaFin);
        _medico = horario.medico;
        _isLoading = false;
      });
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar el horario: $e')));
      context.go('/horarios');
    }
  }

  Future<void> _editarHorario(
    DateTime dia,
    DateTime horaInicio,
    DateTime horaFin,
  ) async {
    if (_medico == null || _horario == null) return;

    final horarioActualizado = HorarioMedico(
      id: _horario!.id,
      dia: dia,
      horaInicio: horaInicio,
      horaFin: horaFin,
      medico: _medico!,
    );

    setState(() => _saving = true);
    try {
      await _horarioService.editarHorario(_horario!.id!, horarioActualizado);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Horario actualizado exitosamente')),
      );
      context.go('/horarios');
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
                    // ignore: deprecated_member_use
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
                    // ignore: deprecated_member_use
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
                          onPressed: () => context.go('/horarios'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Editar Horario',
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
                                    : HorarioFormWidget(
                                      medico: _medico,
                                      initialDia: _dia,
                                      initialHoraInicio: _horaInicio,
                                      initialHoraFin: _horaFin,
                                      isLoading: _saving,
                                      onSave: _editarHorario,
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

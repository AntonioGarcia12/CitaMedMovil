import 'package:CitaMed/infrastructures/models/horario_medico.dart';
import 'package:CitaMed/infrastructures/models/medico.dart';
import 'package:CitaMed/presentation/widgets/custom_appBar_widget.dart';
import 'package:CitaMed/presentation/widgets/horario_form_widget.dart';
import 'package:CitaMed/services/services.dart';
import 'package:CitaMed/utils/estado_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrearHorarioMedicoScreen extends StatefulWidget {
  static const String name = 'CrearHorarioMedicaScreen';
  const CrearHorarioMedicoScreen({super.key});

  @override
  State<CrearHorarioMedicoScreen> createState() => _CrearHorarioMedicoScreen();
}

class _CrearHorarioMedicoScreen extends State<CrearHorarioMedicoScreen> {
  final HorarioMedicoServices _horarioService = HorarioMedicoServices();
  Medico? _medico;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarMedico();
  }

  Future<void> _cargarMedico() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    if (id != null) {
      final medico = await MedicoService().listarUnMedico(id);
      setState(() => _medico = medico);
    }
  }

  Future<void> _guardarHorario(
    DateTime dia,
    DateTime horaInicio,
    DateTime horaFin,
  ) async {
    if (_medico == null) return;

    final horario = HorarioMedico(
      dia: dia,
      horaInicio: horaInicio,
      horaFin: horaFin,
      medico: _medico!,
    );

    setState(() => _isLoading = true);
    try {
      await _horarioService.crearHorarioMedico(horario);
      mostrarExito(context, 'Horario creado exitosamente');
      context.go('/horarios');
    } catch (e) {
      mostrarError(context, 'Error al crear el horario: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

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
                    child: CustomAppBarWidget(
                      title: 'Crear Horario Médico',
                      onBackPressed: () => context.go('/medico'),
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
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child:
                                _medico == null
                                    ? const Center(
                                      child: CircularProgressIndicator(),
                                    )
                                    : HorarioFormWidget(
                                      medico: _medico,
                                      isLoading: _isLoading,
                                      onSave: _guardarHorario,
                                      buttonText: 'Guardar horario',
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

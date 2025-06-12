import 'package:CitaMed/infrastructures/models/centro_de_salud.dart';
import 'package:CitaMed/infrastructures/models/cita.dart';
import 'package:CitaMed/infrastructures/models/medico.dart';
import 'package:CitaMed/presentation/widgets/widgets.dart';
import 'package:CitaMed/services/services.dart';
import 'package:CitaMed/utils/estado_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class EditarCitaScreen extends StatefulWidget {
  static const String name = 'EditarCitaScreen';
  final int id;

  const EditarCitaScreen({super.key, required this.id});

  @override
  State<EditarCitaScreen> createState() => _EditarCitaScreenState();
}

class _EditarCitaScreenState extends State<EditarCitaScreen> {
  final _formKey = GlobalKey<FormState>();
  final CitaServices _citaService = CitaServices();

  DateTime? _fecha;
  Medico? _medico;
  CentroDeSalud? _centro;
  String? _estado;
  bool _isLoading = true;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _cargarCita();
  }

  Future<void> _cargarCita() async {
    try {
      final cita = await _citaService.obtenerCitaPorId(widget.id);
      setState(() {
        _fecha = cita.fecha;
        _medico = cita.idMedico;
        _centro = cita.idCentro;
        _estado = cita.estado;
        _isLoading = false;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      mostrarError(context, 'Error al cargar la cita: $e');
      _navegarAListadoCitas();
    }
  }

  Future<void> _pickDateTime() async {
    final selected = await pickDateTime(context, initial: _fecha);
    if (selected != null) {
      setState(() => _fecha = selected);
    }
  }

  Future<void> _guardarCambios() async {
    if (!_formKey.currentState!.validate() || _fecha == null) {
      mostrarError(context, 'Por favor completa todos los campos');
      return;
    }

    setState(() => _saving = true);

    final citaActualizada = Cita(
      id: widget.id,
      fecha: _fecha!,
      idMedico: _medico!,
      idCentro: _centro!,
      estado: _estado,
    );

    try {
      await _citaService.editarCita(cita: citaActualizada, citaId: widget.id);
      // ignore: use_build_context_synchronously
      mostrarExito(context, 'Cita actualizada exitosamente');
      _navegarAListadoCitas();
    } catch (e) {
      // ignore: use_build_context_synchronously
      mostrarError(context, 'Error al actualizar cita: $e');
    } finally {
      setState(() => _saving = false);
    }
  }

  void _navegarAListadoCitas() {
    context.go('/citasMedico');
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
              GradientBackgroundWidget(
                child: Container(color: Colors.transparent),
              ),

              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CustomAppBarWidget(
                    title: 'Editar Cita',
                    onBackPressed: () => _navegarAListadoCitas(),
                  ),

                  Expanded(
                    child: Center(
                      child: Container(
                        width: min(size.width * 0.95, 450),
                        margin: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 20,
                              spreadRadius: 1,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child:
                            _isLoading
                                ? const Center(
                                  child: CircularProgressIndicator(
                                    color: Color(0xFF00838F),
                                  ),
                                )
                                : _buildFormContent(theme),
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

  Widget _buildFormContent(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            InfoCardWidget(
              title: 'Fecha y hora',
              subtitle:
                  _fecha != null
                      ? DateFormat('dd/MM/yyyy HH:mm').format(_fecha!)
                      : 'Selecciona fecha y hora',
              icon: Icons.calendar_today,
              onTap: _pickDateTime,
            ),
            const SizedBox(height: 16),

            _saving
                ? const Center(
                  child: CircularProgressIndicator(color: Color(0xFF00838F)),
                )
                : ElevatedButton(
                  onPressed: _guardarCambios,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00838F),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 3,
                  ),
                  child: const Text(
                    'GUARDAR CAMBIOS',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  double min(double a, double b) => a < b ? a : b;
}

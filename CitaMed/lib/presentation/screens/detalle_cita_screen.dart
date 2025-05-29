import 'package:CitaMed/infrastructures/models/cita.dart';
import 'package:CitaMed/infrastructures/models/horario_medico.dart';
import 'package:CitaMed/infrastructures/models/medico.dart';
import 'package:CitaMed/presentation/widgets/widgets.dart';
import 'package:CitaMed/services/services.dart';
import 'package:CitaMed/utils/estado_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetalleCitaScreen extends StatefulWidget {
  static const String name = 'DetalleCitaScreen';
  final int medicoId;

  const DetalleCitaScreen({super.key, required this.medicoId});

  @override
  State<DetalleCitaScreen> createState() => _DetalleCitaScreenState();
}

class _DetalleCitaScreenState extends State<DetalleCitaScreen> {
  final PacienteServices _pacienteService = PacienteServices();
  final CitaServices _citaService = CitaServices();
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  final DateFormat _timeFormat = DateFormat('HH-mm');

  List<HorarioMedico> _horarios = [];
  Medico? _medico;
  bool _isLoading = false;
  HorarioMedico? _horarioSeleccionado;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('es');
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);
    try {
      _horarios = await _pacienteService.obtenerDisponibilidad(widget.medicoId);
      _horarios.sort((a, b) => a.dia.compareTo(b.dia));

      _medico = await _pacienteService.listarUnMedico(widget.medicoId);
    } catch (e) {
      mostrarError(context, '$e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _seleccionarHorario(HorarioMedico horario) {
    setState(() {
      _horarioSeleccionado = _horarioSeleccionado == horario ? null : horario;
    });
  }

  Future<void> _confirmarCita() async {
    if (_horarioSeleccionado == null) {
      mostrarError(context, 'Por favor seleccione una fecha y hora');
      return;
    }
    if (_medico == null) {
      mostrarError(context, 'Datos de médico no disponibles');
      return;
    }

    final fecha = _horarioSeleccionado!.dia;
    final hIni = _horarioSeleccionado!.horaInicio;
    final fechaCompleta = DateTime(
      fecha.year,
      fecha.month,
      fecha.day,
      hIni.hour,
      hIni.minute,
      hIni.second,
    );

    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirmar cita'),
            content: Text(
              '¿Desea confirmar la cita para '
              '${_dateFormat.format(fecha)} de '
              '${_timeFormat.format(hIni)} '
              'a ${_timeFormat.format(_horarioSeleccionado!.horaFin)}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),

                child: const Text('Confirmar'),
              ),
            ],
          ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final idPaciente = prefs.getInt('id');
      if (idPaciente == null) throw Exception('Usuario no autenticado');

      if (_medico!.centroDeSalud == null) {
        mostrarError(context, 'El médico no tiene un centro de salud asignado');
        setState(() => _isLoading = false);
        return;
      }
      final nueva = Cita(
        idMedico: _medico!,
        idCentro: _medico!.centroDeSalud!,
        fecha: fechaCompleta,
      );

      final creada = await _citaService.crearCita(cita: nueva, id: idPaciente);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Cita confirmada para ${_dateFormat.format(creada.fecha)}',
          ),
        ),
      );
      setState(() {
        _horarios.removeWhere((h) => h.id == _horarioSeleccionado?.id);
        _horarioSeleccionado = null;
      });
      context.go('/citas');
    } catch (e) {
      mostrarError(context, 'Error confirmando cita: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
                    child: CustomAppBarWidget(
                      title: 'Detalles de Cita',
                      onBackPressed: () => context.go('/citas'),
                    ),
                  ),
                  // Contenido principal
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Container(
                          width: min(size.width * 0.95, 450),
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF006064).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 0,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child:
                              _isLoading
                                  ? const Padding(
                                    padding: EdgeInsets.all(40.0),
                                    child: Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF00838F),
                                      ),
                                    ),
                                  )
                                  : Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        if (_medico != null) ...[
                                          InformacionMedicoWidget(
                                            medico: _medico!,
                                          ),

                                          const Divider(height: 32),
                                        ],

                                        Text(
                                          'Horarios Disponibles',
                                          style: theme.textTheme.titleMedium
                                              ?.copyWith(
                                                color: const Color(0xFF00838F),
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                        const SizedBox(height: 16),

                                        _horarios.isEmpty
                                            ? construirMensajeVacio(theme)
                                            : HorariosDisponiblesWidget(
                                              horarios: _horarios,
                                              horarioSeleccionado:
                                                  _horarioSeleccionado,
                                              onSeleccionar:
                                                  _seleccionarHorario,
                                            ),

                                        if (_horarioSeleccionado != null) ...[
                                          const SizedBox(height: 24),
                                          ElevatedButton(
                                            onPressed: _confirmarCita,
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF00838F,
                                              ),
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            child: Text(
                                              'Confirmar Cita',
                                              style: theme.textTheme.titleMedium
                                                  ?.copyWith(
                                                    color: Colors.white,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                        ],
                                      ],
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

import 'package:CitaMed/infrastructures/models/cita.dart';
import 'package:CitaMed/presentation/widgets/widgets.dart';
import 'package:CitaMed/services/services.dart';
import 'package:CitaMed/utils/estado_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CitaPacienteScreen extends StatefulWidget {
  static const String name = 'CitaPacienteScreen';
  final int id;

  const CitaPacienteScreen({super.key, required this.id});

  @override
  State<CitaPacienteScreen> createState() => _CitaPacienteScreenState();
}

class _CitaPacienteScreenState extends State<CitaPacienteScreen> {
  List<Cita> _historialCitas = [];
  List<Cita> _todasLasCitas = [];
  bool _isLoading = false;
  final CitaServices _citaService = CitaServices();
  String? _errorMessage;

  String? _estadoSeleccionado;
  final List<String> _estados = ['CONFIRMADA', 'CANCELADA'];
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    _cargarHistorialCitas();
  }

  Future<void> _cargarHistorialCitas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final todas = await _citaService.obtenerHistorialCitas(widget.id);
      _todasLasCitas =
          todas
              .where(
                (cita) =>
                    cita.estado == 'CONFIRMADA' || cita.estado == 'CANCELADA',
              )
              .toList();
      _aplicarFiltros();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
      // ignore: use_build_context_synchronously
      mostrarError(context, '$_errorMessage');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _aplicarFiltros() {
    List<Cita> citasFiltradas = List.from(_todasLasCitas);
    if (_estadoSeleccionado != null) {
      citasFiltradas =
          citasFiltradas
              .where((cita) => cita.estado == _estadoSeleccionado)
              .toList();
    }

    if (_fechaInicio != null) {
      citasFiltradas =
          citasFiltradas
              .where(
                (cita) =>
                    cita.fecha.isAfter(_fechaInicio!) ||
                    cita.fecha.isAtSameMomentAs(_fechaInicio!),
              )
              .toList();
    }

    if (_fechaFin != null) {
      citasFiltradas =
          citasFiltradas
              .where(
                (cita) =>
                    cita.fecha.isBefore(_fechaFin!) ||
                    cita.fecha.isAtSameMomentAs(_fechaFin!),
              )
              .toList();
    }

    citasFiltradas.sort((a, b) => b.fecha.compareTo(a.fecha));

    setState(() {
      _historialCitas = citasFiltradas;
    });
  }

  void _reiniciarFiltros() {
    setState(() {
      _estadoSeleccionado = null;
      _fechaInicio = null;
      _fechaFin = null;
    });

    _aplicarFiltros();
  }

  Future<void> _seleccionarFecha(bool esInicio) async {
    final DateTime ahora = DateTime.now();
    final DateTime? fecha = await showDatePicker(
      context: context,
      initialDate: ahora,
      firstDate: DateTime(ahora.year - 5),
      lastDate: DateTime(ahora.year + 1, 12, 31),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00838F),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fecha != null) {
      setState(() {
        if (esInicio) {
          _fechaInicio = fecha;
        } else {
          _fechaFin = fecha;
        }
      });
      _aplicarFiltros();
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
                    child: CustomAppBarWidget(
                      title: 'Historial de Citas',
                      onBackPressed: () => context.go('/citasActuales'),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        width: min(size.width * 0.95, 450),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: const Color(0xFF006064).withOpacity(0.3),
                              blurRadius: 20,
                              spreadRadius: 0,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            FiltrosCitasWidget(
                              estadoSeleccionado: _estadoSeleccionado,
                              estadosDisponibles: _estados,
                              fechaInicio: _fechaInicio,
                              fechaFin: _fechaFin,
                              onEstadoChanged: (value) {
                                setState(() => _estadoSeleccionado = value);
                                _aplicarFiltros();
                              },
                              onReiniciar: _reiniciarFiltros,
                              onSeleccionarFecha: _seleccionarFecha,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Historial de Citas',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: const Color(0xFF00838F),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: CitasListPacienteWidget(
                                citas: _historialCitas,
                                isLoading: _isLoading,
                                errorMessage: _errorMessage,
                                onCitaTap: (_) {},
                                nombrePersonaBuilder:
                                    (cita) =>
                                        'Dr. ${cita.idMedico.nombre} ${cita.idMedico.apellidos}',
                                especialidadBuilder:
                                    (cita) => cita.idMedico.especialidad,
                              ),
                            ),
                          ],
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

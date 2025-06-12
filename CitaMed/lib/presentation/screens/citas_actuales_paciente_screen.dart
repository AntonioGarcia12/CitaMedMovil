import 'package:CitaMed/infrastructures/models/cita.dart';
import 'package:CitaMed/presentation/screens/screens.dart';
import 'package:CitaMed/presentation/widgets/widgets.dart';
import 'package:CitaMed/services/services.dart';
import 'package:CitaMed/utils/estado_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CitasActualesPacienteScreen extends StatefulWidget {
  static const String name = 'CitasActualesPacienteScreen';

  const CitasActualesPacienteScreen({super.key});

  @override
  State<CitasActualesPacienteScreen> createState() =>
      _CitasActualesPacienteScreenState();
}

class _CitasActualesPacienteScreenState
    extends State<CitasActualesPacienteScreen> {
  List<Cita> _citasActuales = [];
  List<Cita> _todasLasCitas = [];
  bool _isLoading = false;
  final CitaServices _citaService = CitaServices();
  String? _errorMessage;

  String? _estadoSeleccionado;
  final List<String> _estados = ['PENDIENTE', 'CONFIRMADA', 'CANCELADA'];
  DateTime? _fechaInicio;
  DateTime? _fechaFin;

  @override
  void initState() {
    super.initState();
    _cargarCitasActuales();
  }

  Future<void> _cargarCitasActuales() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      _todasLasCitas = await _citaService.obtenerCitasActualesPaciente();
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

  void _confirmarCancelacion(Cita cita) async {
    final confirmado = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cancelar cita'),
            content: const Text('¿Deseas cancelar esta cita?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Sí'),
              ),
            ],
          ),
    );

    if (confirmado == true) {
      try {
        final prefs = await SharedPreferences.getInstance();
        final pacienteId = prefs.getInt('id');

        if (pacienteId == null) {
          // ignore: use_build_context_synchronously
          mostrarError(context, 'No se encontró el ID del paciente');
          return;
        }

        await _citaService.cancelarCitaPaciente(
          citaId: cita.id!,
          pacienteId: pacienteId,
        );

        setState(() {
          final index = _todasLasCitas.indexWhere((c) => c.id == cita.id);
          if (index != -1) {
            _todasLasCitas[index] = cita.copyWith(estado: 'CANCELADA');
          }
          _aplicarFiltros();
        });

        // ignore: use_build_context_synchronously
        mostrarExito(context, 'La cita ha sido cancelada exitosamente');
      } catch (e) {
        // ignore: use_build_context_synchronously
        mostrarError(context, 'Error al cancelar la cita: $e');
      }
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

    citasFiltradas.sort((a, b) => a.fecha.compareTo(b.fecha));

    setState(() {
      _citasActuales = citasFiltradas;
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

  Future<void> _irAHistorial() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    if (id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró el ID del paciente')),
      );
      return;
    }
    context.goNamed(
      CitaPacienteScreen.name,
      pathParameters: {'id': id.toString()},
    );
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
                      title: 'Citas Actuales',
                      onBackPressed: () => context.go('/paciente'),
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
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Citas Actuales',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF00838F),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                IconButton(
                                  onPressed: _cargarCitasActuales,
                                  icon: const Icon(
                                    Icons.refresh,
                                    color: Color(0xFF00838F),
                                  ),
                                  tooltip: 'Actualizar',
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Expanded(
                              child: CitasListPacienteWidget(
                                citas: _citasActuales,
                                isLoading: _isLoading,
                                errorMessage: _errorMessage,
                                onCitaTap: (_) {},
                                onEstadoUpdate: (cita, estado) {
                                  if (estado == 'cancelar') {
                                    _confirmarCancelacion(cita);
                                  }
                                },
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _irAHistorial,
        backgroundColor: const Color(0xFF00838F),
        foregroundColor: Colors.white,
        icon: const Icon(Icons.history),
        label: const Text('Historial'),
        tooltip: 'Ver historial completo',
      ),
    );
  }

  double min(double a, double b) => a < b ? a : b;
}

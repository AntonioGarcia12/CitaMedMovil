import 'package:CitaMed/infrastructures/models/cita.dart';
import 'package:CitaMed/presentation/widgets/widgets.dart';
import 'package:CitaMed/services/services.dart';
import 'package:CitaMed/utils/estado_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CitasMedicoScreen extends StatefulWidget {
  static const String name = 'CitasMedicoScreen';

  const CitasMedicoScreen({super.key});

  @override
  State<CitasMedicoScreen> createState() => _CitasMedicoScreenState();
}

class _CitasMedicoScreenState extends State<CitasMedicoScreen> {
  final CitaServices _citaService = CitaServices();
  List<Cita> _citas = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _messageState;

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  Future<void> _cargarCitas() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final todas = await _citaService.obtenerCitasDeUnMedico();
      final ahora = DateTime.now();
      _citas =
          todas
              .where((c) => c.fecha.isAfter(ahora))
              .where((c) => c.id != null)
              .toList();
    } catch (e) {
      _errorMessage = e.toString();
      // ignore: use_build_context_synchronously
      mostrarError(context, _errorMessage!);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _actualizarEstado(Cita cita, String nuevoEstado) async {
    final confirmacion = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: Text(
              nuevoEstado == 'confirmar' ? 'Confirmar Cita' : 'Cancelar Cita',
            ),
            content: Text(
              nuevoEstado == 'confirmar'
                  ? '¿Estás seguro de que quieres confirmar esta cita?'
                  : '¿Estás seguro de que quieres cancelar esta cita?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text('Sí'),
              ),
            ],
          ),
    );

    if (confirmacion != true) return;

    try {
      await _citaService.actualizarEstadoCitaMedico(cita.id!, nuevoEstado);
      setState(() {
        final idx = _citas.indexWhere((c) => c.id == cita.id);
        if (idx != -1) {
          _citas[idx] = Cita(
            id: cita.id,
            fecha: cita.fecha,
            paciente: cita.paciente,
            idMedico: cita.idMedico,
            idCentro: cita.idCentro,
            estado: nuevoEstado,
          );
        }
      });
      _messageState =
          nuevoEstado == 'confirmar'
              ? 'Cita confirmada correctamente'
              : 'Cita cancelada correctamente';

      // ignore: use_build_context_synchronously
      mostrarExito(context, _messageState!);
    } catch (e) {
      // ignore: use_build_context_synchronously
      mostrarError(context, 'No se pudo actualizar: ${e.toString()}');
    }
  }

  void _irACrearHistorial(Cita cita) {
    if (cita.estado == 'PENDIENTE') {
      return;
    }
    context.go(
      '/crearHistorialMedico',
      extra: {'paciente': cita.paciente, 'cita': cita},
    );
  }

  Future<void> _irAEditarCita(Cita cita) async {
    setState(() => _isLoading = true);
    try {
      final detalle = await _citaService.obtenerCitaPorId(cita.id!);
      // ignore: use_build_context_synchronously
      context.go('/editarCita/${detalle.id}', extra: detalle);
    } catch (e) {
      // ignore: use_build_context_synchronously
      mostrarError(context, 'Error al obtener detalle: ${e.toString()}');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackgroundWidget(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CustomAppBarWidget(
                title: 'Mis Citas',
                onBackPressed: () => context.go('/medico'),
              ),
              Expanded(
                child: MainContentContainerWidget(
                  title: 'Lista de Citas',
                  onRefresh: _cargarCitas,
                  child: CitasListWidget(
                    citas: _citas,
                    isLoading: _isLoading,
                    errorMessage: _errorMessage,
                    onTap: _irACrearHistorial,
                    onEditarTap: _irAEditarCita,
                    onEstadoUpdate: _actualizarEstado,
                    nombrePersonaBuilder:
                        (cita) =>
                            '${cita.paciente?.nombre ?? ''} ${cita.paciente?.apellidos ?? ''}',
                    especialidadBuilder: (_) => 'Paciente',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

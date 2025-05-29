import 'package:CitaMed/infrastructures/models/cita.dart';
import 'package:CitaMed/presentation/widgets/widgets.dart';
import 'package:CitaMed/services/services.dart';
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
      _mostrarError(_errorMessage!);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje), backgroundColor: Colors.red),
    );
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            nuevoEstado == 'confirmar'
                ? 'Cita confirmada correctamente'
                : 'Cita cancelada correctamente',
          ),
        ),
      );
    } catch (e) {
      _mostrarError('No se pudo actualizar: ${e.toString()}');
    }
  }

  Future<void> _verDetalle(Cita cita) async {
    setState(() => _isLoading = true);
    try {
      final detalle = await _citaService.obtenerCitaPorId(cita.id!);
      context.go('/editarCita/${detalle.id}', extra: detalle);
    } catch (e) {
      _mostrarError('Error al obtener detalle: ${e.toString()}');
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

                    onCitaTap: _verDetalle,
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

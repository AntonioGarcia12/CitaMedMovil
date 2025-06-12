import 'package:CitaMed/DTO/cita_con_historial_dto.dart';
import 'package:CitaMed/infrastructures/models/usuario.dart';
import 'package:CitaMed/presentation/widgets/custom_appBar_widget.dart';
import 'package:CitaMed/services/services.dart';
import 'package:CitaMed/utils/estado_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class VerHistorialMedicoScreen extends StatefulWidget {
  static const String name = 'VerHistorialMedicoScreen';
  final int pacienteId;

  const VerHistorialMedicoScreen({super.key, required this.pacienteId});

  @override
  State<VerHistorialMedicoScreen> createState() =>
      _VerHistorialMedicoScreenState();
}

class _VerHistorialMedicoScreenState extends State<VerHistorialMedicoScreen> {
  final HistorialMedicoServices _servicio = HistorialMedicoServices();
  final MedicoService _usuarioService = MedicoService();

  List<CitaConHistorial> _citasConHistorial = [];
  Usuario? _paciente;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    setState(() => _isLoading = true);

    try {
      final todasLasCitas = await _servicio.obtenerCitasConHistorial(
        widget.pacienteId,
      );
      final citasConfirmadas =
          todasLasCitas.where((c) => c.estado == 'CONFIRMADA').toList();
      final paciente = await _usuarioService.listarUnPaciente(
        widget.pacienteId,
      );

      setState(() {
        _citasConHistorial = citasConfirmadas;
        _paciente = paciente;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      mostrarError(context, 'Error al cargar datos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
          child: Column(
            children: [
              CustomAppBarWidget(
                title: 'Historial del Paciente',
                onBackPressed: () => context.pop(),
              ),

              if (!_isLoading && _paciente != null) _buildPatientHeader(),

              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: const Color(0xFF006064).withOpacity(0.3),
                        blurRadius: 30,
                        offset: const Offset(0, 15),
                      ),
                    ],
                  ),
                  child: _buildContent(theme),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientHeader() {
    final p = _paciente!;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 30,
            // ignore: deprecated_member_use
            backgroundColor: const Color(0xFF00838F).withOpacity(0.1),
            backgroundImage: p.imagen != null ? NetworkImage(p.imagen!) : null,
            child:
                p.imagen == null
                    ? const Icon(
                      Icons.person,
                      size: 35,
                      color: Color(0xFF00838F),
                    )
                    : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${p.nombre} ${p.apellidos}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006064),
                  ),
                ),
                const SizedBox(height: 4),
                if (p.dni != null)
                  Text(
                    'DNI: ${p.dni}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                if (p.telefono != null)
                  Text(
                    'Tel: ${p.telefono}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: const Color(0xFF00838F).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '${_citasConHistorial.length} ${_citasConHistorial.length == 1 ? 'Cita' : 'Citas'}',
              style: const TextStyle(
                color: Color(0xFF00838F),
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00838F)),
      );
    }
    if (_citasConHistorial.isEmpty) {
      return _buildEmptyState();
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _citasConHistorial.length,
      itemBuilder: (context, index) {
        final citaConHistorial = _citasConHistorial[index];
        return _buildCitaCard(citaConHistorial, theme);
      },
    );
  }

  Widget _buildCitaCard(CitaConHistorial ch, ThemeData theme) {
    final fecha = ch.fecha;
    final estado = ch.estado;
    final hasHistorial = ch.diagnostico != null || ch.tratamiento != null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          // Header de fecha y estado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              // ignore: deprecated_member_use
              color: getEstadoColor(estado).withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.calendar_today,
                  color: getEstadoColor(estado),
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _formatDate(fecha),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: getEstadoColor(estado),
                    ),
                  ),
                ),
                _buildStatusChip(estado),
              ],
            ),
          ),

          // Contenido de médico, centro e historial
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasHistorial) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Médico: ${ch.medicoNombre}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Centro: ${ch.centroNombre}',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                  ),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      // ignore: deprecated_member_use
                      color: const Color(0xFF00838F).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        // ignore: deprecated_member_use
                        color: const Color(0xFF00838F).withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.medical_information,
                              color: Color(0xFF00838F),
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Historial Médico',
                              style: theme.textTheme.titleSmall?.copyWith(
                                color: const Color(0xFF00838F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        if (ch.diagnostico != null) ...[
                          _buildHistorialField('Diagnóstico:', ch.diagnostico!),
                          const SizedBox(height: 8),
                        ],
                        if (ch.tratamiento != null) ...[
                          _buildHistorialField('Tratamiento:', ch.tratamiento!),
                        ],
                      ],
                    ),
                  ),
                ] else ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.grey[600],
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Sin historial médico registrado',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.calendar_today_outlined,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            const Text(
              'Sin historial disponible',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Color(0xFF006064),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistorialField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF006064),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: Colors.grey[800], fontSize: 14, height: 1.3),
        ),
      ],
    );
  }

  Widget _buildStatusChip(String estado) {
    final color = getEstadoColor(estado);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        // ignore: deprecated_member_use
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        // ignore: deprecated_member_use
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        estado.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const meses = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];
    return '${date.day} ${meses[date.month - 1]} ${date.year}';
  }
}

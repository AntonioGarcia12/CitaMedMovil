import 'dart:math';

import 'package:CitaMed/infrastructures/models/cita.dart';
import 'package:CitaMed/infrastructures/models/historial_medico.dart';
import 'package:CitaMed/infrastructures/models/medico.dart';
import 'package:CitaMed/infrastructures/models/usuario.dart';
import 'package:CitaMed/presentation/widgets/custom_appBar_widget.dart';
import 'package:CitaMed/services/services.dart';
import 'package:CitaMed/utils/estado_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrearHistorialMedicoScreen extends StatefulWidget {
  static const String name = 'CrearHistorialMedicoScreen';
  final Usuario? pacienteInicial;
  final Cita? cita;

  const CrearHistorialMedicoScreen({
    super.key,
    this.pacienteInicial,
    this.cita,
  });

  @override
  State<CrearHistorialMedicoScreen> createState() =>
      _CrearHistorialMedicoScreenState();
}

class _CrearHistorialMedicoScreenState
    extends State<CrearHistorialMedicoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diagnosticoController = TextEditingController();
  final _tratamientoController = TextEditingController();
  final _historialService = HistorialMedicoServices();
  final _medicoService = MedicoService();

  Medico? _medico;
  Usuario? _pacienteSeleccionado;
  Cita? _cita;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _pacienteSeleccionado = widget.pacienteInicial;
    _cita = widget.cita;
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await _cargarMedico();
  }

  Future<void> _cargarMedico() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    if (id != null) {
      final medico = await _medicoService.listarUnMedico(id);
      setState(() => _medico = medico);
    }
  }

  Future<void> _guardarHistorial() async {
    if (!_formKey.currentState!.validate() || _medico == null) {
      return;
    }

    final historial = HistorialMedico(
      medico: _medico!,
      paciente: _pacienteSeleccionado!,
      cita: _cita,
      diagnostico: _diagnosticoController.text.trim(),
      tratamiento: _tratamientoController.text.trim(),
    );

    setState(() => _isLoading = true);
    try {
      await _historialService.crearHistorialMedico(historial);
      // ignore: use_build_context_synchronously
      mostrarExito(context, 'Historial médico creado con éxito');
      // ignore: use_build_context_synchronously
      context.go('/citasMedico');
    } catch (e) {
      // ignore: use_build_context_synchronously
      mostrarError(context, 'Error al crear historial: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _diagnosticoController.dispose();
    _tratamientoController.dispose();
    super.dispose();
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
              buildBackgroundDecorations(),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: CustomAppBarWidget(
                      title: 'Historial',
                      onBackPressed: () => context.go('/citasMedico'),
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        child: _buildFormulario(size),
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

  Widget _buildFormulario(Size size) {
    if (_medico == null) {
      return const CircularProgressIndicator();
    }

    return Container(
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Datos del Historial',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00838F),
                ),
              ),
              const SizedBox(height: 20),
              _buildDropdownPacientes(),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _diagnosticoController,
                label: 'Diagnóstico',
                icon: Icons.medical_information,
                validatorMessage: 'El diagnóstico es requerido',
              ),
              const SizedBox(height: 20),
              _buildTextFormField(
                controller: _tratamientoController,
                label: 'Tratamiento',
                icon: Icons.healing,
                validatorMessage: 'El tratamiento es requerido',
              ),
              const SizedBox(height: 30),
              _buildGuardarButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDropdownPacientes() {
    if (_pacienteSeleccionado == null) {
      return const Text(
        'Paciente no disponible',
        style: TextStyle(fontSize: 16, color: Colors.grey),
      );
    }
    return Text(
      '${_pacienteSeleccionado!.nombre} ${_pacienteSeleccionado!.apellidos}',
      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required String validatorMessage,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: 3,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.grey.shade50,
        prefixIcon: Icon(icon, color: const Color(0xFF00838F)),
      ),
      validator:
          (value) => value == null || value.isEmpty ? validatorMessage : null,
    );
  }

  Widget _buildGuardarButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _isLoading ? null : _guardarHistorial,
        label: Text(
          _isLoading ? 'Guardando...' : 'Guardar Historial',
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF00838F),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

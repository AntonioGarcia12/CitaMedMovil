import 'package:CitaMed/infrastructures/models/historial_medico.dart';
import 'package:CitaMed/infrastructures/models/medico.dart';
import 'package:CitaMed/infrastructures/models/usuario.dart';
import 'package:CitaMed/services/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CrearHistorialMedicoScreen extends StatefulWidget {
  static const String name = 'CrearHistorialMedicoScreen';
  const CrearHistorialMedicoScreen({super.key});

  @override
  State<CrearHistorialMedicoScreen> createState() =>
      _CrearHistorialMedicoScreen();
}

class _CrearHistorialMedicoScreen extends State<CrearHistorialMedicoScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _diagnosticoController = TextEditingController();
  final TextEditingController _tratamientoController = TextEditingController();
  final HistorialMedicoServices _historialService = HistorialMedicoServices();
  final MedicoService _medicoService = MedicoService();

  Medico? _medico;
  List<Usuario> _pacientes = [];
  Usuario? _pacienteSeleccionado;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  Future<void> _cargarDatos() async {
    await _cargarMedico();
    await _cargarPacientes();
  }

  Future<void> _cargarMedico() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    if (id != null) {
      final medico = await MedicoService().listarUnMedico(id);
      setState(() => _medico = medico);
    }
  }

  Future<void> _cargarPacientes() async {
    try {
      final pacientes = await _medicoService.obtenerPacientes();
      setState(() => _pacientes = pacientes);
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error cargando pacientes: $e')));
    }
  }

  Future<void> _guardarHistorial() async {
    if (!_formKey.currentState!.validate() ||
        _medico == null ||
        _pacienteSeleccionado == null) {
      return;
    }

    final historial = HistorialMedico(
      medico: _medico!,
      paciente: _pacienteSeleccionado!,
      diagnostico: _diagnosticoController.text.trim(),
      tratamiento: _tratamientoController.text.trim(),
    );

    setState(() => _isLoading = true);
    try {
      await _historialService.crearHistorialMedico(historial);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Historial creado exitosamente')),
      );
      context.go('/historiales');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
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
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => context.go('/historiales'),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            'Crear Historial Médico',
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
                                    : Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'Datos del Historial',
                                            style: theme.textTheme.titleMedium
                                                ?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                  color: const Color(
                                                    0xFF00838F,
                                                  ),
                                                ),
                                          ),
                                          const SizedBox(height: 20),
                                          DropdownButtonFormField<Usuario>(
                                            value: _pacienteSeleccionado,
                                            items:
                                                _pacientes
                                                    .map(
                                                      (
                                                        paciente,
                                                      ) => DropdownMenuItem(
                                                        value: paciente,
                                                        child: Text(
                                                          '${paciente.nombre} ${paciente.apellidos}',
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                            onChanged:
                                                (value) => setState(
                                                  () =>
                                                      _pacienteSeleccionado =
                                                          value,
                                                ),
                                            decoration: InputDecoration(
                                              labelText: 'Seleccionar Paciente',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              filled: true,
                                              fillColor: Colors.grey.shade50,
                                              prefixIcon: const Icon(
                                                Icons.person,
                                                color: Color(0xFF00838F),
                                              ),
                                            ),
                                            validator:
                                                (value) =>
                                                    value == null
                                                        ? 'Seleccione un paciente'
                                                        : null,
                                          ),
                                          const SizedBox(height: 20),
                                          TextFormField(
                                            controller: _diagnosticoController,
                                            decoration: InputDecoration(
                                              labelText: 'Diagnóstico',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              filled: true,
                                              fillColor: Colors.grey.shade50,
                                              prefixIcon: const Icon(
                                                Icons.medical_information,
                                                color: Color(0xFF00838F),
                                              ),
                                            ),
                                            validator:
                                                (value) =>
                                                    value == null ||
                                                            value.isEmpty
                                                        ? 'El diagnóstico es requerido'
                                                        : null,
                                            maxLines: 3,
                                          ),
                                          const SizedBox(height: 20),
                                          TextFormField(
                                            controller: _tratamientoController,
                                            decoration: InputDecoration(
                                              labelText: 'Tratamiento',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              filled: true,
                                              fillColor: Colors.grey.shade50,
                                              prefixIcon: const Icon(
                                                Icons.healing,
                                                color: Color(0xFF00838F),
                                              ),
                                            ),
                                            validator:
                                                (value) =>
                                                    value == null ||
                                                            value.isEmpty
                                                        ? 'El tratamiento es requerido'
                                                        : null,
                                            maxLines: 3,
                                          ),
                                          const SizedBox(height: 30),
                                          SizedBox(
                                            width: double.infinity,
                                            child: ElevatedButton.icon(
                                              onPressed:
                                                  _isLoading
                                                      ? null
                                                      : _guardarHistorial,
                                              icon: const Icon(Icons.save),
                                              label: Text(
                                                _isLoading
                                                    ? 'Guardando...'
                                                    : 'Guardar Historial',
                                                style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: const Color(
                                                  0xFF00838F,
                                                ),
                                                foregroundColor: Colors.white,
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 16,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                elevation: 2,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
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

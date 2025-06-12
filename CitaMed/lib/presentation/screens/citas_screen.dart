import 'package:CitaMed/infrastructures/models/medico.dart';
import 'package:CitaMed/presentation/widgets/widgets.dart';
import 'package:CitaMed/services/medico_service.dart';
import 'package:CitaMed/utils/estado_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CitaScreen extends StatefulWidget {
  static const String name = 'CitaScreen';
  const CitaScreen({super.key});

  @override
  State<CitaScreen> createState() => _CitaScreenState();
}

class _CitaScreenState extends State<CitaScreen> {
  final MedicoService _medicoService = MedicoService();
  List<Medico> _todosMedicos = [];
  List<Medico> _medicosFiltrados = [];
  List<String> _especialidades = [];
  String? _especialidadSeleccionada;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _inicializarDatos();
  }

  Future<void> _inicializarDatos() async {
    setState(() => _isLoading = true);
    try {
      final especialidades = await _medicoService.buscarPorEspecialidad();
      final medicos = await _medicoService.listarMedicos();

      setState(() {
        _especialidades = especialidades;
        _todosMedicos = medicos;
        _medicosFiltrados = medicos;
      });
    } catch (e) {
      // ignore: use_build_context_synchronously
      mostrarError(context, 'Error al cargar datos: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filtrarMedicos(String? especialidad) {
    setState(() {
      _especialidadSeleccionada = especialidad;
      _medicosFiltrados =
          (especialidad == null || especialidad.isEmpty)
                ? _todosMedicos
                : _todosMedicos
                    .where((medico) => medico.especialidad == especialidad)
                    .toList()
            ..sort((a, b) => a.nombre.compareTo(b.nombre));
    });
  }

  void _reiniciarFiltros() {
    _filtrarMedicos(null);
  }

  void _irADetalleCita(int id) {
    context.go('/detalleCita/$id');
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
              buildBackgroundDecorations(),
              Column(
                children: [
                  CustomAppBarWidget(
                    onBackPressed: () => context.go('/paciente'),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      child: Container(
                        width: min(size.width * 0.95, 450),
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              // ignore: deprecated_member_use
                              color: const Color(0xFF006064).withOpacity(0.3),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            _buildDropdownFiltro(theme),
                            const SizedBox(height: 16),
                            _buildListaMedicos(theme),
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

  Widget _buildDropdownFiltro(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Filtrar por especialidad',
          style: theme.textTheme.titleMedium?.copyWith(
            color: const Color(0xFF00838F),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _especialidadSeleccionada,
          isExpanded: true,
          hint: const Text('Seleccione una especialidad'),
          items:
              _especialidades
                  .map((esp) => DropdownMenuItem(value: esp, child: Text(esp)))
                  .toList(),
          onChanged: _filtrarMedicos,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            suffixIcon:
                _especialidadSeleccionada != null
                    ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: _reiniciarFiltros,
                    )
                    : null,
          ),
        ),
      ],
    );
  }

  Widget _buildListaMedicos(ThemeData theme) {
    return _isLoading
        ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF00838F)),
        )
        : _medicosFiltrados.isEmpty
        ? Column(
          children: [
            const Icon(Icons.search_off, color: Colors.grey, size: 48),
            const SizedBox(height: 8),
            Text(
              'No hay médicos disponibles',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ],
        )
        : ListView.builder(
          shrinkWrap: true,
          physics: const BouncingScrollPhysics(),
          itemCount: _medicosFiltrados.length,
          itemBuilder: (context, index) {
            final medico = _medicosFiltrados[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 6),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListTile(
                onTap: () => _irADetalleCita(medico.id),
                contentPadding: const EdgeInsets.all(8),
                leading: CircleAvatar(
                  backgroundImage:
                      (medico.imagen?.isNotEmpty ?? false)
                          ? NetworkImage(medico.imagen!)
                          : const AssetImage('assets/imgs/imagenDefault.webp')
                              as ImageProvider,
                ),
                title: Text(
                  '${medico.nombre} ${medico.apellidos}',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medico.especialidad,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    if (medico.centroDeSalud?.nombre != null)
                      Text(
                        medico.centroDeSalud!.nombre,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[500],
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
  }

  double min(double a, double b) => a < b ? a : b;
}

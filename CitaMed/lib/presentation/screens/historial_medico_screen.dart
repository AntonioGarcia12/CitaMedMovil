import 'package:CitaMed/infrastructures/models/historial_medico.dart';
import 'package:CitaMed/presentation/widgets/custom_appBar_widget.dart';
import 'package:CitaMed/presentation/widgets/historial_list_widget.dart';
import 'package:CitaMed/services/services.dart';
import 'package:CitaMed/utils/estado_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HistorialMedicoScreen extends StatefulWidget {
  static const String name = 'HistorialMedicoScreen';
  const HistorialMedicoScreen({super.key});

  @override
  State<HistorialMedicoScreen> createState() => _HistorialMedicoScreenState();
}

class _HistorialMedicoScreenState extends State<HistorialMedicoScreen> {
  final HistorialMedicoServices _servicio = HistorialMedicoServices();
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<HistorialMedico> _historiales = [];
  List<HistorialMedico> _filtrados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _cargarHistoriales();
    _searchController.addListener(_filtrarHistoriales);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _cargarHistoriales() async {
    setState(() => _isLoading = true);
    try {
      final list = await _servicio.obtenerHistorialesMedicos();
      setState(() {
        _historiales = list;
        _filtrados = List.from(list);
      });
    } catch (e) {
      mostrarError(context, 'Error al cargar historiales: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filtrarHistoriales() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() => _filtrados = List.from(_historiales));
      return;
    }

    setState(() {
      _filtrados =
          _historiales.where((h) {
            final nombre =
                '${h.paciente.nombre} ${h.paciente.apellidos}'.toLowerCase();
            final dni = h.paciente.dni?.toLowerCase() ?? '';
            return nombre.contains(query) || dni.contains(query);
          }).toList();
    });
  }

  Future<void> _borrarHistorial(int id) async {
    try {
      await _servicio.borrarhistorial(id);
      mostrarExito(context, 'Historial eliminado correctamente');
      await _cargarHistoriales();
    } catch (e) {
      mostrarError(context, 'Error al borrar historial: $e');
    }
  }

  void _editarHistorial(int pacienteId) =>
      context.go('/editarHistorial/$pacienteId');
  void _limpiarBusqueda() {
    _searchController.clear();
    _searchFocusNode.unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/crearHistorialMedico'),
        backgroundColor: const Color(0xFF00838F),
        child: const Icon(Icons.add),
      ),
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
                title: 'Historiales Médicos',
                onBackPressed: () => context.go('/medico'),
              ),
              _buildSearchBar(),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    width: size.width > 500 ? 500 : double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF006064).withOpacity(0.3),
                          blurRadius: 30,
                          offset: const Offset(0, 15),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: _buildContent(theme),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        decoration: InputDecoration(
          hintText: 'Buscar por nombre o DNI',
          filled: true,
          fillColor: Colors.white,
          prefixIcon: const Icon(Icons.search, color: Color(0xFF00838F)),
          suffixIcon:
              _searchController.text.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear, color: Color(0xFF00838F)),
                    onPressed: _limpiarBusqueda,
                  )
                  : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide.none,
          ),
        ),
        textInputAction: TextInputAction.search,
      ),
    );
  }

  Widget _buildContent(ThemeData theme) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00838F)),
      );
    } else if (_historiales.isEmpty) {
      return _buildEmptyState(theme);
    } else if (_filtrados.isEmpty) {
      return _buildNoResultsFound(theme);
    } else {
      return HistorialListWidget(
        historiales: _filtrados,
        onDelete: _borrarHistorial,
        onEdit: _editarHistorial,
      );
    }
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.medical_information_outlined,
          size: 64,
          color: Color(0xFF00838F),
        ),
        const SizedBox(height: 12),
        Text('No hay historiales médicos', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          'Crea un nuevo historial para tus pacientes.',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: () => context.go('/crearHistorial'),
          icon: const Icon(Icons.add),
          label: const Text('Crear Historial'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00838F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoResultsFound(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.search_off, size: 64, color: Color(0xFF00838F)),
        const SizedBox(height: 12),
        Text(
          'No se encontraron resultados',
          style: theme.textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Text(
          'Prueba con otro nombre o DNI.',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: _limpiarBusqueda,
          icon: const Icon(Icons.refresh),
          label: const Text('Ver todos'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00838F),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  double min(double a, double b) => a < b ? a : b;
}

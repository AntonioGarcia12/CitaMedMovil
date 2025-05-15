import 'package:citamed/infrastructures/models/historial_medico.dart';
import 'package:citamed/presentation/widgets/historial_list_widget.dart';
import 'package:citamed/services/services.dart';
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
  List<HistorialMedico> _historiales = [];
  List<HistorialMedico> _historialesFiltrados = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _cargarHistoriales();
    _searchController.addListener(() {
      _filtrarHistoriales();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _filtrarHistoriales() {
    final query = _searchController.text.toLowerCase().trim();

    if (query.isEmpty) {
      setState(() {
        _historialesFiltrados = List.from(_historiales);
      });
      return;
    }

    setState(() {
      _historialesFiltrados =
          _historiales.where((historial) {
            final nombreCompleto =
                '${historial.paciente.nombre} ${historial.paciente.apellidos}'
                    .toLowerCase();
            final dni = historial.paciente.dni?.toLowerCase();

            return nombreCompleto.contains(query) ||
                (dni?.contains(query) ?? false);
          }).toList();
    });
  }

  Future<void> _cargarHistoriales() async {
    setState(() => _isLoading = true);
    try {
      final list = await _servicio.obtenerHistorialesMedicos();
      setState(() {
        _historiales = list;
        _historialesFiltrados = List.from(list);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar historiales: $e')),
      );
    }
    setState(() => _isLoading = false);
  }

  Future<void> _borrarHistorial(int id) async {
    try {
      await _servicio.borrarhistorial(id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Historial eliminado correctamente')),
      );
      await _cargarHistoriales();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al borrar historial: $e')));
    }
  }

  void _editarHistorial(int pacienteId) {
    context.go('/editarHistorial/$pacienteId');
  }

  void _limpiarBusqueda() {
    _searchController.clear();
    _searchFocusNode.unfocus();
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
                    child: Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Color(0xFF00838F),
                            ),
                            onPressed: () => context.go('/medico'),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              boxShadow: [
                                BoxShadow(
                                  // ignore: deprecated_member_use
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              'Historiales Médicos',
                              style: theme.textTheme.titleLarge?.copyWith(
                                color: const Color(0xFF00838F),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                      ],
                    ),
                  ),

                  // Buscador
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            // ignore: deprecated_member_use
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: TextField(
                        controller: _searchController,
                        focusNode: _searchFocusNode,
                        decoration: InputDecoration(
                          hintText: 'Buscar por nombre o DNI',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Color(0xFF00838F),
                          ),
                          suffixIcon:
                              _searchController.text.isNotEmpty
                                  ? IconButton(
                                    icon: const Icon(
                                      Icons.clear,
                                      color: Color(0xFF00838F),
                                    ),
                                    onPressed: _limpiarBusqueda,
                                  )
                                  : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                          ),
                        ),
                        textInputAction: TextInputAction.search,
                        onChanged: (_) => _filtrarHistoriales(),
                      ),
                    ),
                  ),

                  // Contenido principal
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24.0,
                          vertical: 16.0,
                        ),
                        child: Container(
                          width: min(size.width * 0.95, 500),
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(32),
                            boxShadow: [
                              BoxShadow(
                                // ignore: deprecated_member_use
                                color: const Color(0xFF006064).withOpacity(0.3),
                                blurRadius: 30,
                                offset: const Offset(0, 15),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child:
                                _isLoading
                                    ? const Center(
                                      child: CircularProgressIndicator(
                                        color: Color(0xFF00838F),
                                      ),
                                    )
                                    : _historiales.isEmpty
                                    ? _buildEmptyState()
                                    : _historialesFiltrados.isEmpty
                                    ? _buildNoResultsFound()
                                    : HistorialListWidget(
                                      historiales: _historialesFiltrados,
                                      onDelete: _borrarHistorial,
                                      onEdit: _editarHistorial,
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
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/crearHistorialMedico'),
        backgroundColor: const Color(0xFF00838F),
        elevation: 4,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.medical_information_outlined,
          size: 80,
          color: Color(0xFF00838F),
        ),
        const SizedBox(height: 16),
        Text(
          'No hay historiales médicos',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF00838F),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Crea un nuevo historial médico para tus pacientes',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () => context.go('/crearHistorial'),
          icon: const Icon(Icons.add),
          label: const Text('Crear Historial'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00838F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNoResultsFound() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.search_off, size: 80, color: Color(0xFF00838F)),
        const SizedBox(height: 16),
        Text(
          'No se encontraron resultados',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: const Color(0xFF00838F),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Intenta con otros términos de búsqueda',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: _limpiarBusqueda,
          icon: const Icon(Icons.refresh),
          label: const Text('Ver todos'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00838F),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
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

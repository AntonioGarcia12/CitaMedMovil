import 'package:citamed/infrastructures/models/medico.dart';
import 'package:citamed/services/medico_service.dart';
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
      _especialidades = await _medicoService.buscarPorEspecialidad();
      _todosMedicos = await _medicoService.listarMedicos();
      _medicosFiltrados = _todosMedicos;
    } catch (e) {
      _mostrarError('Error al cargar datos: \$e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filtrarMedicos(String? especialidad) {
    setState(() {
      _especialidadSeleccionada = especialidad;
      if (especialidad == null || especialidad.isEmpty) {
        _medicosFiltrados = _todosMedicos;
      } else {
        _medicosFiltrados =
            _todosMedicos
                .where((medico) => medico.especialidad == especialidad)
                .toList();
      }
      _medicosFiltrados.sort((a, b) => a.nombre.compareTo(b.nombre));
    });
  }

  void _reiniciarFiltros() {
    setState(() {
      _especialidadSeleccionada = null;
      _medicosFiltrados = _todosMedicos;
    });
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(mensaje)));
  }

  void _irADetalleMedico(Medico medico) {
    context.go('/detalleCita', extra: medico);
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => context.go('/paciente'),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 36,
                            vertical: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 12.0,
                        ),
                        child: Container(
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
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                                  hint: const Text(
                                    'Seleccione una especialidad',
                                  ),
                                  items:
                                      _especialidades
                                          .map(
                                            (esp) => DropdownMenuItem(
                                              value: esp,
                                              child: Text(esp),
                                            ),
                                          )
                                          .toList(),
                                  onChanged: (value) => _filtrarMedicos(value),
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
                                const SizedBox(height: 16),
                                Text(
                                  'Médicos disponibles',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: const Color(0xFF00838F),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  constraints: const BoxConstraints(
                                    maxHeight: 400,
                                  ),
                                  child:
                                      _isLoading
                                          ? const Center(
                                            child: CircularProgressIndicator(
                                              color: Color(0xFF00838F),
                                            ),
                                          )
                                          : _medicosFiltrados.isEmpty
                                          ? Center(
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.search_off,
                                                  color: Colors.grey,
                                                  size: 48,
                                                ),
                                                const SizedBox(height: 12),
                                                Text(
                                                  'No hay médicos disponibles',
                                                  style: theme
                                                      .textTheme
                                                      .bodyLarge
                                                      ?.copyWith(
                                                        color: Colors.grey[700],
                                                      ),
                                                ),
                                              ],
                                            ),
                                          )
                                          : ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const BouncingScrollPhysics(),
                                            itemCount: _medicosFiltrados.length,
                                            itemBuilder: (context, index) {
                                              final medico =
                                                  _medicosFiltrados[index];
                                              return Card(
                                                elevation: 2,
                                                margin:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 6,
                                                    ),
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                child: InkWell(
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                  onTap:
                                                      () => _irADetalleMedico(
                                                        medico,
                                                      ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.symmetric(
                                                          horizontal: 4,
                                                          vertical: 4,
                                                        ),
                                                    child: ListTile(
                                                      contentPadding:
                                                          const EdgeInsets.symmetric(
                                                            horizontal: 8,
                                                            vertical: 4,
                                                          ),
                                                      leading: CircleAvatar(
                                                        radius: 24,
                                                        backgroundImage:
                                                            (medico
                                                                        .imagen
                                                                        ?.isNotEmpty ??
                                                                    false)
                                                                ? NetworkImage(
                                                                  medico
                                                                      .imagen!,
                                                                )
                                                                : const AssetImage(
                                                                      'assets/imgs/imagenDefault.webp',
                                                                    )
                                                                    as ImageProvider,
                                                      ),
                                                      title: Text(
                                                        '${medico.nombre} ${medico.apellido}',
                                                        style: theme
                                                            .textTheme
                                                            .bodyLarge
                                                            ?.copyWith(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600,
                                                            ),
                                                        overflow:
                                                            TextOverflow
                                                                .ellipsis,
                                                      ),
                                                      subtitle: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            medico.especialidad,
                                                            style: theme
                                                                .textTheme
                                                                .bodySmall
                                                                ?.copyWith(
                                                                  color:
                                                                      Colors
                                                                          .grey[600],
                                                                ),
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                          if (medico
                                                                  .centroDeSalud
                                                                  ?.nombre !=
                                                              null)
                                                            Text(
                                                              medico
                                                                  .centroDeSalud!
                                                                  .nombre,
                                                              style: theme
                                                                  .textTheme
                                                                  .bodySmall
                                                                  ?.copyWith(
                                                                    color:
                                                                        Colors
                                                                            .grey[500],
                                                                  ),
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                        ],
                                                      ),
                                                      trailing: Container(
                                                        width: 30,
                                                        height: 30,
                                                        padding:
                                                            const EdgeInsets.all(
                                                              6,
                                                            ),
                                                        decoration: BoxDecoration(
                                                          color: const Color(
                                                            0xFF00838F,
                                                            // ignore: deprecated_member_use
                                                          ).withOpacity(0.1),
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                6,
                                                              ),
                                                        ),
                                                        child: const Icon(
                                                          Icons
                                                              .arrow_forward_ios,
                                                          color: Color(
                                                            0xFF00838F,
                                                          ),
                                                          size: 14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                ),
                              ],
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

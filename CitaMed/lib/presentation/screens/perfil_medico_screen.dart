import 'package:citamed/infrastructures/models/medico.dart';
import 'package:citamed/services/services.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilMedicoScreen extends StatefulWidget {
  static const String name = 'PerfilMedicoScreen';
  const PerfilMedicoScreen({super.key});

  @override
  State<PerfilMedicoScreen> createState() => _PerfilMedicoScreenState();
}

class _PerfilMedicoScreenState extends State<PerfilMedicoScreen> {
  final MedicoService _medicoService = MedicoService();
  Medico? _medico;

  @override
  void initState() {
    super.initState();
    _cargarDatosMedico();
  }

  Future<void> _cargarDatosMedico() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    if (id != null) {
      final medico = await _medicoService.listarUnMedico(id);
      setState(() {
        _medico = medico;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    Theme.of(context);

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
                      horizontal: 8,
                      vertical: 16,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                          onPressed: () => context.go('/medico'),
                        ),
                        IconButton(
                          icon: const Icon(Icons.logout, color: Colors.white),
                          onPressed: () async {
                            final confirm = await showDialog<bool>(
                              context: context,
                              builder:
                                  (context) => AlertDialog(
                                    title: const Text('Cerrar sesión'),
                                    content: const Text(
                                      '¿Estás seguro de que deseas cerrar sesión?',
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, false),
                                        child: const Text('Cancelar'),
                                      ),
                                      TextButton(
                                        onPressed:
                                            () => Navigator.pop(context, true),
                                        child: const Text('Cerrar sesión'),
                                      ),
                                    ],
                                  ),
                            );
                            if (confirm == true) {
                              await AuthService.logout();
                              if (context.mounted) context.go('/login');
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                  // Contenido principal
                  Expanded(
                    child:
                        _medico == null
                            ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                            : Center(
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
                                        color: const Color(
                                          0xFF006064,
                                          // ignore: deprecated_member_use
                                        ).withOpacity(0.3),
                                        blurRadius: 30,
                                        offset: const Offset(0, 15),
                                      ),
                                    ],
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(24.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Center(
                                          child: CircleAvatar(
                                            radius: 60,
                                            backgroundImage:
                                                (_medico!.imagen?.isNotEmpty ??
                                                        false)
                                                    ? NetworkImage(
                                                      _medico!.imagen!,
                                                    )
                                                    : const AssetImage(
                                                          'assets/imgs/imagenDefault.webp',
                                                        )
                                                        as ImageProvider,
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        _buildReadOnlyField(
                                          'Nombre',
                                          _medico!.nombre,
                                        ),
                                        _buildReadOnlyField(
                                          'Apellidos',
                                          _medico!.apellido,
                                        ),
                                        _buildReadOnlyField(
                                          'DNI',
                                          _medico!.dni,
                                        ),
                                        _buildReadOnlyField(
                                          'Nº Seguridad Social',
                                          _medico!.numeroSeguridadSocial,
                                        ),
                                        _buildReadOnlyField(
                                          'Especialidad',
                                          _medico!.especialidad,
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

  Widget _buildReadOnlyField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ],
      ),
    );
  }
}

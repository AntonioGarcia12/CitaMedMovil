import 'package:CitaMed/infrastructures/models/medico.dart';
import 'package:CitaMed/presentation/widgets/widgets.dart';
import 'package:CitaMed/services/services.dart';
import 'package:CitaMed/utils/estado_utils.dart';
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
    if (_medico == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return PerfilUsuario(
      onBack: () => context.go('/medico'),
      onLogout: () => cerrarSesion(context),
      avatar: FotoPerfilMedicoWidget(
        image:
            (_medico!.imagen?.isNotEmpty ?? false)
                ? NetworkImage(_medico!.imagen!)
                : const AssetImage('assets/imgs/imagenDefault.webp')
                    as ImageProvider,
      ),
      form: Form(
        child: Column(
          children: [
            buildReadOnlyField('Nombre', _medico!.nombre),
            buildReadOnlyField('Apellidos', _medico!.apellidos),
            buildReadOnlyField('DNI', _medico!.dni ?? 'N/A'),
            buildReadOnlyField(
              'Nº Seguridad Social',
              _medico!.numeroSeguridadSocial ?? 'N/A',
            ),
            buildReadOnlyField('Especialidad', _medico!.especialidad),
          ],
        ),
      ),
      fields: [
        buildReadOnlyField('Nombre', _medico!.nombre),
        buildReadOnlyField('Apellidos', _medico!.apellidos),
        buildReadOnlyField('DNI', _medico!.dni ?? 'N/A'),
        buildReadOnlyField(
          'Nº Seguridad Social',
          _medico!.numeroSeguridadSocial ?? 'N/A',
        ),
        buildReadOnlyField('Especialidad', _medico!.especialidad),
      ],
    );
  }

  double min(double a, double b) => a < b ? a : b;
}

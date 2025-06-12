import 'dart:io';

import 'package:CitaMed/DTO/paciente_dto.dart';
import 'package:CitaMed/infrastructures/models/usuario.dart';
import 'package:CitaMed/services/services.dart';
import 'package:CitaMed/utils/estado_utils.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PerfilPacienteScreen extends StatefulWidget {
  static const String name = 'PerfilPacienteScreen';
  const PerfilPacienteScreen({super.key});

  @override
  State<PerfilPacienteScreen> createState() => _PerfilPacienteScreenState();
}

class _PerfilPacienteScreenState extends State<PerfilPacienteScreen> {
  final _formKey = GlobalKey<FormState>();
  final PacienteServices _pacienteService = PacienteServices();
  Usuario? _usuario;
  File? _imagenSeleccionada;
  bool _isLoading = false;
  final DateFormat _dateFormat = DateFormat('dd-MM-yyyy');
  final _telefonoController = TextEditingController();
  final _direccionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getInt('id');
    if (id != null) {
      final usuario = await _pacienteService.listarUnPaciente(id);
      setState(() {
        _usuario = usuario;
        _telefonoController.text = usuario.telefono!;
        _direccionController.text = usuario.direccion!;
      });
    }
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _imagenSeleccionada = File(picked.path);
      });
    }
  }

  Future<void> _guardarCambios() async {
    if (_formKey.currentState!.validate() && _usuario != null) {
      final telefonoNuevo = _telefonoController.text.trim();
      final direccionNueva = _direccionController.text.trim();

      final cambios = PacienteDto(
        telefono:
            telefonoNuevo.isNotEmpty && telefonoNuevo != _usuario!.telefono
                ? telefonoNuevo
                : null,
        direccion:
            direccionNueva.isNotEmpty && direccionNueva != _usuario!.direccion
                ? direccionNueva
                : null,
      );

      if (cambios.telefono == null &&
          cambios.direccion == null &&
          _imagenSeleccionada == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No hay cambios para guardar')),
        );
        return;
      }

      setState(() => _isLoading = true);

      try {
        await _pacienteService.editarPaciente(
          usuarioActual: _usuario!,
          cambios: cambios,
          archivo: _imagenSeleccionada,
        );

        final usuarioActualizado = await _pacienteService.listarUnPaciente(
          _usuario!.id,
        );

        setState(() => _usuario = usuarioActualizado);

        final prefs = await SharedPreferences.getInstance();
        if (usuarioActualizado.imagen != null &&
            usuarioActualizado.imagen!.isNotEmpty) {
          await prefs.setString('imagen', usuarioActualizado.imagen!);
        }

        PaintingBinding.instance.imageCache.clear();
        PaintingBinding.instance.imageCache.clearLiveImages();

        // ignore: use_build_context_synchronously
        mostrarExito(context, 'Perfil actualizado');
        // ignore: use_build_context_synchronously
        context.pop(true);
      } catch (e) {
        // ignore: use_build_context_synchronously
        mostrarError(context, 'Error al actualizar el perfil');
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _telefonoController.dispose();
    _direccionController.dispose();
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
                          onPressed: () => context.go('/paciente'),
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
                  Expanded(
                    child:
                        _usuario == null
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
                                    child: Form(
                                      key: _formKey,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Center(
                                            child: GestureDetector(
                                              onTap: _seleccionarImagen,
                                              child: Stack(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 60,
                                                    backgroundImage:
                                                        _imagenSeleccionada !=
                                                                null
                                                            ? FileImage(
                                                              _imagenSeleccionada!,
                                                            )
                                                            : (_usuario
                                                                    ?.imagen
                                                                    ?.isNotEmpty ??
                                                                false)
                                                            ? NetworkImage(
                                                              _usuario!.imagen!,
                                                            )
                                                            : const AssetImage(
                                                                  'assets/imgs/imagenDefault.webp',
                                                                )
                                                                as ImageProvider,
                                                  ),
                                                  Positioned(
                                                    bottom: 0,
                                                    right: 0,
                                                    child: CircleAvatar(
                                                      backgroundColor:
                                                          Colors.white,
                                                      radius: 16,
                                                      child: Icon(
                                                        Icons.edit,
                                                        size: 18,
                                                        color:
                                                            theme.primaryColor,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 24),
                                          buildReadOnlyField(
                                            'Nombre',
                                            _usuario!.nombre,
                                          ),
                                          buildReadOnlyField(
                                            'Apellidos',
                                            _usuario!.apellidos,
                                          ),
                                          buildReadOnlyField(
                                            'Correo electrónico',
                                            _usuario!.email,
                                          ),
                                          buildReadOnlyField(
                                            'DNI',
                                            _usuario!.dni ?? 'N/A',
                                          ),
                                          buildReadOnlyField(
                                            'Nº Seguridad Social',
                                            _usuario!.numeroSeguridadSocial ??
                                                'N/A',
                                          ),
                                          buildReadOnlyField(
                                            'Sexo',
                                            _usuario!.sexo ?? 'N/A',
                                          ),
                                          buildReadOnlyField(
                                            'Fecha de nacimiento',
                                            _usuario!.fechaNacimiento != null
                                                ? _dateFormat.format(
                                                  _usuario!.fechaNacimiento!,
                                                )
                                                : 'N/A',
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _telefonoController,
                                            decoration: InputDecoration(
                                              labelText: 'Teléfono',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            keyboardType: TextInputType.phone,
                                            validator:
                                                (value) =>
                                                    value == null ||
                                                            value.isEmpty
                                                        ? 'Campo requerido'
                                                        : null,
                                          ),
                                          const SizedBox(height: 16),
                                          TextFormField(
                                            controller: _direccionController,
                                            decoration: InputDecoration(
                                              labelText: 'Dirección',
                                              border: OutlineInputBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            validator:
                                                (value) =>
                                                    value == null ||
                                                            value.isEmpty
                                                        ? 'Campo requerido'
                                                        : null,
                                          ),
                                          const SizedBox(height: 32),
                                          ElevatedButton.icon(
                                            onPressed:
                                                _isLoading
                                                    ? null
                                                    : _guardarCambios,

                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: const Color(
                                                0xFF00838F,
                                              ),
                                              foregroundColor: Colors.white,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    vertical: 12,
                                                  ),
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                            ),
                                            label: Text(
                                              _isLoading
                                                  ? 'Guardando...'
                                                  : 'Guardar',
                                              style: const TextStyle(
                                                fontSize: 16,
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

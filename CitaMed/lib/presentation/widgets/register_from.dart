import 'dart:io';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../infrastructures/models/usuario.dart';
import '../../services/auth_services.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final Usuario _usuario = Usuario.vacio();
  File? _imagenSeleccionada;
  bool _isLoading = false;
  final _dateController = TextEditingController();
  bool _ocultarContrasenya = true;

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _seleccionarImagen() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _imagenSeleccionada = File(picked.path);
      });
    }
  }

  Future<void> _seleccionarFecha() async {
    final DateTime ahora = DateTime.now();
    final DateTime fechaMinima = DateTime(ahora.year - 100, 1, 1);
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _usuario.fechaNacimiento,
      firstDate: fechaMinima,
      lastDate: ahora,
    );
    if (pickedDate != null) {
      final formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);
      setState(() {
        _dateController.text = formattedDate;
        _usuario.fechaNacimiento = pickedDate;
      });
    }
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_usuario.sexo == null) {
      return;
    }
    _formKey.currentState!.save();

    setState(() {
      _isLoading = true;
    });

    try {
      await AuthService.registrarPaciente(
        usuario: _usuario,
        archivo: _imagenSeleccionada,
      );
      _showOverlayMessage("Registro exitoso");

      Future.delayed(const Duration(seconds: 2), () {
        context.go('/login');
      });
    } catch (e) {
      setState(() {});
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showOverlayMessage(String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder:
          (context) => Positioned(
            top: MediaQuery.of(context).size.height * 0.1,
            left: MediaQuery.of(context).size.width * 0.1,
            right: MediaQuery.of(context).size.width * 0.1,
            child: Material(
              color: Colors.transparent,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 24.0,
                ),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
    );

    overlay.insert(overlayEntry);

    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildProfileImagePicker(),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: _buildCampoTexto(
                  'Nombre',
                  (val) => _usuario.nombre = val!,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCampoTexto(
                  'Apellidos',
                  (val) => _usuario.apellidos = val!,
                ),
              ),
            ],
          ),
          _buildCampoTexto(
            'Correo electrónico',
            (val) => _usuario.email = val!,
            tipo: TextInputType.emailAddress,
          ),
          _buildPasswordField(),
          _buildCampoTexto(
            'Teléfono',
            (val) => _usuario.telefono = val!,
            tipo: TextInputType.phone,
          ),
          _buildCampoTexto('Dirección', (val) => _usuario.direccion = val!),
          _buildCampoTexto('DNI', (val) => _usuario.dni = val!),
          _buildCampoTexto(
            'Nº Seguridad Social',
            (val) => _usuario.numeroSeguridadSocial = val!,
          ),
          _buildDatePicker(),
          _buildSexoSelector(),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _registrar,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00838F),
                foregroundColor: Colors.white,
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child:
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                        'Registrarse',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 12.0),
          child: Text(
            'Foto de perfil',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              GestureDetector(
                onTap: _seleccionarImagen,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(75),
                    border: Border.all(
                      color: const Color(0xFF00838F),
                      width: 2,
                    ),
                  ),
                  child:
                      _imagenSeleccionada != null
                          ? ClipRRect(
                            borderRadius: BorderRadius.circular(75),
                            child: Image.file(
                              _imagenSeleccionada!,
                              width: 150,
                              height: 150,
                              fit: BoxFit.cover,
                            ),
                          )
                          : const Icon(
                            Icons.add_a_photo,
                            size: 40,
                            color: Color(0xFF00838F),
                          ),
                ),
              ),
              if (_imagenSeleccionada != null)
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => setState(() => _imagenSeleccionada = null),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.black26, blurRadius: 4),
                        ],
                      ),
                      padding: const EdgeInsets.all(4),
                      child: const Icon(
                        Icons.close,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCampoTexto(
    String label,
    Function(String?) onSaved, {
    TextInputType tipo = TextInputType.text,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
              prefixIcon != null
                  ? Icon(prefixIcon, color: const Color(0xFF00838F))
                  : null,
          filled: true,
          fillColor: Colors.grey.shade50,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF00838F), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade300),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
        ),
        keyboardType: tipo,
        onSaved: onSaved,
        validator:
            validator ??
            ((value) =>
                (value == null || value.isEmpty) ? 'Campo requerido' : null),
      ),
    );
  }

  Widget _buildSexoSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0, bottom: 8.0),
          child: Text(
            'Sexo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('Masculino'),
                value: 'Hombre',
                groupValue: _usuario.sexo,
                activeColor: const Color(0xFF00838F),
                onChanged: (value) => setState(() => _usuario.sexo = value!),
              ),
              Divider(height: 1, color: Colors.grey.shade200),
              RadioListTile<String>(
                title: const Text('Femenino'),
                value: 'Mujer',
                groupValue: _usuario.sexo,
                activeColor: const Color(0xFF00838F),
                onChanged: (value) => setState(() => _usuario.sexo = value!),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        obscureText: _ocultarContrasenya,
        decoration: InputDecoration(
          labelText: 'Contraseña',
          suffixIcon: IconButton(
            icon: Icon(
              _ocultarContrasenya
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: const Color(0xFF00838F),
            ),
            onPressed: () {
              setState(() {
                _ocultarContrasenya = !_ocultarContrasenya;
              });
            },
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF00838F), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade300),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'La contraseña es obligatoria';
          }
          if (value.length < 6) {
            return 'La contraseña debe tener al menos 6 caracteres';
          }
          return null;
        },
        onSaved: (value) => _usuario.contrasenya = value!,
      ),
    );
  }

  Widget _buildDatePicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: _dateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Fecha de nacimiento',
          hintText: 'DD/MM/AAAA',
          filled: true,
          fillColor: Colors.grey.shade50,
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFF00838F), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade300),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.red.shade400, width: 2),
          ),
        ),
        onTap: _seleccionarFecha,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'La fecha de nacimiento es obligatoria';
          }
          return null;
        },
      ),
    );
  }
}

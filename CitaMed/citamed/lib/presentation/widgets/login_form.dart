import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/services.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _contrasenyaController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final AuthService _authService = AuthService();

  bool _verContrasenya = false;
  String? _errorMensaje;
  bool _isLoading = false;

  Future<void> _iniciarSesion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMensaje = null;
    });

    try {
      final usuario = await _authService.login(
        _emailController.text.trim(),
        _contrasenyaController.text.trim(),
      );
      if (usuario.rol == 'PACIENTE') {
        context.go('/paciente');
      } else if (usuario.rol == 'MEDICO') {
        context.go('/medico');
      }
    } catch (e) {
      setState(() {
        _errorMensaje = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          if (_errorMensaje != null)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 24),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.red.shade400),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _errorMensaje!,
                      style: TextStyle(color: Colors.red.shade700),
                    ),
                  ),
                ],
              ),
            ),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: _inputDecoration(
              label: 'Correo electrónico',
              hint: '',
              icon: Icons.email_outlined,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'El correo es obligatorio';
              }
              if (!value.contains('@')) {
                return 'Ingrese un correo electrónico válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          TextFormField(
            controller: _contrasenyaController,
            obscureText: !_verContrasenya,
            decoration: _inputDecoration(
              label: 'Contraseña',
              hint: '',
              icon: Icons.lock_outlined,
              suffix: IconButton(
                icon: Icon(
                  _verContrasenya
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  color: const Color(0xFF00838F),
                ),
                onPressed: () => setState(() {
                  _verContrasenya = !_verContrasenya;
                }),
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'La contraseña es obligatoria';
              }
              return null;
            },
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _iniciarSesion,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00838F),
                foregroundColor: Colors.white,
                elevation: 2,
                shadowColor: const Color(0xFF00838F).withOpacity(0.5),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2.5,
                      ),
                    )
                  : const Text(
                      'Iniciar sesión',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: const Color(0xFF00838F)),
      suffixIcon: suffix,
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
      floatingLabelStyle: const TextStyle(color: Color(0xFF00838F)),
    );
  }
}

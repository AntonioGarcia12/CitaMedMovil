import 'package:citamed/presentation/widgets/register_from.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class RegisterScreen extends StatelessWidget {
  static const String name = '/registrar';
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F7FA), Color(0xFFE3F2FD)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Align(
            alignment: Alignment.topCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 550),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        // ignore: deprecated_member_use
                        color: Colors.black12.withOpacity(0.08),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Hero(
                        tag: 'logo',
                        child: Image.asset(
                          'assets/imgs/logoCitaMed.webp',
                          height: 70,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Registro de Paciente',
                        style: theme.textTheme.headlineSmall?.copyWith(
                          color: const Color(0xFF00838F),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const SizedBox(height: 24),
                      const RegisterForm(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '¿Ya tienes cuenta?',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                          TextButton(
                            onPressed: () => context.go('/login'),
                            child: const Text(
                              'Inicia sesión',
                              style: TextStyle(
                                color: Color(0xFF00838F),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(color: Color(0xFFE0F7FA)),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

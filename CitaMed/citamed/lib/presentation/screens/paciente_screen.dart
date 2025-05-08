import 'package:flutter/material.dart';

class PacienteScreen extends StatelessWidget {
  static const String name = 'PacienteScreen';
  const PacienteScreen({Key? key});
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paciente Screen'),
      ),
      body: const Center(
        child: Text('Bienvenido a la pantalla del paciente'),
      ),
    );
  }
}

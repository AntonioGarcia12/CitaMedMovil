import 'package:flutter/material.dart';

class MedicoScreen extends StatelessWidget {
  static const String name = 'MedicoScreen';
  const MedicoScreen({Key? key});
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Medico Screen'),
      ),
      body: const Center(
        child: Text('Bienvenido a la pantalla del médico'),
      ),
    );
  }
}

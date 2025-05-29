import 'package:flutter/material.dart';

class FotoPerfilMedicoWidget extends StatelessWidget {
  final ImageProvider image;

  const FotoPerfilMedicoWidget({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(radius: 100, backgroundImage: image);
  }
}

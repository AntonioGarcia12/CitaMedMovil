import 'package:flutter/material.dart';

class FotoPerfilWidget extends StatelessWidget {
  final ImageProvider image;
  final VoidCallback onTap;

  const FotoPerfilWidget({super.key, required this.image, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CircleAvatar(radius: 60, backgroundImage: image),
          Positioned(
            bottom: 0,
            right: 0,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              radius: 16,
              child: Icon(Icons.edit, size: 18, color: theme.primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}

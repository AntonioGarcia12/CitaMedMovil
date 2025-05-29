import 'package:flutter/material.dart';

class InfoCardWidget extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final Color? subtitleColor;

  const InfoCardWidget({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.onTap,
    this.subtitleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 15,
            color: subtitleColor,
          ),
        ),
        trailing: Icon(icon, color: const Color(0xFF00838F)),
        onTap: onTap,
      ),
    );
  }
}

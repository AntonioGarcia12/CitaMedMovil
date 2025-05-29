import 'package:CitaMed/infrastructures/models/medico.dart';
import 'package:flutter/material.dart';

class InformacionMedicoWidget extends StatelessWidget {
  final Medico medico;

  const InformacionMedicoWidget({super.key, required this.medico});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 35,
          backgroundImage:
              (medico.imagen?.isNotEmpty ?? false)
                  ? NetworkImage(medico.imagen!)
                  : const AssetImage('assets/imgs/imagenDefault.webp')
                      as ImageProvider,
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                medico.sexo == 'Mujer'
                    ? 'Dra. ${medico.nombre} ${medico.apellidos}'
                    : 'Dr. ${medico.nombre} ${medico.apellidos}',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF00838F),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                medico.especialidad,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                ),
              ),
              if (medico.centroDeSalud?.nombre != null) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        medico.centroDeSalud!.nombre,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

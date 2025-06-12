import 'package:CitaMed/infrastructures/models/cita.dart';
import 'package:CitaMed/utils/estado_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class CitaCardWidget extends StatelessWidget {
  final Cita cita;
  final String nombrePersona;
  final String especialidad;
  final VoidCallback onTap;
  final Function(String accion) onEstadoUpdate;

  const CitaCardWidget({
    super.key,
    required this.cita,
    required this.nombrePersona,
    required this.especialidad,
    required this.onTap,
    required this.onEstadoUpdate,
  });

  @override
  Widget build(BuildContext context) {
    return Slidable(
      key: ValueKey(cita.id),
      startActionPane:
          (cita.estado == 'PENDIENTE')
              ? ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.25,
                children: [
                  SlidableAction(
                    onPressed: (_) => onEstadoUpdate('CONFIRMADA'),
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    icon: Icons.check_circle,
                  ),
                ],
              )
              : null,
      endActionPane:
          (cita.estado == 'PENDIENTE' || cita.estado == 'CONFIRMADA')
              ? ActionPane(
                motion: const DrawerMotion(),
                extentRatio: 0.25,
                children: [
                  SlidableAction(
                    onPressed: (_) => onEstadoUpdate('CANCELADA'),
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.cancel,
                  ),
                ],
              )
              : null,
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: CircleAvatar(
            backgroundColor: getEstadoColor(cita.estado!),
            child: Icon(
              getEstadoIcon(cita.estado!),
              color: Colors.white,
              size: 20,
            ),
          ),
          title: Text(
            nombrePersona,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 4),
              Text(
                especialidad,
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                DateFormat('dd/MM/yyyy HH:mm').format(cita.fecha),
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  // ignore: deprecated_member_use
                  color: getEstadoColor(cita.estado!).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  getEstadoText(cita.estado!),
                  style: TextStyle(
                    color: getEstadoColor(cita.estado!),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          trailing: const Icon(
            Icons.arrow_forward_ios,
            size: 16,
            color: Colors.grey,
          ),
        ),
      ),
    );
  }
}

import 'package:CitaMed/infrastructures/models/historial_medico.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

class HistorialListWidget extends StatelessWidget {
  final List<HistorialMedico> historiales;
  final Function(int)? onDelete;
  final Function(int)? onEdit;

  const HistorialListWidget({
    super.key,
    required this.historiales,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Historiales (${historiales.length})',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00838F),
          ),
        ),
        const SizedBox(height: 16),
        ...historiales.map(
          (historial) => _buildSlidableCard(context, historial),
        ),
      ],
    );
  }

  Widget _buildSlidableCard(BuildContext context, HistorialMedico historial) {
    return Slidable(
      key: ValueKey(historial.id),
      startActionPane: ActionPane(
        motion: const DrawerMotion(),
        dismissible: null,
        children: [
          SlidableAction(
            onPressed: (_) {
              if (onEdit != null) {
                onEdit!(historial.paciente.id);
              }
            },
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
            icon: Icons.edit,
            label: 'Editar',
          ),
        ],
      ),
      endActionPane: ActionPane(
        motion: const DrawerMotion(),
        dismissible: DismissiblePane(
          onDismissed: () {
            if (onDelete != null) onDelete!(historial.id!);
          },
        ),
        children: [
          SlidableAction(
            onPressed: (_) => _showDeleteConfirmDialog(context, historial),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            label: 'Borrar',
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ),
            childrenPadding: const EdgeInsets.only(
              left: 16,
              right: 16,
              bottom: 16,
            ),
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            title: Row(
              children: [
                _buildPatientAvatar(historial),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${historial.paciente.nombre} ${historial.paciente.apellidos}',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'DNI: ${historial.paciente.dni}',
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            trailing: const Icon(Icons.expand_more),
            children: [
              const Divider(),
              const SizedBox(height: 8),
              _buildInfoSection(context, 'Diagnóstico', historial.diagnostico),
              const SizedBox(height: 16),
              _buildInfoSection(context, 'Tratamiento', historial.tratamiento),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPatientAvatar(HistorialMedico historial) {
    if (historial.paciente.imagen != null &&
        historial.paciente.imagen!.isNotEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: const Color(0xFFE0F7FA),
        backgroundImage: NetworkImage(historial.paciente.imagen!),
        onBackgroundImageError: (exception, stackTrace) {},
      );
    } else {
      return const CircleAvatar(
        radius: 20,
        backgroundColor: Color(0xFFE0F7FA),
        child: Icon(Icons.person, color: Color(0xFF00838F)),
      );
    }
  }

  Widget _buildInfoSection(BuildContext context, String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: const Color(0xFF00838F),
          ),
        ),
        const SizedBox(height: 4),
        Text(content, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  void _showDeleteConfirmDialog(
    BuildContext context,
    HistorialMedico historial,
  ) {
    if (onDelete == null) return;

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Confirmar eliminación'),
            content: Text(
              '¿Estás seguro que deseas eliminar el historial médico de ${historial.paciente.nombre} ${historial.paciente.apellidos}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  onDelete!(historial.id!);
                  Navigator.pop(context);
                },
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Eliminar'),
              ),
            ],
          ),
    );
  }
}

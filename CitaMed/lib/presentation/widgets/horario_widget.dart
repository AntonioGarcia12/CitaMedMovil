import 'package:citamed/infrastructures/models/horario_medico.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class HorarioListWidget extends StatelessWidget {
  final List<HorarioMedico> horarios;
  final bool isLoading;
  final Function(int) onDelete;

  const HorarioListWidget({
    required this.horarios,
    required this.isLoading,
    required this.onDelete,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00838F)),
      );
    }

    if (horarios.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('assets/imgs/iconoCitaMed.webp', height: 64),
          const SizedBox(height: 24),
          Text(
            'No hay horarios disponibles',
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF00838F),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Crea tu primer horario de atención presionando el botón + abajo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/imgs/iconoCitaMed.webp', height: 48),
            const SizedBox(width: 12),
            Text(
              'Horarios de Atención',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: const Color(0xFF00838F),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        const Text(
          'Desliza el horario para editar o eliminar',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
        const SizedBox(height: 16),
        ...horarios.map((h) {
          final inicio = TimeOfDay.fromDateTime(h.horaInicio);
          final fin = TimeOfDay.fromDateTime(h.horaFin);
          final diaFormateado = DateFormat('dd-MM-yyyy').format(h.dia);
          final label =
              '$diaFormateado: ${inicio.format(context)} - ${fin.format(context)}';

          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Slidable(
              key: ValueKey(h.id),
              startActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (_) => context.go('/editarHorario/${h.id}'),
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    icon: Icons.edit,
                    label: 'Editar',
                    borderRadius: const BorderRadius.horizontal(
                      left: Radius.circular(12),
                    ),
                  ),
                ],
              ),
              endActionPane: ActionPane(
                motion: const DrawerMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) async {
                      final confirm = await showDialog<bool>(
                        context: context,
                        builder:
                            (context) => AlertDialog(
                              title: const Text('Confirmar'),
                              content: const Text(
                                '¿Deseas eliminar este horario?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed:
                                      () => Navigator.pop(context, false),
                                  child: const Text('Cancelar'),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context, true),
                                  child: const Text('Borrar'),
                                ),
                              ],
                            ),
                      );
                      if (confirm == true) {
                        onDelete(h.id!);
                      }
                    },
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    icon: Icons.delete,
                    label: 'Borrar',
                    borderRadius: const BorderRadius.horizontal(
                      right: Radius.circular(12),
                    ),
                  ),
                ],
              ),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 1,
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF00838F).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.access_time,
                      color: Color(0xFF00838F),
                    ),
                  ),
                  title: Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}

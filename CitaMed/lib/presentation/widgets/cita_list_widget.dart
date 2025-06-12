import 'package:CitaMed/infrastructures/models/cita.dart';
import 'package:CitaMed/utils/estado_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class CitasListWidget extends StatelessWidget {
  final List<Cita> citas;
  final bool isLoading;
  final String? errorMessage;
  final Function(Cita) onTap;
  final Function(Cita)? onEditarTap;
  final Function(Cita, String)? onEstadoUpdate;
  final String Function(Cita) nombrePersonaBuilder;
  final String Function(Cita) especialidadBuilder;

  const CitasListWidget({
    super.key,
    required this.citas,
    required this.isLoading,
    this.errorMessage,
    required this.onTap,
    this.onEditarTap,
    this.onEstadoUpdate,
    required this.nombrePersonaBuilder,
    required this.especialidadBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00838F)),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Text(
          'Error al cargar citas:\n$errorMessage',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.red),
        ),
      );
    }

    if (citas.isEmpty) {
      return Center(
        child: Text(
          'No hay citas disponibles',
          style: theme.textTheme.titleMedium?.copyWith(color: Colors.grey),
        ),
      );
    }

    return ListView.builder(
      itemCount: citas.length,
      itemBuilder: (context, index) {
        final cita = citas[index];

        final mostrarEstadoPane =
            onEstadoUpdate != null &&
            (cita.estado == 'PENDIENTE' || cita.estado == 'CONFIRMADA');

        return Slidable(
          key: ValueKey(cita.id),

          startActionPane:
              onEditarTap != null
                  ? ActionPane(
                    motion: const ScrollMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (_) => onEditarTap!(cita),
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        icon: Icons.edit,
                      ),
                    ],
                  )
                  : null,

          endActionPane:
              mostrarEstadoPane
                  ? ActionPane(
                    motion: const DrawerMotion(),

                    extentRatio: cita.estado == 'PENDIENTE' ? 0.50 : 0.25,
                    children:
                        cita.estado == 'PENDIENTE'
                            ? [
                              SlidableAction(
                                onPressed:
                                    (_) => onEstadoUpdate!(cita, 'confirmar'),
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                                icon: Icons.check,
                              ),

                              SlidableAction(
                                onPressed:
                                    (_) => onEstadoUpdate!(cita, 'cancelar'),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.cancel,
                              ),
                            ]
                            : [
                              SlidableAction(
                                onPressed:
                                    (_) => onEstadoUpdate!(cita, 'cancelar'),
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                                icon: Icons.cancel,
                              ),
                            ],
                  )
                  : null,

          child: ListTile(
            onTap: () => onTap(cita),
            leading: CircleAvatar(
              backgroundColor: getEstadoColor(cita.estado!),
              child: Icon(getEstadoIcon(cita.estado!), color: Colors.white),
            ),
            title: Text(
              nombrePersonaBuilder(cita),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(especialidadBuilder(cita)),
                Text(
                  DateFormat('dd/MM/yyyy HH:mm').format(cita.fecha),
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

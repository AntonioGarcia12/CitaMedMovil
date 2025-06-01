import 'package:CitaMed/infrastructures/models/cita.dart';
import 'package:CitaMed/utils/estado_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:intl/intl.dart';

class CitasListPacienteWidget extends StatelessWidget {
  final List<Cita> citas;
  final bool isLoading;
  final String? errorMessage;
  final Function(Cita) onCitaTap;
  final Function(Cita, String)? onEstadoUpdate;
  final String Function(Cita) nombrePersonaBuilder;
  final String Function(Cita) especialidadBuilder;

  const CitasListPacienteWidget({
    super.key,
    required this.citas,
    required this.isLoading,
    this.errorMessage,
    required this.onCitaTap,
    this.onEstadoUpdate,
    required this.nombrePersonaBuilder,
    required this.especialidadBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF00838F)),
            SizedBox(height: 16),
            Text(
              'Cargando citas...',
              style: TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 12),
            Text(
              'Error al cargar las citas',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: Colors.red[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    if (citas.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              color: Colors.grey,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'No tienes citas programadas',
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.grey[700],
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Las nuevas citas aparecerán aquí',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: citas.length,
      itemBuilder: (context, index) {
        final cita = citas[index];

        final mostrarCancelar =
            onEstadoUpdate != null &&
            (cita.estado == 'PENDIENTE' || cita.estado == 'CONFIRMADA');

        return Slidable(
          key: ValueKey(cita.id),
          endActionPane:
              mostrarCancelar
                  ? ActionPane(
                    motion: const DrawerMotion(),
                    extentRatio: 0.25,
                    children: [
                      SlidableAction(
                        onPressed: (_) => onEstadoUpdate!(cita, 'cancelar'),
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.cancel,
                      ),
                    ],
                  )
                  : null,
          child: ListTile(
            onTap: () => onCitaTap(cita),
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

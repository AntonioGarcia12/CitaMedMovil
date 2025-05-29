import 'package:CitaMed/infrastructures/models/horario_medico.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HorariosDisponiblesWidget extends StatelessWidget {
  final List<HorarioMedico> horarios;
  final HorarioMedico? horarioSeleccionado;
  final void Function(HorarioMedico) onSeleccionar;

  const HorariosDisponiblesWidget({
    super.key,
    required this.horarios,
    required this.horarioSeleccionado,
    required this.onSeleccionar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat('dd-MM-yyyy');
    final timeFormat = DateFormat('HH-mm');

    final Map<String, List<HorarioMedico>> agrupados = {};
    for (final horario in horarios) {
      final key = DateFormat('yyyy-MM-dd').format(horario.dia);
      agrupados.putIfAbsent(key, () => []).add(horario);
    }

    return Column(
      children:
          agrupados.entries.map((entry) {
            final fecha = entry.value.first.dia;
            final diaFormateado = dateFormat.format(fecha);

            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.calendar_today,
                          size: 18,
                          color: Color(0xFF00838F),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          diaFormateado,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children:
                          entry.value.map((horario) {
                            final isSelected = horario == horarioSeleccionado;
                            return InkWell(
                              onTap: () => onSeleccionar(horario),
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color:
                                      isSelected
                                          ? const Color(0xFF00838F)
                                          : const Color(0xFFE0F7FA),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color:
                                        isSelected
                                            ? const Color(0xFF00838F)
                                            : Colors.transparent,
                                  ),
                                ),
                                child: Text(
                                  '${timeFormat.format(horario.horaInicio)} - ${timeFormat.format(horario.horaFin)}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color:
                                        isSelected
                                            ? Colors.white
                                            : Colors.black87,
                                    fontWeight:
                                        isSelected
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
    );
  }
}

Widget construirMensajeVacio(ThemeData theme) {
  return Container(
    padding: const EdgeInsets.symmetric(vertical: 30),
    alignment: Alignment.center,
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.event_busy, color: Colors.grey, size: 48),
        const SizedBox(height: 12),
        Text(
          'No hay horarios disponibles',
          style: theme.textTheme.bodyLarge?.copyWith(color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        Text(
          'Por favor, intente con otro médico',
          style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
        ),
      ],
    ),
  );
}

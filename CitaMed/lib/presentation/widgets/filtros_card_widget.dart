import 'package:flutter/material.dart';

class FiltrosCitasWidget extends StatelessWidget {
  final String? estadoSeleccionado;
  final List<String> estadosDisponibles;
  final DateTime? fechaInicio;
  final DateTime? fechaFin;
  final Function(String?) onEstadoChanged;
  final VoidCallback onReiniciar;

  /// Si es null, no se muestran los selectores de fecha
  final Function(bool esInicio)? onSeleccionarFecha;

  const FiltrosCitasWidget({
    super.key,
    required this.estadoSeleccionado,
    required this.estadosDisponibles,
    required this.fechaInicio,
    required this.fechaFin,
    required this.onEstadoChanged,
    required this.onReiniciar,
    this.onSeleccionarFecha,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Filtros',
          style: theme.textTheme.titleMedium?.copyWith(
            color: const Color(0xFF00838F),
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),

        // Fila de estado + botón de reiniciar
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: estadoSeleccionado,
                isExpanded: true,
                hint: const Text('Estado'),
                items:
                    estadosDisponibles
                        .map(
                          (estado) => DropdownMenuItem(
                            value: estado,
                            child: Text(estado),
                          ),
                        )
                        .toList(),
                onChanged: onEstadoChanged,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.refresh, color: Color(0xFF00838F)),
              onPressed: onReiniciar,
            ),
          ],
        ),

        const SizedBox(height: 8),

        // Solo si onSeleccionarFecha NO es null mostramos los selectores de fecha
        if (onSeleccionarFecha != null)
          Row(
            children: [
              Expanded(
                child: _buildFechaSelector(
                  context,
                  label: 'Desde',
                  fecha: fechaInicio,
                  onTap: () => onSeleccionarFecha!(true),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFechaSelector(
                  context,
                  label: 'Hasta',
                  fecha: fechaFin,
                  onTap: () => onSeleccionarFecha!(false),
                ),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildFechaSelector(
    BuildContext context, {
    required String label,
    required DateTime? fecha,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              fecha != null
                  ? '${fecha.day}/${fecha.month}/${fecha.year}'
                  : label,
              style: TextStyle(
                color: fecha != null ? Colors.black87 : Colors.grey.shade600,
              ),
            ),
            const Icon(
              Icons.calendar_today,
              size: 16,
              color: Color(0xFF00838F),
            ),
          ],
        ),
      ),
    );
  }
}

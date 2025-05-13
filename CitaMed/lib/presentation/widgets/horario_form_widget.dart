import 'package:citamed/infrastructures/models/medico.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HorarioFormWidget extends StatefulWidget {
  final Medico? medico;
  final DateTime? initialDia;
  final TimeOfDay? initialHoraInicio;
  final TimeOfDay? initialHoraFin;
  final bool isLoading;
  final Function(DateTime dia, DateTime horaInicio, DateTime horaFin) onSave;
  final String buttonText;
  final String loadingText;

  const HorarioFormWidget({
    super.key,
    required this.medico,
    this.initialDia,
    this.initialHoraInicio,
    this.initialHoraFin,
    required this.isLoading,
    required this.onSave,
    this.buttonText = 'Guardar horario',
    this.loadingText = 'Guardando...',
  });

  @override
  State<HorarioFormWidget> createState() => _HorarioFormWidgetState();
}

class _HorarioFormWidgetState extends State<HorarioFormWidget> {
  final _formKey = GlobalKey<FormState>();
  DateTime? _dia;
  TimeOfDay? _horaInicio;
  TimeOfDay? _horaFin;

  @override
  void initState() {
    super.initState();
    _dia = widget.initialDia;
    _horaInicio = widget.initialHoraInicio;
    _horaFin = widget.initialHoraFin;
  }

  Future<void> _seleccionarDia() async {
    final now = DateTime.now();
    final firstAllowed = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _dia ?? firstAllowed,
      firstDate: firstAllowed,
      lastDate: DateTime(now.year + 1, now.month, now.day),
    );
    if (picked != null) setState(() => _dia = picked);
  }

  Future<void> _seleccionarHoraInicio() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaInicio ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _horaInicio = picked);
  }

  Future<void> _seleccionarHoraFin() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _horaFin ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _horaFin = picked);
  }

  void _procesarGuardar() {
    if (!_formKey.currentState!.validate()) return;
    if (_dia == null || _horaInicio == null || _horaFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor completa todos los campos')),
      );
      return;
    }

    final onlyDate = DateTime(_dia!.year, _dia!.month, _dia!.day);
    final inicio = DateTime(
      onlyDate.year,
      onlyDate.month,
      onlyDate.day,
      _horaInicio!.hour,
      _horaInicio!.minute,
    );
    final fin = DateTime(
      onlyDate.year,
      onlyDate.month,
      onlyDate.day,
      _horaFin!.hour,
      _horaFin!.minute,
    );

    widget.onSave(onlyDate, inicio, fin);
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                // ignore: deprecated_member_use
                color: const Color(0xFF00838F).withOpacity(0.5),
              ),
            ),
            child: ListTile(
              title: Text(
                _dia != null
                    ? DateFormat('dd-MM-yyyy').format(_dia!)
                    : 'Seleccionar fecha',
                style: TextStyle(
                  color: _dia != null ? Colors.black87 : Colors.black54,
                ),
              ),
              trailing: const Icon(
                Icons.calendar_today,
                color: Color(0xFF00838F),
              ),
              onTap: _seleccionarDia,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Selector de hora inicio
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                // ignore: deprecated_member_use
                color: const Color(0xFF00838F).withOpacity(0.5),
              ),
            ),
            child: ListTile(
              title: Text(
                _horaInicio != null
                    ? 'Inicio: ${_horaInicio!.format(context)}'
                    : 'Seleccionar hora inicio',
                style: TextStyle(
                  color: _horaInicio != null ? Colors.black87 : Colors.black54,
                ),
              ),
              trailing: const Icon(Icons.access_time, color: Color(0xFF00838F)),
              onTap: _seleccionarHoraInicio,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Selector de hora fin
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                // ignore: deprecated_member_use
                color: const Color(0xFF00838F).withOpacity(0.5),
              ),
            ),
            child: ListTile(
              title: Text(
                _horaFin != null
                    ? 'Fin: ${_horaFin!.format(context)}'
                    : 'Seleccionar hora fin',
                style: TextStyle(
                  color: _horaFin != null ? Colors.black87 : Colors.black54,
                ),
              ),
              trailing: const Icon(Icons.access_time, color: Color(0xFF00838F)),
              onTap: _seleccionarHoraFin,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: widget.isLoading ? null : _procesarGuardar,
            icon: const Icon(Icons.save),
            label: Text(
              widget.isLoading ? widget.loadingText : widget.buttonText,
            ),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              backgroundColor: const Color(0xFF00838F),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

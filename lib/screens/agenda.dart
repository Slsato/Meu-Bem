import 'package:flutter/material.dart';
import 'package:health_truck/constants_colors.dart';
import 'package:health_truck/widget/text_labels.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widget/button.dart';
import '../widget/default_layout.dart';
import '../widget/dialog-exclusao.dart';
import '../widget/snack_bar.dart';
import '../widget/textFormField.dart';

class AgendaMedica extends StatefulWidget {
  const AgendaMedica({super.key});

  @override
  _AgendaMedicaState createState() => _AgendaMedicaState();
}

class _AgendaMedicaState extends State<AgendaMedica> {
  final TextEditingController _typeController = TextEditingController();
  List<String> _appointments = [];
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool isEdit = false;
  int? _editedIndex;

  @override
  void initState() {
    super.initState();
    _loadAppointments();
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'Lembrete de Consultas',
      body: Container(
        color: Colors.white, // Fundo branco
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectDate(context),
                    child: buttonDate(_selectedDate == null
                        ? 'Selecionar Data'
                        : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextButton(
                    onPressed: () => _selectTime(context),
                    child: buttonDate(_selectedTime == null
                        ? 'Selecionar Hora'
                        : _selectedTime!.format(context)),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            buildText('Especialidade'),
            buildTextField(
              controller: _typeController,
              keyboardType: TextInputType.text,
              hintText: 'Exemplo: Clínico Geral',
              length: 100,
              onChanged: (value) {},
            ),
            const SizedBox(height: 20),
            customElevatedButton(
              context: context,
              text: isEdit ? 'Salvar' : 'Adicionar',
              onPress: isEdit ? _saveAppointment : _addAppointment,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _appointments.isEmpty
                  ? const Center(child: Text('Nenhum lembrete cadastrado.'))
                  : ListView.builder(
                itemCount: _appointments.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: ColorsDefaults.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        _appointments[index],
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, color: Colors.black),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editAppointment(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => dialogDelete(
                              context: context,
                              index: index,
                              onPressed: () {
                                setState(() {
                                  _appointments.removeAt(index);
                                  _saveAppointments();
                                  SnackBarApp.success('Lembrete excluído!');
                                });
                                Navigator.of(context).pop();
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container buttonDate(String label) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: ColorsDefaults.background),
        borderRadius: BorderRadius.circular(20),
      ),
      alignment: Alignment.center,
      height: 44,
      child: buildText(label),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  void _addAppointment() {
    if (_selectedDate != null &&
        _selectedTime != null &&
        _typeController.text.isNotEmpty) {
      String date =
          '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
      String time = _selectedTime!.format(context);
      String type = _typeController.text.trim();

      setState(() {
        _appointments.add('$date $time - $type');
      });
      _clearFields();
      _saveAppointments();
      SnackBarApp.success('Lembrete salvo com sucesso!');
    } else {
      SnackBarApp.error('Por favor, preencha todos os campos!');
    }
  }

  void _editAppointment(int index) {
    String appointment = _appointments[index];

    List<String> parts = appointment.split(' - ');
    String dateTime = parts[0];
    String type = parts[1];

    List<String> dateTimeParts = dateTime.split(' ');
    String datePart = dateTimeParts[0];
    String timePart = dateTimeParts[1];

    List<String> dateParts = datePart.split('/');
    int day = int.parse(dateParts[0]);
    int month = int.parse(dateParts[1]);
    int year = int.parse(dateParts[2]);

    List<String> timeParts = timePart.split(':');
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);

    setState(() {
      isEdit = true;
      _editedIndex = index;
      _typeController.text = type;
      _selectedDate = DateTime(year, month, day);
      _selectedTime = TimeOfDay(hour: hour, minute: minute);
    });
  }

  void _saveAppointment() {
    if (_selectedDate != null &&
        _selectedTime != null &&
        _typeController.text.isNotEmpty) {
      String date =
          '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}';
      String time = _selectedTime!.format(context);
      String type = _typeController.text.trim();

      setState(() {
        _appointments[_editedIndex!] = '$date $time - $type';
        isEdit = false;
      });
      _clearFields();
      _saveAppointments();
      SnackBarApp.success('Lembrete editado com sucesso!');
    } else {
      SnackBarApp.error('Por favor, preencha todos os campos!');
    }
  }

  void _clearFields() {
    _typeController.clear();
    _selectedDate = null;
    _selectedTime = null;
    isEdit = false;
    _editedIndex = null;
  }

  void _saveAppointments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('appointments', _appointments);
  }

  void _loadAppointments() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _appointments = prefs.getStringList('appointments') ?? [];
    });
  }
}

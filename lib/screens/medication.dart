import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:health_truck/constants_colors.dart';
import 'package:health_truck/widget/button.dart';
import 'package:health_truck/widget/default_layout.dart';
import 'package:health_truck/widget/snack_bar.dart';
import 'package:health_truck/widget/textFormField.dart';
import 'package:health_truck/widget/text_labels.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
FlutterLocalNotificationsPlugin();

class MedicationReminderApp extends StatefulWidget {
  const MedicationReminderApp({super.key});

  @override
  _MedicationReminderAppState createState() => _MedicationReminderAppState();
}

class _MedicationReminderAppState extends State<MedicationReminderApp> {
  final TextEditingController _typeController = TextEditingController();
  final TextEditingController _intervalController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();

  List<String> _reminders = [];
  List<List<DateTime>> _schedules = [];
  bool isEdit = false;
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _loadReminders();
  }

  Future<void> _initializeNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
    InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  @override
  Widget build(BuildContext context) {
    return Layout(
      title: 'Lembrete de Medicamentos',
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildText('Nome do Remédio'),
            textForm(
              textInputAction: TextInputAction.next,
              controller: _typeController,
              maxLength: 20,
              textInputType: TextInputType.text,
              obscureText: false,
              hintText: 'Ex: Dipirona',
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildText('Intervalo (h)'),
                      textForm(
                        textInputAction: TextInputAction.next,
                        controller: _intervalController,
                        maxLength: 2,
                        textInputType: TextInputType.number,
                        obscureText: false,
                        hintText: 'Ex: 8',
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildText('Dias de uso'),
                      textForm(
                        textInputAction: TextInputAction.done,
                        controller: _daysController,
                        maxLength: 2,
                        textInputType: TextInputType.number,
                        obscureText: false,
                        hintText: 'Ex: 7',
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            customElevatedButton(
              context: context,
              text: isEdit ? 'Salvar' : 'Adicionar',
              onPress: _handleReminder,
            ),
            const SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                itemCount: _reminders.length,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: ColorsDefaults.background,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ListTile(
                      title: Text(
                        _reminders[index],
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editReminder(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _removeReminder(index),
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

  void _handleReminder() async {
    final String type = _typeController.text.trim();
    final int? interval = int.tryParse(_intervalController.text);
    final int? days = int.tryParse(_daysController.text);

    if (type.isEmpty || interval == null || days == null) {
      SnackBarApp.error("Preencha todos os campos corretamente!");
      return;
    }

    final schedule = _generateSchedule(interval, days);

    if (isEdit && editingIndex != null) {
      await _cancelNotifications(editingIndex!);
      await _scheduleNotifications(editingIndex!, type, schedule);
      setState(() {
        _reminders[editingIndex!] =
        'Remédio: $type | Intervalo: ${interval}h | Duração: ${days}d | ${schedule.length} notificações';
        _schedules[editingIndex!] = schedule;
        isEdit = false;
        editingIndex = null;
      });
    } else {
      final newIndex = _reminders.length;
      await _scheduleNotifications(newIndex, type, schedule);
      setState(() {
        _reminders.add(
            'Remédio: $type | Intervalo: ${interval}h | Duração: ${days}d | ${schedule.length} notificações');
        _schedules.add(schedule);
      });
    }

    _typeController.clear();
    _intervalController.clear();
    _daysController.clear();
    _saveReminders();
    SnackBarApp.success(
        "Lembrete ${isEdit ? 'atualizado' : 'adicionado'} com sucesso!");
  }

  List<DateTime> _generateSchedule(int interval, int days) {
    final now = DateTime.now();
    final totalHours = days * 24;
    final List<DateTime> schedule = [];

    for (int hour = 0; hour < totalHours; hour += interval) {
      schedule.add(now.add(Duration(hours: hour)));
    }
    return schedule;
  }

  Future<void> _scheduleNotifications(
      int idBase, String title, List<DateTime> schedule) async {
    for (int i = 0; i < schedule.length; i++) {
      await flutterLocalNotificationsPlugin.zonedSchedule(
        idBase * 100 + i,
        'Hora do medicamento',
        'Tomar: $title',
        tz.TZDateTime.from(schedule[i], tz.local),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'med_channel',
            'Lembretes de Medicamentos',
            importance: Importance.max,
            priority: Priority.high,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'lembrete_$idBase',
        // Removido os parâmetros problemáticos
      );
    }
  }

  Future<void> _cancelNotifications(int idBase) async {
    for (int i = 0; i < 100; i++) {
      await flutterLocalNotificationsPlugin.cancel(idBase * 100 + i);
    }
  }

  void _removeReminder(int index) async {
    await _cancelNotifications(index);
    setState(() {
      _reminders.removeAt(index);
      _schedules.removeAt(index);
    });
    _saveReminders();
    SnackBarApp.success("Lembrete removido!");
  }

  void _editReminder(int index) {
    final parts = _reminders[index].split('|');
    final String med = parts[0].split(':')[1].trim();
    final String interval = parts[1].replaceAll(RegExp(r'[^0-9]'), '');
    final String days = parts[2].replaceAll(RegExp(r'[^0-9]'), '');

    setState(() {
      isEdit = true;
      editingIndex = index;
      _typeController.text = med;
      _intervalController.text = interval;
      _daysController.text = days;
    });
  }

  void _saveReminders() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('reminders', _reminders);
  }

  void _loadReminders() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _reminders = prefs.getStringList('reminders') ?? [];
      _schedules = List.generate(_reminders.length, (_) => []);
    });
  }
}

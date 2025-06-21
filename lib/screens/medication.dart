import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class MedicationReminderApp extends StatefulWidget {
  const MedicationReminderApp({super.key});

  @override
  State<MedicationReminderApp> createState() => _MedicationReminderAppState();
}

class _MedicationReminderAppState extends State<MedicationReminderApp> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _intervalController = TextEditingController();
  final TextEditingController _daysController = TextEditingController();

  final List<Map<String, dynamic>> _medications = [];

  late FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;

  @override
  void initState() {
    super.initState();
    flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    _initializeNotifications();
  }

  void _initializeNotifications() {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(android: android);

    flutterLocalNotificationsPlugin.initialize(initializationSettings);
  }

  Future<void> _showNotification(String title, String body) async {
    const androidDetails = AndroidNotificationDetails(
      'medication_channel_id',
      'Lembrete de Medicamento',
      channelDescription: 'Notificações para lembrar dos medicamentos',
      importance: Importance.max,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await flutterLocalNotificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      notificationDetails,
    );
  }

  void _addMedication() {
    String name = _nameController.text.trim();
    String interval = _intervalController.text.trim();
    String days = _daysController.text.trim();

    if (name.isEmpty || interval.isEmpty || days.isEmpty) {
      _showSnackbar('Por favor, preencha todos os campos');
      return;
    }

    int? intervalHours = int.tryParse(interval);
    int? daysInt = int.tryParse(days);

    if (intervalHours == null || daysInt == null) {
      _showSnackbar('Intervalo e dias devem ser números válidos');
      return;
    }

    if (intervalHours <= 0 || daysInt <= 0) {
      _showSnackbar('Intervalo e dias devem ser maiores que zero');
      return;
    }

    setState(() {
      _medications.add({
        'name': name,
        'interval': intervalHours,
        'days': daysInt,
      });
    });

    _showSnackbar('Lembrete adicionado com sucesso!');
    _showNotification('Lembrete de Medicamento', 'Tomar $name');

    _nameController.clear();
    _intervalController.clear();
    _daysController.clear();
  }

  void _editMedication(int index) {
    final med = _medications[index];
    final TextEditingController nameController = TextEditingController(text: med['name']);
    final TextEditingController intervalController = TextEditingController(text: med['interval'].toString());
    final TextEditingController daysController = TextEditingController(text: med['days'].toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Medicamento'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: intervalController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Intervalo (h)'),
            ),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Dias de uso'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              String name = nameController.text.trim();
              int? interval = int.tryParse(intervalController.text.trim());
              int? days = int.tryParse(daysController.text.trim());

              if (name.isNotEmpty && interval != null && days != null) {
                setState(() {
                  _medications[index] = {
                    'name': name,
                    'interval': interval,
                    'days': days,
                  };
                });
                Navigator.pop(context);
                _showSnackbar('Medicamento atualizado');
              } else {
                _showSnackbar('Campos inválidos');
              }
            },
            child: const Text('Salvar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    );
  }

  void _deleteMedication(int index) {
    setState(() {
      _medications.removeAt(index);
    });
    _showSnackbar('Medicamento removido');
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      border: const OutlineInputBorder(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fundo branco
      appBar: AppBar(
        title: const Text('Lembrete de Medicamentos'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Nome do Remédio'),
            TextField(
              controller: _nameController,
              style: const TextStyle(color: Colors.black), // Texto preto
              decoration: _inputDecoration('Ex: Dipirona'),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      const Text('Intervalo (h)'),
                      TextField(
                        controller: _intervalController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.black),
                        decoration: _inputDecoration('Ex: 8'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    children: [
                      const Text('Dias de uso'),
                      TextField(
                        controller: _daysController,
                        keyboardType: TextInputType.number,
                        style: const TextStyle(color: Colors.black),
                        decoration: _inputDecoration('Ex: 7'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _addMedication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                ),
                child: const Text('Adicionar'),
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Lembretes cadastrados:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _medications.isEmpty
                  ? const Center(child: Text('Nenhum lembrete cadastrado.'))
                  : ListView.builder(
                itemCount: _medications.length,
                itemBuilder: (context, index) {
                  final med = _medications[index];
                  return Card(
                    child: ListTile(
                      title: Text(med['name']),
                      subtitle: Text(
                          'Intervalo: ${med['interval']}h - Dias: ${med['days']}'),
                      trailing: Wrap(
                        spacing: 12,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _editMedication(index),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteMedication(index),
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
}

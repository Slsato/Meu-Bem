import 'package:flutter/material.dart';
import 'package:health_truck/constants_colors.dart';
import 'package:health_truck/screens/agenda.dart';
import 'package:health_truck/screens/autoexame.dart';
import 'package:health_truck/screens/imc.dart';
import '../models/home_model.dart';
import 'medication.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = [
    IMCCalculator(),
    MedicationReminderApp(),
    AgendaMedica(),
    AutoexameScreen(), // nova tela
  ];

  final List<BottomNavItem> _bottomNavItems = [
    BottomNavItem(
      icon: Icons.calculate,
      label: 'IMC',
    ),
    BottomNavItem(
      icon: Icons.medication,
      label: 'Medicamentos',
    ),
    BottomNavItem(
      icon: Icons.calendar_today,
      label: 'Agenda',
    ),
    BottomNavItem(
      icon: Icons.favorite, // ícone sugestivo
      label: 'Autoexame',
    ),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorsDefaults.background,
      body: Center(
        child: _widgetOptions[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: _bottomNavItems.map((item) {
          return BottomNavigationBarItem(
            backgroundColor: Colors.white,
            icon: Icon(item.icon, color: ColorsDefaults.background),
            label: item.label,
          );
        }).toList(),
        backgroundColor: Colors.blueAccent,
        currentIndex: _selectedIndex,
        selectedItemColor: ColorsDefaults.background,
        unselectedItemColor: Colors.white,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}

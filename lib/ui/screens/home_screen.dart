// lib/ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'term_management_screen.dart';
import 'document_processing_screen.dart';
import 'report_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const TermManagementScreen(),
    const DocumentProcessingScreen(),
    const ReportScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.library_books),
                label: Text('Terim Yönetimi'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.edit),
                label: Text('Belge İşleme'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.assessment),
                label: Text('Raporlar'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}

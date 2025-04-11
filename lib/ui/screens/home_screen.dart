// lib/ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:chinese_english_term_corrector/generated/l10n/app_localizations.dart'; // Import localization
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
    final l10n = AppLocalizations.of(context)!; // Get localization instance

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
            destinations: [
              NavigationRailDestination(
                icon: const Icon(Icons.library_books),
                label: Text(l10n.termManagement), // Localized label
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.edit),
                label: Text(l10n.documentProcessing), // Localized label
              ),
              NavigationRailDestination(
                icon: const Icon(Icons.assessment),
                label: Text(l10n.reports), // Localized label
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

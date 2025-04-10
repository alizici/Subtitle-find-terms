import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';

import 'repositories/term_repository.dart';
import 'services/term_matcher.dart';
import 'services/correction_service.dart';
import 'ui/screens/home_screen.dart';
import 'ui/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isMacOS) {
    setWindowTitle('Çince-İngilizce Terim Düzeltici');
    setWindowMinSize(const Size(800, 600));
    setWindowMaxSize(Size.infinite);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TermRepository()),
        ProxyProvider<TermRepository, TermMatcher>(
          update: (_, termRepo, __) => TermMatcher(termRepo),
        ),
        ProxyProvider<TermMatcher, CorrectionService>(
          update: (_, termMatcher, __) => CorrectionService(termMatcher),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Çince-İngilizce Terim Düzeltici',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

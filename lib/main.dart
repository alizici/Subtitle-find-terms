import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:window_size/window_size.dart';
import 'dart:io';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:logging/logging.dart';

import 'repositories/term_repository.dart';
import 'repositories/project_repository.dart';
import 'services/term_matcher.dart';
import 'services/correction_service.dart';
import 'ui/screens/project_list_screen.dart';
import 'ui/theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Logger yapılandırması
  Logger.root.level = Level.INFO;
  Logger.root.onRecord.listen((record) {
    // ignore: avoid_print
    print('${record.level.name}: ${record.time}: ${record.message}');
  });

  if (Platform.isMacOS) {
    setWindowMinSize(const Size(800, 600));
    setWindowMaxSize(Size.infinite);
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TermRepository()),
        ChangeNotifierProvider(create: (_) => ProjectRepository()),
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
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('tr'), // Türkçe
        Locale('en'), // İngilizce
        Locale('zh'), // Çince
      ],
      locale: const Locale('en'), // Varsayılan dil olarak Türkçe
      home: const ProjectListScreen(),
      onGenerateTitle: (BuildContext context) {
        final appTitle = AppLocalizations.of(context)!.appTitle;
        if (Platform.isMacOS) {
          setWindowTitle(appTitle);
        }
        return appTitle;
      },
    );
  }
}

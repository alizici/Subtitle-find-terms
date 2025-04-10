// lib/utils/constants.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppConstants {
  // Dosya formatları
  static const List<String> supportedTextFormats = ['txt'];
  static const List<String> supportedTermFormats = ['json', 'csv'];
  static const List<String> supportedReportFormats = ['html', 'csv'];

  // Renk Paleti
  static const Color primaryColor = Color(0xFF2962FF);
  static const Color accentColor = Color(0xFF2979FF);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color successColor = Color(0xFF388E3C);
}

// Lokalizasyon gerektiren metinler için yardımcı sınıf
class LocalizedStrings {
  final BuildContext context;

  LocalizedStrings(this.context);

  AppLocalizations get _localizations => AppLocalizations.of(context)!;

  // Uygulama bilgileri
  String get appName => _localizations.appTitle;
  String get appVersion => '1.0.0'; // Versiyon sabit kalabilir

  // Varsayılan dosya adları
  String get defaultTermsFileName => _localizations.defaultTermsFileName;
  String get defaultReportFileName => _localizations.defaultReportFileName;

  // Hata mesajları
  String get errorFileLoad => _localizations.errorFileLoad;
  String get errorFileSave => _localizations.errorFileSave;
  String get errorTermImport => _localizations.errorTermImport;
  String get errorTermExport => _localizations.errorTermExport;

  // Başarı mesajları
  String get successTermImport => _localizations.successTermImport;
  String get successTermExport => _localizations.successTermExport;
  String get successFileLoad => _localizations.successFileLoad;
  String get successFileSave => _localizations.successFileSave;
  String get successCorrectionsApplied =>
      _localizations.successCorrectionsApplied;
}

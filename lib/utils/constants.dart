// lib/utils/constants.dart
import 'package:flutter/material.dart';

class AppConstants {
  // Uygulama bilgileri
  static const String appName = 'Çince-İngilizce Terim Düzeltici';
  static const String appVersion = '1.0.0';

  // Dosya formatları
  static const List<String> supportedTextFormats = ['txt'];
  static const List<String> supportedTermFormats = ['json', 'csv'];
  static const List<String> supportedReportFormats = ['html', 'csv'];

  // Varsayılan dosya adları
  static const String defaultTermsFileName = 'terimler.json';
  static const String defaultReportFileName = 'terim_raporu.html';

  // Hata mesajları
  static const String errorFileLoad = 'Dosya yüklenirken bir hata oluştu';
  static const String errorFileSave = 'Dosya kaydedilirken bir hata oluştu';
  static const String errorTermImport =
      'Terimler içe aktarılırken bir hata oluştu';
  static const String errorTermExport =
      'Terimler dışa aktarılırken bir hata oluştu';

  // Başarı mesajları
  static const String successTermImport = 'Terimler başarıyla içe aktarıldı';
  static const String successTermExport = 'Terimler başarıyla dışa aktarıldı';
  static const String successFileLoad = 'Dosya başarıyla yüklendi';
  static const String successFileSave = 'Dosya başarıyla kaydedildi';
  static const String successCorrectionsApplied =
      'Düzeltmeler başarıyla uygulandı';

  // Renk Paleti
  static const Color primaryColor = Color(0xFF2962FF);
  static const Color accentColor = Color(0xFF2979FF);
  static const Color errorColor = Color(0xFFD32F2F);
  static const Color warningColor = Color(0xFFFFA000);
  static const Color successColor = Color(0xFF388E3C);
}

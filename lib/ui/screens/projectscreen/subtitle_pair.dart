import 'dart:io';

// Altyazı çiftlerini saklamak için yardımcı sınıf
class SubtitlePair {
  final File chineseFile;
  final File englishFile;

  SubtitlePair({
    required this.chineseFile,
    required this.englishFile,
  });
}

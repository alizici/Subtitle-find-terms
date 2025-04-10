import 'dart:core'; // Duration için gerekli
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

// Lokalizasyon yardımcı sınıfı
class AssParserLocalizer {
  static String invalidTimeFormat(BuildContext context, String timestamp) {
    return AppLocalizations.of(context)!.invalidTimeFormat(timestamp);
  }

  static String invalidSecondsFormat(BuildContext context, String timestamp) {
    return AppLocalizations.of(context)!.invalidSecondsFormat(timestamp);
  }

  static String timestampParsingError(
      BuildContext context, String timestamp, String error) {
    return AppLocalizations.of(context)!
        .timestampParsingError(timestamp, error);
  }

  static String warningDialogueMissingFields(
      BuildContext context, String line) {
    return AppLocalizations.of(context)!.warningDialogueMissingFields(line);
  }

  static String dialogueParsingError(
      BuildContext context, String line, String format, String error) {
    return AppLocalizations.of(context)!
        .dialogueParsingError(line, format, error);
  }
}

// Zaman damgasını Duration nesnesine çeviren yardımcı fonksiyon
Duration _parseAssTimestamp(String timestamp, [BuildContext? context]) {
  try {
    final parts = timestamp.split(':');
    if (parts.length != 3) {
      final errorMsg = context != null
          ? AssParserLocalizer.invalidTimeFormat(context, timestamp)
          : "Invalid time format: $timestamp";
      throw FormatException(errorMsg);
    }

    final secondsParts = parts[2].split('.');
    if (secondsParts.length != 2) {
      final errorMsg = context != null
          ? AssParserLocalizer.invalidSecondsFormat(context, timestamp)
          : "Invalid seconds/centiseconds format: $timestamp";
      throw FormatException(errorMsg);
    }

    final hours = int.parse(parts[0]);
    final minutes = int.parse(parts[1]);
    final seconds = int.parse(secondsParts[0]);
    // .ass salise (centiseconds) kullanır (saniyenin 1/100'ü)
    final centiseconds = int.parse(secondsParts[1]);
    return Duration(
      hours: hours,
      minutes: minutes,
      seconds: seconds,
      milliseconds: centiseconds * 10, // Milisaniyeye çevir
    );
  } catch (e) {
    if (context != null) {
      print(AssParserLocalizer.timestampParsingError(
          context, timestamp, e.toString()));
    } else {
      print("Timestamp parsing error: '$timestamp' - $e");
    }
    // Hata durumunda varsayılan bir değer döndür veya hatayı yeniden fırlat
    return Duration.zero;
  }
}

// Bir altyazı olayını temsil eden sınıf
class AssEvent {
  final int layer;
  final Duration start;
  final Duration end;
  final String style;
  final String name;
  final int marginL;
  final int marginR;
  final int marginV;
  final String effect;
  final String text;

  AssEvent({
    required this.layer,
    required this.start,
    required this.end,
    required this.style,
    required this.name,
    required this.marginL,
    required this.marginR,
    required this.marginV,
    required this.effect,
    required this.text,
  });

  // Dialogue satırını ve format bilgisini alarak AssEvent nesnesi oluşturur
  factory AssEvent.fromLine(String line, List<String> format,
      [BuildContext? context]) {
    // Satırın 'Dialogue: ' kısmını atla
    final valuesString = line.substring(line.indexOf(':') + 1).trim();
    final values = <String>[];
    int currentPos = 0;
    int fieldsToSplit =
        format.length - 1; // Format'ın son elemanı 'Text' olduğu için

    // İlk 'fieldsToSplit' adet virgülü bulup ona göre ayır
    for (int i = 0; i < fieldsToSplit; i++) {
      final commaIndex = valuesString.indexOf(',', currentPos);
      if (commaIndex == -1) {
        // Yeterli virgül bulunamadı
        if (i == fieldsToSplit - 1) {
          // Eğer bu son beklenen alansa, kalan string'i ekle
          values.add(valuesString.substring(currentPos).trim());
        } else {
          // Eksik alanlar var, boş ekle ve uyar
          values.add('');
          if (context != null) {
            print(
                AssParserLocalizer.warningDialogueMissingFields(context, line));
          } else {
            print("Warning: Not enough fields in Dialogue line: $line");
          }
        }
        // Kalan beklenen alanları boş ile doldur
        while (values.length < fieldsToSplit) {
          values.add('');
        }
        break; // Virgül aramayı durdur
      }
      values.add(valuesString.substring(currentPos, commaIndex).trim());
      currentPos = commaIndex + 1;
    }

    // String'in geri kalanı Text alanıdır
    String textContent = '';
    // Eğer tüm ayırıcı virgüller bulunduysa ve string bitmediyse
    if (values.length == fieldsToSplit && currentPos < valuesString.length) {
      textContent = valuesString.substring(currentPos).trim();
    }
    // Eğer yeterli alan bulunamadıysa ama en az bir alan varsa, son eklenen alan metin olabilir (riskli)
    // else if (values.isNotEmpty && values.length < fieldsToSplit) {
    //   textContent = values.last; // Bu durum genellikle hatalı formata işaret eder
    // }

    final data = <String, String>{};
    for (int i = 0; i < fieldsToSplit; i++) {
      // Eğer ayrıştırma sırasında beklenenden az değer bulunduysa kontrol et
      if (i < values.length) {
        data[format[i]] = values[i]; // trim() daha önce yapıldı
      } else {
        data[format[i]] = ''; // Eksik değerler için boş string ata
      }
    }

    return AssEvent(
      layer: int.tryParse(data['Layer'] ?? '0') ?? 0,
      start: _parseAssTimestamp(data['Start'] ?? '0:00:00.00', context),
      end: _parseAssTimestamp(data['End'] ?? '0:00:00.00', context),
      style: data['Style'] ?? 'Default',
      name: data['Name'] ?? '',
      marginL: int.tryParse(data['MarginL'] ?? '0') ?? 0,
      marginR: int.tryParse(data['MarginR'] ?? '0') ?? 0,
      marginV: int.tryParse(data['MarginV'] ?? '0') ?? 0,
      effect: data['Effect'] ?? '',
      text: textContent,
    );
  }

  @override
  String toString() {
    return '[$start -> $end] Style: $style, Text: $text';
  }
}

// .ass dosya içeriğini ayrıştırıp AssEvent listesi döndüren fonksiyon
List<AssEvent> parseAssContent(String content, [BuildContext? context]) {
  final events = <AssEvent>[];
  final lines = content.split('\n'); // Satırları newline karakterine göre ayır
  bool inEventsSection = false;
  List<String> eventFormat = [];

  for (final rawLine in lines) {
    final line = rawLine.trim(); // Baştaki/sondaki boşlukları temizle

    if (line.isEmpty || line.startsWith(';')) {
      continue; // Boş satırları veya yorumları atla
    }

    if (line == '[Events]') {
      inEventsSection = true;
      eventFormat = []; // Bölüme girince formatı sıfırla
      continue;
    }

    // Başka bir bölüme girildiyse [Events] bölümünden çık
    if (line.startsWith('[') && line.endsWith(']')) {
      inEventsSection = false;
      continue;
    }

    if (inEventsSection) {
      if (line.startsWith('Format:')) {
        // Format satırını işle: "Format:" kısmını atla, boşlukları temizle, virgülle ayır
        eventFormat = line
            .substring('Format:'.length)
            .trim()
            .split(',')
            .map((e) => e.trim()) // Her format elemanındaki boşlukları temizle
            .toList();
      } else if (line.startsWith('Dialogue:') && eventFormat.isNotEmpty) {
        // Dialogue satırını işle (Format tanımlanmışsa)
        try {
          events.add(AssEvent.fromLine(line, eventFormat, context));
        } catch (e) {
          // Hata mesajındaki kaçış karakterlerini düzelt
          if (context != null) {
            print(AssParserLocalizer.dialogueParsingError(
                context, line, eventFormat.toString(), e.toString()));
          } else {
            print(
                "Could not parse Dialogue line: '$line'\nFormat: $eventFormat\nError: $e");
          }
          // Hatalı satırları atlayabilir veya farklı bir şekilde işleyebilirsiniz
        }
      }
      // İsterseniz 'Comment:' satırlarını da benzer şekilde işleyebilirsiniz
    }
    // Diğer bölümler ([Script Info], [V4+ Styles] vb.) burada işlenebilir
  }

  return events;
}

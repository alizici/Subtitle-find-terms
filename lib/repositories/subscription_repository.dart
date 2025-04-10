import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import '../models/user_subscription.dart';

class SubscriptionRepository extends ChangeNotifier {
  static const String _fileName = 'subscription.json';
  UserSubscription? _subscription;
  bool _isLoading = false;
  String? _error;

  UserSubscription get subscription => _subscription ?? UserSubscription();

  bool get isLoading => _isLoading;
  String? get error => _error;

  // Abonelik bilgilerini yükle
  Future<void> loadSubscription() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');

      if (await file.exists()) {
        final content = await file.readAsString();
        _subscription = UserSubscription.fromJson(jsonDecode(content));
      } else {
        // Dosya yoksa yeni bir abonelik oluştur
        _subscription = UserSubscription();
        await _saveSubscription();
      }
    } catch (e) {
      _error = 'Abonelik bilgileri yüklenirken hata oluştu: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Altyazı yükleme hakkı kullan
  Future<bool> useUpload() async {
    if (_subscription == null) {
      await loadSubscription();
    }

    final result = subscription.useUpload();
    if (result) {
      await _saveSubscription();
      notifyListeners();
    }

    return result;
  }

  // Abonelik yenile
  Future<void> resetUploads() async {
    subscription.resetUploads();
    await _saveSubscription();
    notifyListeners();
  }

  // Ekstra yükleme hakkı ekle
  Future<void> addUploads(int count) async {
    subscription.addUploads(count);
    await _saveSubscription();
    notifyListeners();
  }

  // Abonelik bilgilerini kaydet
  Future<void> _saveSubscription() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/$_fileName');

      final json = jsonEncode(subscription.toJson());
      await file.writeAsString(json);
    } catch (e) {
      _error = 'Abonelik bilgileri kaydedilirken hata oluştu: $e';
      notifyListeners();
    }
  }
}

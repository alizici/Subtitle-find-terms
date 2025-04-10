class UserSubscription {
  static const int maxSubtitleUploads = 5; // Maksimum 5 altyazı yükleme hakkı

  int _remainingUploads;
  DateTime _lastReset;

  UserSubscription({
    int? remainingUploads,
    DateTime? lastReset,
  })  : _remainingUploads = remainingUploads ?? maxSubtitleUploads,
        _lastReset = lastReset ?? DateTime.now();

  int get remainingUploads => _remainingUploads;
  DateTime get lastReset => _lastReset;
  bool get hasRemainingUploads => _remainingUploads > 0;

  // Altyazı yüklendi, kalan hakkı azalt
  bool useUpload() {
    if (_remainingUploads > 0) {
      _remainingUploads--;
      return true;
    }
    return false;
  }

  // Hakları sıfırla (örneğin ödeme yapıldığında)
  void resetUploads() {
    _remainingUploads = maxSubtitleUploads;
    _lastReset = DateTime.now();
  }

  // Kalan yükleme hakkını artır
  void addUploads(int count) {
    _remainingUploads += count;
  }

  // JSON serialization
  Map<String, dynamic> toJson() {
    return {
      'remainingUploads': _remainingUploads,
      'lastReset': _lastReset.toIso8601String(),
    };
  }

  factory UserSubscription.fromJson(Map<String, dynamic> json) {
    return UserSubscription(
      remainingUploads: json['remainingUploads'],
      lastReset:
          json['lastReset'] != null ? DateTime.parse(json['lastReset']) : null,
    );
  }
}

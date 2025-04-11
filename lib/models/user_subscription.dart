class UserSubscription {
  static const int maxSubtitleUploads = 5; // Maximum 5 subtitle upload rights

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

  // Use an upload right, decrement remaining uploads
  bool useUpload() {
    if (_remainingUploads > 0) {
      _remainingUploads--;
      return true;
    }
    return false;
  }

  // Reset rights (for example after payment)
  void resetUploads() {
    _remainingUploads = maxSubtitleUploads;
    _lastReset = DateTime.now();
  }

  // Increase remaining upload rights
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

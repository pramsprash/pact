import 'dart:async';
import 'package:flutter/foundation.dart';

class SessionTimer extends ChangeNotifier {
  static const int totalSeconds = 540; // 9 minutes

  int _remainingSeconds = totalSeconds;
  Timer? _timer;

  int get remainingSeconds => _remainingSeconds;
  bool get isComplete => _remainingSeconds <= 0;
  bool get isRunning => _timer != null && _timer!.isActive;

  String get formattedTime {
    final minutes = _remainingSeconds ~/ 60;
    final seconds = _remainingSeconds % 60;
    return '${minutes.toString()}:${seconds.toString().padLeft(2, '0')}';
  }

  void start() {
    _timer?.cancel();
    _remainingSeconds = totalSeconds;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds > 0) {
        _remainingSeconds--;
        notifyListeners();
      } else {
        _timer?.cancel();
        notifyListeners();
      }
    });
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

import 'package:flutter/foundation.dart';

class RCKDownloadProgressProvider with ChangeNotifier {
  final Map<String, ValueNotifier<double>> _progressMap = {};

  ValueNotifier<double> getProgress(String key) {
    if (!_progressMap.containsKey(key)) {
      _progressMap[key] = ValueNotifier<double>(0);
    }
    return _progressMap[key]!;
  }

  void updateProgress(String key, double progress) {
    getProgress(key).value = progress;
    notifyListeners();
  }

  void removeProgress(String key) {
    _progressMap.remove(key);
    notifyListeners();
  }

  void reset(String key) {
    getProgress(key).value = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    for (var notifier in _progressMap.values) {
      notifier.dispose();
    }
    _progressMap.clear();
    super.dispose();
  }
}

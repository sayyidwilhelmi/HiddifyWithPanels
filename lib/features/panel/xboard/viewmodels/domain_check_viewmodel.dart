// viewmodels/domain_check_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/http_service.dart';
import 'dart:async';

class DomainCheckViewModel extends ChangeNotifier {
  bool _isChecking = true;
  bool _isSuccess = false;
  int _retryCount = 0;
  int _dotsCount = 0;
  Timer? _timer;

  bool get isChecking => _isChecking;
  bool get isSuccess => _isSuccess;
  int get retryCount => _retryCount;
  String get progressIndicator => '检查中${'.' * _dotsCount}';

  DomainCheckViewModel() {
    checkDomain();
  }

  Future<void> checkDomain() async {
    _isChecking = true;
    _isSuccess = false;
    _retryCount++;
    _dotsCount = 0;
    notifyListeners();

    // 动态更新进度指示器中的点数
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      _dotsCount = (_dotsCount + 1) % 4; // 点数在0到3之间循环
      notifyListeners();
    });

    try {
      await HttpService.initialize();
      _isSuccess = true;
      _timer?.cancel(); // 成功后停止定时器
    } catch (_) {
      _isSuccess = false;
      _timer?.cancel(); // 失败后停止定时器
      Future.delayed(const Duration(seconds: 2), () {
        // 延迟两秒后重试
        checkDomain();
      });
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  void retry() {
    _retryCount = 0; // 重置重试计数
    checkDomain();
  }
}

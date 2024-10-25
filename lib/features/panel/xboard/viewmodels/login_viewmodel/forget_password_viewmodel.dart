// viewmodels/forget_password_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/auth_service.dart';

class ForgetPasswordViewModel extends ChangeNotifier {
  final AuthService _authService;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isCountingDown = false;
  bool get isCountingDown => _isCountingDown;

  int _countdownTime = 60;
  int get countdownTime => _countdownTime;

  bool _obscurePassword = true;
  bool get obscurePassword => _obscurePassword;

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController emailCodeController = TextEditingController();

  ForgetPasswordViewModel({required AuthService authService})
      : _authService = authService;

  Future<void> sendVerificationCode() async {
    final email = emailController.text.trim();
    _isCountingDown = true;
    _countdownTime = 60;
    notifyListeners();

    try {
      await _authService.sendVerificationCode(email);

      // 只有发送成功后才开始倒计时
      while (_countdownTime > 0) {
        await Future.delayed(const Duration(seconds: 1));
        _countdownTime--;
        notifyListeners();
      }
    } catch (e) {
      // 请求失败时，停止倒计时并允许重新发送
      _isCountingDown = false;
      _countdownTime = 60; // 重置倒计时时间
      notifyListeners();

      // 可以在这里记录错误或显示错误提示
      if (kDebugMode) {
        print("发送验证码失败: $e");
      }
    }

    // 请求成功或倒计时结束后，重置状态
    _isCountingDown = false;
    notifyListeners();
  }


  Future<void> resetPassword(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final emailCode = emailCodeController.text.trim();

    try {
      await _authService.resetPassword(email, password, emailCode);
      if (context.mounted) {
        context.go('/login');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void togglePasswordVisibility() {
    _obscurePassword = !_obscurePassword;
    notifyListeners();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    emailCodeController.dispose();
    super.dispose();
  }
}

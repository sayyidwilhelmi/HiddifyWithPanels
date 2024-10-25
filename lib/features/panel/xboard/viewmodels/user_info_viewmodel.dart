// viewmodels/user_info_viewmodel.dart
import 'package:flutter/foundation.dart';
import 'package:hiddify/features/panel/xboard/models/user_info_model.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/user_service.dart';
import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 创建 UserInfoViewModel
class UserInfoViewModel extends ChangeNotifier {
  final UserService _userService;

  UserInfo? _userInfo;
  UserInfo? get userInfo => _userInfo;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  UserInfoViewModel({required UserService userService})
      : _userService = userService;

  Future<void> fetchUserInfo() async {
    _isLoading = true;
    notifyListeners();
    print('开始获取用户信息...');

    try {
      final token = await getToken();
      if (token != null) {
        if (kDebugMode) {
          print('Token: $token');
        }
        _userInfo = await _userService.fetchUserInfo(token);
        if (kDebugMode) {
          print('用户信息已获取: $_userInfo');
        }
      } else {
        if (kDebugMode) {
          print('未找到Token');
        }
      }
    } catch (e) {
      _userInfo = null;
      if (kDebugMode) {
        print('获取用户信息失败: $e');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print('用户信息加载状态: $_isLoading');
      }
    }
  }
}

// 注册 ViewModel 提供器
final userInfoViewModelProvider = ChangeNotifierProvider((ref) {
  return UserInfoViewModel(userService: UserService());
});

// 提供一个访问用户信息的 FutureProvider，确保与 ViewModel 一致
final userInfoProvider = FutureProvider<UserInfo?>((ref) async {
  final userInfoViewModel = ref.read(userInfoViewModelProvider);
  await userInfoViewModel.fetchUserInfo();
  return userInfoViewModel.userInfo;
});

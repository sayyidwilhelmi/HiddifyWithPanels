import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

final authProvider = StateProvider<bool>((ref) {
  // 初始为未登录状态
  return false;
});
// 定义一个登出函数
Future<void> logout(BuildContext context, WidgetRef ref) async {
  // 清除存储的 token
  await deleteToken();
  // 更新 authProvider 状态为未登录
  ref.read(authProvider.notifier).state = false;
  // 跳转到登录页面
  if (context.mounted) {
    context.go('/');
  }
}

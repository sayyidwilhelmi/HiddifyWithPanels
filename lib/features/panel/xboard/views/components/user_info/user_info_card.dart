// views/user_info_card.dart
import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/models/user_info_model.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/user_service.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/user_info_viewmodel.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final userInfoViewModelProvider = ChangeNotifierProvider((ref) {
  return UserInfoViewModel(userService: UserService());
});

class UserInfoCard extends ConsumerStatefulWidget {
  const UserInfoCard({super.key});

  @override
  _UserInfoCardState createState() => _UserInfoCardState();
}

class _UserInfoCardState extends ConsumerState<UserInfoCard> {
  @override
  void initState() {
    super.initState();
    // 使用 Future 来确保不会在 widget 构建过程中修改状态
    Future(() {
      ref.read(userInfoViewModelProvider).fetchUserInfo();
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(userInfoViewModelProvider);
    final t = ref.watch(translationsProvider);

    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (viewModel.userInfo != null) {
      return _buildUserInfoCard(viewModel.userInfo!, t);
    } else {
      return const SizedBox(); // 如果没有数据，则返回空占位
    }
  }

  Widget _buildUserInfoCard(UserInfo userInfo, Translations t) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: NetworkImage(userInfo.avatarUrl),
        ),
        title: Text(userInfo.email),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${t.userInfo.plan}: ${userInfo.planId}',
                style: const TextStyle(fontSize: 12),
              ),
            ),
            Expanded(
              child: Text(
                '${t.userInfo.accountStatus}: ${userInfo.banned ? t.userInfo.banned : t.userInfo.active}',
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.end,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

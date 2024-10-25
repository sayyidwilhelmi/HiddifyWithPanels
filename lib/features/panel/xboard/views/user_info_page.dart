import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/services/future_provider.dart';
import 'package:hiddify/features/panel/xboard/views/components/user_info/account_balance_card.dart';
import 'package:hiddify/features/panel/xboard/views/components/user_info/invite_code_section.dart';
import 'package:hiddify/features/panel/xboard/views/components/user_info/reset_subscription_button.dart';
import 'package:hiddify/features/panel/xboard/views/components/user_info/user_info_card.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class UserInfoPage extends ConsumerStatefulWidget {
  const UserInfoPage({super.key});

  @override
  _UserInfoPageState createState() => _UserInfoPageState();
}

class _UserInfoPageState extends ConsumerState<UserInfoPage> {
  @override
  void initState() {
    super.initState();
    // 页面加载时自动刷新数据
    _refreshData();
  }

  void _refreshData() {
    // 刷新用户信息和邀请码列表
    // ignore: unused_result
    ref.refresh(userTokenInfoProvider);
    // ignore: unused_result
    ref.refresh(inviteCodesProvider);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.userInfo.pageTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData, // 手动刷新按钮
            tooltip: t.general.addToClipboard,
          ),
        ],
      ),
      body: FutureBuilder(
        // 等待所有需要的数据加载完毕再渲染视图
        future: Future.wait([
          ref.watch(userTokenInfoProvider.future),
          ref.watch(inviteCodesProvider.future),
        ]),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            // 显示加载指示器
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    t.general.addToClipboard,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // 显示错误信息
            return Center(
              child: Text(
                '${t.userInfo.fetchUserInfoError} ${snapshot.error}',
                style: const TextStyle(fontSize: 16, color: Colors.red),
              ),
            );
          }

          // 如果数据加载成功，显示整个视图
          return const SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                UserInfoCard(),
                SizedBox(height: 16),
                AccountBalanceCard(),
                SizedBox(height: 16),
                InviteCodeSection(),
                SizedBox(height: 16),
                ResetSubscriptionButton(),
              ],
            ),
          );
        },
      ),
    );
  }
}

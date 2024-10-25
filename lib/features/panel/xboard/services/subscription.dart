// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/subscription_service.dart';
import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart';
import 'package:hiddify/features/profile/data/profile_data_providers.dart';
import 'package:hiddify/features/profile/model/profile_entity.dart';
import 'package:hiddify/features/profile/notifier/active_profile_notifier.dart';
import 'package:hiddify/features/profile/notifier/profile_notifier.dart';
import 'package:hiddify/features/profile/overview/profiles_overview_notifier.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class Subscription {
  static final SubscriptionService _subscriptionService = SubscriptionService();
  // 公共方法：处理获取新订阅链接的逻辑
  static Future<void> _handleSubscription(BuildContext context, WidgetRef ref,
      Future<String?> Function(String) getSubscriptionLink) async {
    final t = ref.watch(translationsProvider);
    final accessToken = await getToken();
    if (accessToken == null) {
      _showSnackbar(context, t.userInfo.noAccessToken);
      return;
    }

    try {
      // 获取新的订阅链接
      final newSubscriptionLink = await getSubscriptionLink(accessToken);
      if (newSubscriptionLink != null) {
        // 删除旧的订阅配置
        final profileRepository =
            await ref.read(profileRepositoryProvider.future);
        final profilesResult = await profileRepository.watchAll().first;
        final profiles = profilesResult.getOrElse((_) => []);
        for (final profile in profiles) {
          if (profile is RemoteProfileEntity) {
            await ref
                .read(profilesOverviewNotifierProvider.notifier)
                .deleteProfile(profile);
          }
        }

        // 添加新的订阅链接
        await ref.read(addProfileProvider.notifier).add(newSubscriptionLink);

        // 获取新添加的配置文件并设置为活动配置文件
        final newProfilesResult = await profileRepository.watchAll().first;
        final newProfiles = newProfilesResult.getOrElse((_) => []);
        final newProfile = newProfiles.firstWhere(
          (profile) =>
              profile is RemoteProfileEntity &&
              profile.url == newSubscriptionLink,
          orElse: () {
            if (newProfiles.isNotEmpty) {
              return newProfiles[0];
            } else {
              throw Exception("No profiles available");
            }
          },
        );

        // 更新活跃配置文件状态
        // ignore: invalid_use_of_protected_member, invalid_use_of_visible_for_testing_member
        ref.read(activeProfileProvider.notifier).update((_) => newProfile);

        // 显示成功提示
        _showSnackbar(
          context,
          getSubscriptionLink == _subscriptionService.resetSubscriptionLink
              ? t.userInfo.subscriptionResetSuccess
              : t.userInfo.subscriptionUpdateSuccess,
        );
      }
    } catch (e) {
      _showSnackbar(context,
          "${getSubscriptionLink == _subscriptionService.resetSubscriptionLink ? t.userInfo.subscriptionResetError : t.userInfo.subscriptionUpdateError} $e");
    }
  }

  // 更新订阅的方法
  static Future<void> updateSubscription(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await _handleSubscription(
        context, ref, _subscriptionService.getSubscriptionLink);
  }

  // 重置订阅的方法
  static Future<void> resetSubscription(
    BuildContext context,
    WidgetRef ref,
  ) async {
    await _handleSubscription(
      context,
      ref,
      _subscriptionService.resetSubscriptionLink,
    );
  }

  // 显示提示信息
  static void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

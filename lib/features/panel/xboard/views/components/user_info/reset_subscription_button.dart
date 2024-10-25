import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/services/subscription.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

class ResetSubscriptionButton extends ConsumerWidget {
  const ResetSubscriptionButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return Center(
      child: ElevatedButton.icon(
        onPressed: () => Subscription.resetSubscription(context, ref),
        icon: const Icon(Icons.refresh),
        label: Text(t.userInfo.resetSubscription),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          backgroundColor: Colors.blue,
        ),
      ),
    );
  }
}

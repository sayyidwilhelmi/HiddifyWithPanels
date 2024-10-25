// views/domain_check_indicator.dart
import 'package:flutter/material.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/domain_check_viewmodel.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hiddify/core/localization/translations.dart'; // 引入本地化提供者

final domainCheckViewModelProvider = ChangeNotifierProvider((ref) {
  return DomainCheckViewModel();
});

class DomainCheckIndicator extends ConsumerWidget {
  const DomainCheckIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider); // 引入本地化文件
    final domainCheckViewModel = ref.watch(domainCheckViewModelProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (domainCheckViewModel.isChecking)
          Row(
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(),
              ),
              const SizedBox(width: 4),
              Text(domainCheckViewModel.progressIndicator),
              const SizedBox(width: 8),
              Text(
                  '${t.domain.retryAttempts}: ${domainCheckViewModel.retryCount}'),
            ],
          )
        else if (domainCheckViewModel.isSuccess)
          Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green),
              const SizedBox(width: 8),
              Text(t.domain.checkPassed),
            ],
          )
        else
          Row(
            children: [
              const Icon(Icons.error, color: Colors.red),
              const SizedBox(width: 8),
              Text(
                  '${t.domain.connectionFailed} (${t.domain.retryAttempts}: ${domainCheckViewModel.retryCount})'),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  domainCheckViewModel.retry();
                },
              ),
            ],
          ),
      ],
    );
  }
}

// viewmodels/reset_subscription_viewmodel.dart
import 'package:flutter/material.dart';
import 'package:hiddify/features/panel/xboard/services/subscription.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

class ResetSubscriptionViewModel extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;
  ResetSubscriptionViewModel();

  Future<void> resetSubscription(BuildContext context, WidgetRef ref) async {
    _isLoading = true;
    notifyListeners();

    try {
      await Subscription.resetSubscription(context, ref);
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subscription reset successfully')),
      );
    } catch (e) {
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error resetting subscription: $e')),
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

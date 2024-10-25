// views/account_balance_card.dart
// ignore_for_file: use_build_context_synchronously

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/models/user_info_model.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/balance.service.dart';
import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/user_info_viewmodel.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class AccountBalanceCard extends ConsumerWidget {
  const AccountBalanceCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);
    final userInfoAsync = ref.watch(userInfoProvider);

    return userInfoAsync.when(
      data: (userInfo) {
        if (userInfo == null) {
          return Center(child: Text(t.userInfo.noData));
        }
        return _buildAccountBalanceCard(userInfo, t, context, ref);
      },
      loading: () {
        return const Center(child: CircularProgressIndicator());
      },
      error: (error, _) {
        return Center(
          child: Text('${t.userInfo.fetchUserInfoError} $error'),
        );
      },
    );
  }

  Widget _buildAccountBalanceCard(
    UserInfo userInfo,
    Translations t,
    BuildContext context,
    WidgetRef ref,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Column(
        children: [
          Container(
            height: 96,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListTile(
              leading: const Icon(FluentIcons.wallet_24_filled),
              title: Text(
                  '${t.userInfo.balance} (${t.userInfo.onlyForConsumption})',),
              subtitle: Text(
                  '${(userInfo.balance / 100).toStringAsFixed(2)} ${t.userInfo.currency}',),
            ),
          ),
          const Divider(height: 1),
          Container(
            height: 96,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: ListTile(
              leading: const Icon(FluentIcons.gift_card_money_24_filled),
              title: Text(t.userInfo.commissionBalance),
              subtitle: Text(
                  '${(userInfo.commissionBalance / 100).toStringAsFixed(2)} ${t.userInfo.currency}',),
            ),
          ),
          Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton(
                  onPressed: () => _showTransferDialog(context, ref, userInfo),
                  child: Text(t.transferDialog.transfer),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _showWithdrawDialog(
                      context, ref, userInfo.commissionBalance,),
                  child: Text(t.transferDialog.withdraw),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showTransferDialog(
      BuildContext context, WidgetRef ref, UserInfo userInfo,) {
    final t = ref.read(translationsProvider);
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(t.transferDialog.transferTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.transferDialog.transferHint),
              const SizedBox(height: 8),
              Text(
                '${t.transferDialog.currentBalance}: ${(userInfo.commissionBalance / 100).toStringAsFixed(2)} ${t.userInfo.currency}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration:
                    InputDecoration(labelText: t.transferDialog.transferAmount),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(t.ensure.cancel),
            ),
            ElevatedButton(
              onPressed: () async {
                final inputAmount = int.tryParse(amountController.text) ?? 0;
                if (inputAmount > 0) {
                  await _transferCommission(context, ref, inputAmount * 100);
                }
                Navigator.of(context).pop();
              },
              child: Text(t.ensure.confirm),
            ),
          ],
        );
      },
    );
  }

  Future<void> _transferCommission(
    BuildContext context,
    WidgetRef ref,
    int transferAmount,
  ) async {
    final t = ref.read(translationsProvider);
    final token = await getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t.userInfo.noAccessToken)),
      );
      return;
    }

    try {
      final success =
          await BalanceService().transferCommission(token, transferAmount);
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.transferDialog.transferSuccess)),
        );
        // ignore: unused_result
        ref.refresh(userInfoProvider); // 刷新用户信息
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.transferDialog.transferError)),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${t.transferDialog.transferError}: $e")),
      );
    }
  }

  void _showWithdrawDialog(
      BuildContext context, WidgetRef ref, double commissionBalance,) {
    final t = ref.watch(translationsProvider);
    final amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(t.transferDialog.withdrawTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(t.transferDialog.withdrawHint),
              const SizedBox(height: 16),
              Text(
                '${t.transferDialog.currentBalance}: ${(commissionBalance / 100).toStringAsFixed(2)} ${t.userInfo.currency}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: t.transferDialog.withdrawAmount,
                  border: const OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(t.ensure.cancel),
            ),
            TextButton(
              onPressed: () async {
                final inputAmount = int.tryParse(amountController.text);
                if (inputAmount != null && inputAmount > 0) {
                  final transferAmount = inputAmount * 100;
                  await _transferCommission(context, ref, transferAmount);
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(t.transferDialog.withdrawError)),
                  );
                }
                Navigator.of(context).pop();
              },
              child: Text(t.ensure.confirm),
            ),
          ],
        );
      },
    );
  }
}

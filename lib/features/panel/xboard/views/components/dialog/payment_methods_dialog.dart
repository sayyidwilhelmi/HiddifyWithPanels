// payment_methods_dialog.dart

import 'package:flutter/material.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/services/subscription.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/dialog_viewmodel/payment_methods_viewmodel.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/dialog_viewmodel/payment_methods_viewmodel_provider.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';
// 导入 ViewModel Provider

class PaymentMethodsDialog extends ConsumerStatefulWidget {
  final String tradeNo;
  final List<dynamic> paymentMethods;
  final double totalAmount;
  final Translations t;
  final WidgetRef ref;

  const PaymentMethodsDialog({
    super.key,
    required this.tradeNo,
    required this.paymentMethods,
    required this.totalAmount,
    required this.t,
    required this.ref,
  });

  @override
  _PaymentMethodsDialogState createState() => _PaymentMethodsDialogState();
}

class _PaymentMethodsDialogState extends ConsumerState<PaymentMethodsDialog> {
  late final PaymentMethodsViewModelParams _params;
  late final AutoDisposeChangeNotifierProvider<PaymentMethodsViewModel>
      _provider;

  @override
  void initState() {
    super.initState();

    _params = PaymentMethodsViewModelParams(
      tradeNo: widget.tradeNo,
      totalAmount: widget.totalAmount,
      onPaymentSuccess: () {
            final t = ref.watch(translationsProvider); // 引入本地化文件
        // 支付成功回调
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(t.purchase.orderSuccess)),
        );
        Subscription.updateSubscription(context, widget.ref);
        Navigator.of(context).pop(); // 关闭支付方式弹窗
        Navigator.of(context).pop(); // 关闭购买详情弹窗
      },
    );

    _provider = paymentMethodsViewModelProvider(_params);
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = ref.watch(_provider);
    final t = ref.watch(translationsProvider); // 引入本地化文件
    return AlertDialog(
      title: Text(t.purchase.orderSuccess),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '${t.purchase.total} : ${widget.totalAmount.toStringAsFixed(2)} ${widget.t.purchase.rmb}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...widget.paymentMethods.map((method) {
              final Map<String, dynamic> paymentMethod =
                  method as Map<String, dynamic>;

              final feePercent = paymentMethod['handling_fee_percent'] != null
                  ? double.tryParse(
                        paymentMethod['handling_fee_percent'].toString(),
                      ) ??
                      0.0
                  : 0.0;
              final handlingFee = widget.totalAmount * feePercent / 100;
              final totalPrice = widget.totalAmount + handlingFee;

              return ListTile(
                title: Text(
                    paymentMethod['name']?.toString() ?? t.purchase.unknown,),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${t.purchase.fee}: ${feePercent.toStringAsFixed(2)}%'),
                    Text(
                      '${t.purchase.total}: ${totalPrice.toStringAsFixed(2)} ${widget.t.purchase.rmb}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '(${widget.totalAmount.toStringAsFixed(2)} ${widget.t.purchase.rmb} + '
                      '${handlingFee.toStringAsFixed(2)} ${widget.t.purchase.rmb} ${t.purchase.fee})',
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.of(context).pop(); // 关闭支付方式弹窗
                  viewModel.handlePayment(paymentMethod);
                },
              );
            }),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // 关闭支付方式弹窗
          },
          child: Text(t.purchase.close),
        ),
      ],
    );
  }
}

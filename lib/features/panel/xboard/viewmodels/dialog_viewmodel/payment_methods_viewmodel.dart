// payment_methods_view_model.dart

// ignore_for_file: avoid_dynamic_calls

import 'package:flutter/foundation.dart';
import 'package:hiddify/features/panel/xboard/services/monitor_pay_status.dart';
import 'package:hiddify/features/panel/xboard/services/purchase_service.dart';
import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart';
import 'package:url_launcher/url_launcher.dart';

class PaymentMethodsViewModel extends ChangeNotifier {
  final String tradeNo;
  final double totalAmount;
  final VoidCallback onPaymentSuccess;
  final PurchaseService _purchaseService = PurchaseService();

  PaymentMethodsViewModel({
    required this.tradeNo,
    required this.totalAmount,
    required this.onPaymentSuccess,
  });

  Future<void> handlePayment(dynamic selectedMethod) async {
    final accessToken = await getToken(); // 获取用户的token
    try {
      // 调用 submitOrder 并获取完整的响应字典
      final response = await _purchaseService.submitOrder(
        tradeNo,
        selectedMethod['id'].toString(),
        accessToken!,
      );

      if (kDebugMode) {
        print('支付响应: $response');
      }

      // 获取 type 和 data 字段
      final type = response['type'];
      final data = response['data'];

      // 确保 type 是 int 并且 data 是期望的类型
      if (type is int) {
        // 如果 type 为 -1 且 data 为 true，表示订单已通过钱包余额支付成功
        if (type == -1 && data == true) {
          if (kDebugMode) {
            print('订单已通过钱包余额支付成功，无需跳转支付页面');
          }
          handlePaymentSuccess(); // 直接处理支付成功
          return;
        }

        // 如果 type 为 1 且 data 是 String 类型，认为它是支付链接
        if (type == 1 && data is String) {
          openPaymentUrl(data); // 打开支付链接
          monitorOrderStatus(); // 开始监听订单状态
          return;
        }
      }

      // 处理其他未知情况
      if (kDebugMode) {
        print('支付处理失败: 意外的响应。');
      }
    } catch (e) {
      if (kDebugMode) {
        print('支付错误: $e');
      }
    }
  }

  void handlePaymentSuccess() {
    if (kDebugMode) {
      print('订单已标记为已支付。');
    }
    onPaymentSuccess();
  }

  Future<void> monitorOrderStatus() async {
    final accessToken = await getToken();
    if (accessToken == null) return;

    MonitorPayStatus().monitorOrderStatus(tradeNo, accessToken, (bool isPaid) {
      if (isPaid) {
        if (kDebugMode) {
          print('订单支付成功');
        }
        handlePaymentSuccess();
      } else {
        if (kDebugMode) {
          print('订单未支付');
        }
      }
    });
  }

  void openPaymentUrl(String paymentUrl) {
    final Uri url = Uri.parse(paymentUrl);
    launchUrl(url);
  }
}

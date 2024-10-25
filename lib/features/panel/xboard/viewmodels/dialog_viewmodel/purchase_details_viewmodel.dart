// purchase_details_view_model.dart

import 'package:flutter/foundation.dart';
import 'package:hiddify/features/panel/xboard/models/order_model.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/order_service.dart';
import 'package:hiddify/features/panel/xboard/services/purchase_service.dart';
import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart';

class PurchaseDetailsViewModel extends ChangeNotifier {
  final int planId;
  String? selectedPeriod;
  double? selectedPrice;
  String? tradeNo;

  final PurchaseService _purchaseService = PurchaseService();
  final OrderService _orderService = OrderService();

  PurchaseDetailsViewModel({
    required this.planId,
    this.selectedPeriod,
    this.selectedPrice,
  });

  void setSelectedPrice(double? price, String? period) {
    selectedPrice = price;
    selectedPeriod = period;
    notifyListeners();
  }

  Future<List<dynamic>> handleSubscribe() async {
    final accessToken = await getToken();
    if (accessToken == null) {
      print("Access token is null");
      return [];
    }

    try {
      // 检查未支付的订单
      final List<Order> orders =
          await _orderService.fetchUserOrders(accessToken);
      for (final order in orders) {
        if (order.status == 0) {
          // 如果订单未支付
          await _orderService.cancelOrder(order.tradeNo!, accessToken);
          print('未支付订单 ${order.tradeNo} 已取消');
        }
      }

      // 创建新订单
      final orderResponse = await _purchaseService.createOrder(
        planId,
        selectedPeriod!,
        accessToken,
      );

      if (orderResponse != null && orderResponse['status'] == 'success') {
        tradeNo = orderResponse['data']?.toString();
        if (kDebugMode) {
          print("订单创建成功 订单号$tradeNo");
        }
        final paymentMethods =
            await _purchaseService.getPaymentMethods(accessToken);
        return paymentMethods;
      } else {
        if (kDebugMode) {
          print('订单创建失败: ${orderResponse?['message']}');
        }
        return [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('错误: $e');
      }
      return [];
    }
  }
}

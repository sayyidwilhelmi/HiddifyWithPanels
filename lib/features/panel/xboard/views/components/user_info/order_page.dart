// ignore_for_file: use_build_context_synchronously

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 用于复制到剪贴板
import 'package:hiddify/core/localization/translations.dart'; // 本地化提供者
import 'package:hiddify/features/panel/xboard/models/order_model.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/order_service.dart';
import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart'; // 用于格式化日期

class OrderPage extends ConsumerStatefulWidget {
  const OrderPage({super.key});

  @override
  _OrderPageState createState() => _OrderPageState();
}

class _OrderPageState extends ConsumerState<OrderPage> {
  late Future<List<Order>> _ordersFuture; // 初始化 late 变量

  @override
  void initState() {
    super.initState();
    _ordersFuture = _fetchUserOrders(); // 在 initState 中初始化 _ordersFuture
  }

  Future<void> _refreshOrders() async {
    setState(() {
      _ordersFuture = _fetchUserOrders(); // 刷新订单数据
    });
  }

  Future<List<Order>> _fetchUserOrders() async {
    final accessToken = await getToken();
    if (accessToken == null) {
      throw Exception("No access token found.");
    }
    return await OrderService().fetchUserOrders(accessToken);
  }

  String _getOrderStatusText(int? status, Translations t) {
    switch (status) {
      case 0:
        return t.order.statuses.unpaid;
      case 3:
        return t.order.statuses.paid;
      case 2:
        return t.order.statuses.cancelled;
      default:
        return t.order.statuses.unknown;
    }
  }

  // 将Unix时间戳转换为可读的日期格式
  String _formatTimestamp(int? timestamp, Translations t) {
    if (timestamp == null) {
      return t.order.statuses.unknown;
    }
    final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    final t = ref.watch(translationsProvider); // 获取本地化内容
    return Scaffold(
      appBar: AppBar(
        title: Text(t.order.title),
      ),
      body: RefreshIndicator(
        onRefresh: _refreshOrders, // 下拉刷新调用刷新方法
        child: FutureBuilder<List<Order>>(
          future: _ordersFuture, // 使用已初始化的 _ordersFuture
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('error: ${snapshot.error}'));
            } else if (snapshot.hasData && snapshot.data != null) {
              final orders = snapshot.data!;
              if (orders.isEmpty) {
                return Center(child: Text(t.order.noOrders));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: orders.length,
                itemBuilder: (context, index) {
                  final order = orders[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 订单号，长按复制订单号
                          GestureDetector(
                            onLongPress: () {
                              Clipboard.setData(
                                ClipboardData(
                                  text:
                                      order.tradeNo ?? t.order.statuses.unknown,
                                ),
                              );
                              _showSnackbar(context, t.order.orderNumberCopied);
                            },
                            child: Text(
                              '${t.order.orderDetails.orderNumber}: ${order.tradeNo ?? t.order.statuses.unknown}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 金额
                          Text(
                            '${t.order.orderDetails.amount}: ¥${order.totalAmount != null ? (order.totalAmount! / 100).toStringAsFixed(2) : t.order.statuses.unknown}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 支付周期
                          Text(
                            '${t.order.orderDetails.paymentCycle}: ${order.period ?? t.order.statuses.unknown}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 订单状态
                          Text(
                            '${t.order.orderDetails.orderStatus}: ${_getOrderStatusText(order.status, t)}',
                            style: TextStyle(
                              fontSize: 14,
                              color: _getStatusColor(order.status),
                            ),
                          ),
                          const SizedBox(height: 8),

                          // 订单创建时间
                          Text(
                            '${t.order.orderDetails.orderTime}: ${_formatTimestamp(order.createdAt, t)}',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          if (order.status == 0) const Divider(height: 24),

                          // 只有未支付状态时显示支付和取消按钮
                          if (order.status == 0)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    // 处理支付逻辑
                                    _handlePayment(order);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue, // 支付按钮颜色
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(t.order.actions.pay),
                                ),
                                const SizedBox(width: 8),
                                ElevatedButton(
                                  onPressed: () {
                                    // 处理取消订单逻辑
                                    _handleCancel(order);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red, // 取消按钮颜色
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Text(t.order.actions.cancel),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  );
                },
              );
            } else {
              return Center(child: Text(t.order.noOrders));
            }
          },
        ),
      ),
    );
  }

  // 根据订单状态设置不同颜色
  Color _getStatusColor(int? status) {
    switch (status) {
      case 0:
        return Colors.orange;
      case 3:
        return Colors.green;
      case 2:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  // 支付逻辑处理函数
  void _handlePayment(Order order) {
    if (kDebugMode) {
      print('Processing payment for order: ${order.tradeNo}');
    }
    // 支付处理逻辑
  }

  // 取消订单逻辑处理函数
  Future<void> _handleCancel(Order order) async {
    if (kDebugMode) {
      print('Cancelling order: ${order.tradeNo}');
    }
    final authService = OrderService();
    final tradeNo = order.tradeNo;
    final accessToken = await getToken();

    try {
      final result = await authService.cancelOrder(tradeNo!, accessToken!);
      if (result['status'] == 'success') {
        _showSnackbar(
          context,
          ref.watch(translationsProvider).order.messages.orderCancelSuccess,
        );
        await _refreshOrders();
      } else {
        _showSnackbar(
          context,
          ref.watch(translationsProvider).order.messages.orderCancelFailed,
        );
      }
    } catch (e) {
      _showSnackbar(
        context,
        "${ref.watch(translationsProvider).order.messages.orderCancelFailed}: $e",
      );
    }
  }

  // 显示提示信息
  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

class Order {
  final int? planId;
  final String? tradeNo;
  final double? totalAmount;
  final String? period;
  final int? status;
  final int? createdAt; // 新增的创建时间字段
  final OrderPlan? orderPlan;

  Order({
    this.planId,
    this.tradeNo,
    this.totalAmount,
    this.period,
    this.status,
    this.createdAt, // 初始化创建时间字段
    this.orderPlan,
  });

factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      planId: json['plan_id'] as int?,
      tradeNo: json['trade_no'] as String?,
      totalAmount: (json['total_amount'] as num?)?.toDouble(),
      period: json['period'] as String?,
      status: json['status'] as int?,
      createdAt: json['created_at'] as int?,
      orderPlan: json['plan'] != null
          ? OrderPlan.fromJson(json['plan'] as Map<String, dynamic>)
          : null,
    );
  }
}
class OrderPlan {
  final int id;
  final String name;
  final double? onetimePrice;
  final String? content;

  OrderPlan({
    required this.id,
    required this.name,
    this.onetimePrice,
    this.content,
  });

  factory OrderPlan.fromJson(Map<String, dynamic> json) {
    return OrderPlan(
      id: json['id'] as int,
      name: json['name'] as String,
      onetimePrice: (json['onetime_price'] as num?)?.toDouble(),
      content: json['content'] as String?,
    );
  }
}

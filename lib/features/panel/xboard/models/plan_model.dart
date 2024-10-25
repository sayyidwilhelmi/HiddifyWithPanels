import 'package:html/parser.dart' as html_parser;

class Plan {
  final int id;
  final int groupId;
  final double transferEnable;
  final String name;
  final int speedLimit;
  final bool show;
  String? content;
  final double? onetimePrice;
  final double? monthPrice;
  final double? quarterPrice;
  final double? halfYearPrice;
  final double? yearPrice;
  final double? twoYearPrice;
  final double? threeYearPrice;
  final int? createdAt;
  final int? updatedAt;

  Plan({
    required this.id,
    required this.groupId,
    required this.transferEnable,
    required this.name,
    required this.speedLimit,
    required this.show,
    this.content,
    this.onetimePrice,
    this.monthPrice,
    this.quarterPrice,
    this.halfYearPrice,
    this.yearPrice,
    this.twoYearPrice,
    this.threeYearPrice,
    this.createdAt,
    this.updatedAt,
  });

  factory Plan.fromJson(Map<String, dynamic> json) {
    // 清理 HTML 标签
    final rawContent = json['content'] ?? '';
    final document = html_parser.parse(rawContent);
    final cleanContent = document.body?.text ?? '';

    return Plan(
      id: json['id'] is int ? json['id'] as int : 0,
      groupId: json['group_id'] is int ? json['group_id'] as int : 0,
      transferEnable: json['transfer_enable'] is num
          ? (json['transfer_enable'] as num).toDouble()
          : 0.0,
      name: json['name'] is String ? json['name'] as String : '未知',
      speedLimit: json['speed_limit'] is int ? json['speed_limit'] as int : 0,
      show: json['show'] == 1, // 布尔类型处理

      // 清理后的内容
      content: cleanContent.isNotEmpty ? cleanContent : null,

      // 处理价格字段
      onetimePrice: json['onetime_price'] != null
          ? (json['onetime_price']! as num).toDouble() / 100
          : null,
      monthPrice: json['month_price'] != null
          ? (json['month_price']! as num).toDouble() / 100
          : null,
      quarterPrice: json['quarter_price'] != null
          ? (json['quarter_price']! as num).toDouble() / 100
          : null,
      halfYearPrice: json['half_year_price'] != null
          ? (json['half_year_price']! as num).toDouble() / 100
          : null,
      yearPrice: json['year_price'] != null
          ? (json['year_price']! as num).toDouble() / 100
          : null,
      twoYearPrice: json['two_year_price'] != null
          ? (json['two_year_price']! as num).toDouble() / 100
          : null,
      threeYearPrice: json['three_year_price'] != null
          ? (json['three_year_price']! as num).toDouble() / 100
          : null,

      // 处理创建时间和更新时间字段
      createdAt: json['created_at'] is int ? json['created_at'] as int : null,
      updatedAt: json['updated_at'] is int ? json['updated_at'] as int : null,
    );
  }
}

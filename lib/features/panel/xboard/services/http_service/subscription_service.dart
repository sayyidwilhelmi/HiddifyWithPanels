// services/subscription_service.dart
import 'package:hiddify/features/panel/xboard/services/http_service/http_service.dart';

class SubscriptionService {
  final HttpService _httpService = HttpService();

  // 获取订阅链接的方法
  Future<String?> getSubscriptionLink(String accessToken) async {
    final result = await _httpService.getRequest(
      "/api/v1/user/getSubscribe",
      headers: {
        'Authorization': accessToken,
      },
    );

    if (result.containsKey("data")) {
      final data = result["data"];
      if (data is Map<String, dynamic> && data.containsKey("subscribe_url")) {
        return data["subscribe_url"] as String?;
      }
    }

    // 返回 null 或抛出异常，如果数据结构不匹配
    throw Exception("Failed to retrieve subscription link");
  }

  // 重置订阅链接的方法
  Future<String?> resetSubscriptionLink(String accessToken) async {
    final result = await _httpService.getRequest(
      "/api/v1/user/resetSecurity",
      headers: {
        'Authorization': accessToken,
      },
    );
    if (result.containsKey("data")) {
      final data = result["data"];
      if (data is String) {
        return data; // 如果 'data' 是字符串，直接返回
      }
    }
    throw Exception("Failed to reset subscription link");
  }
}

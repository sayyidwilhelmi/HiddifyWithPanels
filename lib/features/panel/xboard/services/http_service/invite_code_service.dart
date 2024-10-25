// services/invite_service.dart
import 'package:hiddify/features/panel/xboard/models/invite_code_model.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/http_service.dart';

class InviteCodeService {
  final HttpService _httpService = HttpService();

  // 生成邀请码的方法
  Future<bool> generateInviteCode(String accessToken) async {
    await _httpService.getRequest(
      "/api/v1/user/invite/save",
      headers: {'Authorization': accessToken},
    );
    return true; // 如果没有抛出异常，则表示成功生成邀请码
  }

  // 获取邀请码数据的方法
  Future<List<InviteCode>> fetchInviteCodes(String accessToken) async {
    final result = await _httpService.getRequest(
      "/api/v1/user/invite/fetch",
      headers: {'Authorization': accessToken},
    );

    if (result.containsKey("data") && result["data"] is Map<String, dynamic>) {
      final data = result["data"];
      // ignore: avoid_dynamic_calls
      final codes = data["codes"] as List;
      return codes
          .cast<Map<String, dynamic>>()
          .map((json) => InviteCode.fromJson(json))
          .toList();
    } else {
      throw Exception("Failed to retrieve invite codes");
    }
  }

  // 获取完整邀请码链接的方法
  String getInviteLink(String code) {
    final inviteLinkBase = "${HttpService.baseUrl}/#/register?code=";
    if (HttpService.baseUrl.isEmpty) {
      throw Exception('Base URL is not set.');
    }
    return '$inviteLinkBase$code';
  }
}

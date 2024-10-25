
import 'package:hiddify/features/panel/xboard/services/http_service/http_service.dart';

class BalanceService {
  final HttpService _httpService = HttpService();
// 划转佣金到余额的方法
  Future<bool> transferCommission(
    String accessToken,
    int transferAmount,
  ) async {
    await _httpService.postRequest(
      '/api/v1/user/transfer',
      {'transfer_amount': transferAmount},
      headers: {'Authorization': accessToken}, // 需要用户的认证令牌
    );
    return true;
  }
}

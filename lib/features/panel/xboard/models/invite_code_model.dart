class InviteCode {
  final String code;

  InviteCode({
    required this.code,
  });

  // 从 JSON 创建 InviteCode 实例
  factory InviteCode.fromJson(Map<String, dynamic> json) {
    return InviteCode(
      code: json['code'] as String? ?? '', // 使用空字符串作为默认值
    );
  }
}

// services/domain_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class DomainService {
  static const String ossDomain =
      'https://storage.googleapis.com/oss-clarity/config.json';

// 从返回的 JSON 中挑选一个可以正常访问的域名
  static Future<String> fetchValidDomain() async {
    try {
      final response = await http
          .get(Uri.parse(ossDomain))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final List<dynamic> websites =
            json.decode(response.body) as List<dynamic>;
        for (final website in websites) {
          final Map<String, dynamic> websiteMap =
              website as Map<String, dynamic>;
          final String domain = websiteMap['url'] as String;
          print(domain);
          if (await _checkDomainAccessibility(domain)) {
            if (kDebugMode) {
              print('Valid domain found: $domain');
            }
            return domain;
          }
        }
        throw Exception('No accessible domains found.');
      } else {
        throw Exception(
            'Failed to fetch websites.json: $ossDomain ${response.statusCode}');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching valid domain: $ossDomain:  $e');
      }
      rethrow;
    }
  }

  static Future<bool> _checkDomainAccessibility(String domain) async {
    try {
      final response = await http
          .get(Uri.parse('$domain/api/v1/guest/comm/config'))
          .timeout(const Duration(seconds: 15));

      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}

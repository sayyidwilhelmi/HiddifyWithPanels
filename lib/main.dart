import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiddify/bootstrap.dart';
// 导入环境配置文件
import 'package:hiddify/core/model/environment.dart';

// 应用程序的主入口函数
void main() async {
  // 确保Flutter的Widgets绑定已初始化
  final widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  return lazyBootstrap(widgetsBinding, Environment.dev);
}

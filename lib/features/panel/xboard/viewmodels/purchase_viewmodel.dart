import 'package:flutter/material.dart';
import 'package:hiddify/features/panel/xboard/models/plan_model.dart';
import 'package:hiddify/features/panel/xboard/services/purchase_service.dart';

class PurchaseViewModel extends ChangeNotifier {
  final PurchaseService _purchaseService;
  List<Plan> _plans = [];
  String? _errorMessage;
  bool _isLoading = false;

  List<Plan> get plans => _plans;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  PurchaseViewModel({required PurchaseService purchaseService})
      : _purchaseService = purchaseService;

  // 每次调用时都重新加载数据
  Future<void> fetchPlans() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _plans = await _purchaseService.fetchPlanData();
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}

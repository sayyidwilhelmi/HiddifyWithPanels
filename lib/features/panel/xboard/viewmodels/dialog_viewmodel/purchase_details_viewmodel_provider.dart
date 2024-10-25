// purchase_details_view_model_provider.dart

import 'package:hiddify/features/panel/xboard/viewmodels/dialog_viewmodel/purchase_details_viewmodel.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';


class PurchaseDetailsViewModelParams {
  final int planId;

  PurchaseDetailsViewModelParams({
    required this.planId,
  });
}

final purchaseDetailsViewModelProvider = ChangeNotifierProvider.autoDispose
    .family<PurchaseDetailsViewModel, PurchaseDetailsViewModelParams>(
  (ref, params) => PurchaseDetailsViewModel(
    planId: params.planId,
  ),
);

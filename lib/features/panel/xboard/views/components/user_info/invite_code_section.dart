// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/services/future_provider.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/invite_code_service.dart';

import 'package:hiddify/features/panel/xboard/utils/storage/token_storage.dart';

import 'package:hooks_riverpod/hooks_riverpod.dart';

class InviteCodeSection extends ConsumerWidget {
  const InviteCodeSection({super.key});

  Future<void> _generateInviteCode(BuildContext context, WidgetRef ref) async {
    final t = ref.watch(translationsProvider);
    final accessToken = await getToken();
    if (accessToken == null) {
      _showSnackbar(context, t.userInfo.noAccessToken);
      return;
    }

    try {
      final success = await InviteCodeService().generateInviteCode(accessToken);
      if (success) {
        _showSnackbar(context, t.inviteCode.generateInviteCode);
        // ignore: unused_result
        ref.refresh(inviteCodesProvider);
      } else {
        _showSnackbar(context, t.inviteCode.inviteCodeGenerateError);
      }
    } catch (e) {
      _showSnackbar(context, "${t.inviteCode.inviteCodeGenerateError}: $e");
    }
  }

  void _showSnackbar(BuildContext context, String message) {
    final snackBar = SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 3),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = ref.watch(translationsProvider);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  t.inviteCode.inviteCodeListTitle,
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold,),
                ),
                ElevatedButton.icon(
                  onPressed: () => _generateInviteCode(context, ref),
                  icon: const Icon(Icons.add),
                  label: Text(t.inviteCode.generateInviteCode),
                ),
              ],
            ),
            const Divider(),
            Consumer(
              builder: (context, ref, child) {
                final inviteCodesAsync = ref.watch(inviteCodesProvider);

                return inviteCodesAsync.when(
                  data: (inviteCodes) {
                    if (inviteCodes.isEmpty) {
                      return Center(child: Text(t.inviteCode.noInviteCodes));
                    }
                    return ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: inviteCodes.length,
                      itemBuilder: (context, index) {
                        final inviteCode = inviteCodes[index];
                        final fullInviteLink =
                            InviteCodeService().getInviteLink(inviteCode.code);
                        return ListTile(
                          title: Text(inviteCode.code),
                          trailing: IconButton(
                            icon: const Icon(Icons.copy),
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: fullInviteLink),);
                              _showSnackbar(
                                context,
                                '${t.inviteCode.copiedInviteCode} $fullInviteLink',
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (error, _) => Center(
                    child: Text('${t.inviteCode.fetchInviteCodesError} $error'),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

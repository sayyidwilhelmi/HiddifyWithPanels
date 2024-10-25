// views/forget_password_view.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:hiddify/core/localization/translations.dart';
import 'package:hiddify/features/panel/xboard/services/http_service/auth_service.dart';
import 'package:hiddify/features/panel/xboard/viewmodels/login_viewmodel/forget_password_viewmodel.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final forgetPasswordViewModelProvider = ChangeNotifierProvider((ref) {
  return ForgetPasswordViewModel(
    authService: AuthService(),
  );
});

class ForgetPasswordPage extends ConsumerWidget {
  const ForgetPasswordPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(forgetPasswordViewModelProvider);
    final t = ref.watch(translationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(t.forgetPassword.pageTitle),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            context.go('/login');
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          child: Column(
            children: [
              TextFormField(
                controller: viewModel.emailController,
                decoration: InputDecoration(labelText: t.forgetPassword.email),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.forgetPassword.emailEmptyError;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: viewModel.passwordController,
                decoration: InputDecoration(
                  labelText: t.forgetPassword.newPassword,
                  suffixIcon: IconButton(
                    icon: Icon(viewModel.obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off,),
                    onPressed: viewModel.togglePasswordVisibility,
                  ),
                ),
                obscureText: viewModel.obscurePassword,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.forgetPassword.passwordEmptyError;
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: viewModel.emailCodeController,
                decoration: InputDecoration(
                  labelText: t.forgetPassword.verificationCode,
                  suffixIcon: viewModel.isCountingDown
                      ? Text('${viewModel.countdownTime} s')
                      : TextButton(
                          onPressed: viewModel.isCountingDown
                              ? null
                              : viewModel.sendVerificationCode,
                          child: Text(t.forgetPassword.sendCode),
                        ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return t.forgetPassword.verificationCodeEmptyError;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: viewModel.isLoading
                    ? null
                    : () => viewModel.resetPassword(context),
                child: viewModel.isLoading
                    ? const CircularProgressIndicator()
                    : Text(t.forgetPassword.resetPassword),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

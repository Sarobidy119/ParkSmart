import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/validators.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/widgets/common/custom_button.dart';
import '../../../presentation/widgets/common/custom_input.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final ScrollController? scrollController;
  final bool showRegisterLink;

  const LoginScreen({
    super.key,
    this.scrollController,
    this.showRegisterLink = true,
  });

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState.loading;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          controller: widget.scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                Text(
                  AppStrings.loginTitle,
                  style: AppTheme.themeData().textTheme.displayMedium,
                ),
                const SizedBox(height: 20),
                CustomInput(
                  controller: _emailController,
                  label: AppStrings.emailLabel,
                  hintText: 'votre@email.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final value = v?.trim() ?? '';
                    if (value.isEmpty) return 'Email requis';
                    if (!isValidEmail(value)) return 'Email invalide';
                    return null;
                  },
                  prefixIcon: const Icon(
                    Icons.mail_outline,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  AppStrings.passwordLabel,
                  style: AppTheme.themeData().textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscure,
                  validator: (v) {
                    final value = v ?? '';
                    if (value.isEmpty) return 'Mot de passe requis';
                    if (value.length < 6) return 'Mot de passe trop court';
                    return null;
                  },
                  decoration: InputDecoration(
                    hintText: '........',
                    filled: true,
                    fillColor: AppColors.white,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: AppColors.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Recuperation non configuree.'),
                        ),
                      );
                    },
                    child: Text(
                      AppStrings.forgotPassword,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: CustomButton(
                    text: AppStrings.signIn,
                    isLoading: isLoading,
                    onPressed: () async {
                      final valid = _formKey.currentState?.validate() ?? false;
                      if (!valid) return;

                      try {
                        await ref.read(authProvider.notifier).signIn(
                              _emailController.text.trim().toLowerCase(),
                              _passwordController.text,
                            );
                        if (!context.mounted) return;
                        context.go('/home');
                      } catch (e) {
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(e.toString())),
                        );
                      }
                    },
                  ),
                ),
                if (widget.showRegisterLink) ...[
                  const SizedBox(height: 22),
                  Center(
                    child: Text(
                      'Pas encore de compte ?',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: TextButton(
                      onPressed: () => context.go('/register'),
                      child: Text(
                        AppStrings.signUpLink,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.primary),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

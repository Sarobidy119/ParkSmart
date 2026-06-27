import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/utils/validators.dart';
import '../../../presentation/providers/auth_provider.dart';
import '../../../presentation/widgets/common/custom_button.dart';
import '../../../presentation/widgets/common/custom_input.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomController = TextEditingController();
  final _prenomController = TextEditingController();
  final _emailController = TextEditingController();
  final _telController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscure = true;
  bool _agree = false;

  @override
  void dispose() {
    _nomController.dispose();
    _prenomController.dispose();
    _emailController.dispose();
    _telController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _openLoginSheet() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          expand: false,
          initialChildSize: 0.88,
          minChildSize: 0.55,
          maxChildSize: 0.95,
          builder: (context, scrollController) {
            return Column(
              children: [
                const SizedBox(height: 10),
                Container(
                  width: 42,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.border,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Expanded(
                  child: LoginScreen(
                    scrollController: scrollController,
                    showRegisterLink: false,
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  AppStrings.registerTitle,
                  style: Theme.of(context).textTheme.displayMedium,
                ),
                const SizedBox(height: 18),
                CustomInput(
                  controller: _nomController,
                  label: AppStrings.nom,
                  hintText: 'Entrez votre nom',
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return 'Nom requis';
                    return null;
                  },
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 12),
                CustomInput(
                  controller: _prenomController,
                  label: AppStrings.prenom,
                  hintText: 'Entrez votre prenom',
                  validator: (v) {
                    if ((v ?? '').trim().isEmpty) return 'Prenom requis';
                    return null;
                  },
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                const SizedBox(height: 12),
                CustomInput(
                  controller: _emailController,
                  label: AppStrings.emailLabel,
                  hintText: 'votre@email.com',
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    final value = (v ?? '').trim();
                    if (value.isEmpty) return 'Email requis';
                    if (!isValidEmail(value)) return 'Email invalide';
                    return null;
                  },
                  prefixIcon: const Icon(Icons.mail_outline),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    AppStrings.telephone,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                Row(
                  children: [
                    Container(
                      height: 52,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        border: Border.all(color: AppColors.border, width: 0.8),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                      child: Text(
                        '+261',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _telController,
                        keyboardType: TextInputType.phone,
                        validator: (v) {
                          final value = (v ?? '').trim();
                          if (value.isEmpty) return 'Telephone requis';
                          if (value.length < 9) return 'Telephone invalide';
                          return null;
                        },
                        decoration: InputDecoration(
                          hintText: '34 00 000 00',
                          filled: true,
                          fillColor: AppColors.white,
                          border: OutlineInputBorder(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                              width: 0.8,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.border,
                              width: 0.8,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.only(
                              topRight: Radius.circular(12),
                              bottomRight: Radius.circular(12),
                            ),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 1.2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    AppStrings.passwordLabel,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
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
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 6),
                  child: Text(
                    AppStrings.confirmPassword,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                TextFormField(
                  controller: _confirmController,
                  obscureText: true,
                  validator: (v) {
                    final value = v ?? '';
                    if (value.isEmpty) return 'Confirmation requise';
                    if (value != _passwordController.text) {
                      return 'Les mots de passe ne correspondent pas';
                    }
                    return null;
                  },
                  decoration: const InputDecoration(
                    hintText: '........',
                    filled: true,
                    fillColor: AppColors.white,
                    prefixIcon: Icon(Icons.lock_reset_outlined),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _agree,
                      activeColor: AppColors.primary,
                      onChanged: (v) => setState(() => _agree = v ?? false),
                    ),
                    Expanded(
                      child: Text(
                        "J'accepte les Conditions d'Utilisation et la Politique de Confidentialite de ParkSmart.",
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: CustomButton(
                    text: AppStrings.signUp,
                    isLoading: authState.loading,
                    onPressed: () async {
                      if (!_agree) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Veuillez accepter les conditions.'),
                          ),
                        );
                        return;
                      }

                      final valid = _formKey.currentState?.validate() ?? false;
                      if (!valid) return;

                      try {
                        await ref.read(authProvider.notifier).signUp(
                              nom: _nomController.text.trim(),
                              prenom: _prenomController.text.trim(),
                              email: _emailController.text.trim().toLowerCase(),
                              telephone: '+261${_telController.text.trim()}',
                              password: _passwordController.text,
                            );
                        if (!context.mounted) return;
                        final user = ref.read(authProvider).user;
                        if (user == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Compte cree. Verifiez votre email puis connectez-vous.',
                              ),
                            ),
                          );
                          await _openLoginSheet();
                          return;
                        }
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
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: _openLoginSheet,
                    child: Text(
                      'Deja un compte ? ${AppStrings.loginLink}',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppColors.primary),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

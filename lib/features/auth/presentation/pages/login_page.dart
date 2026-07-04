import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:field_tracker/core/router/route_names.dart';
import 'package:field_tracker/core/theme/app_colors.dart';
import 'package:field_tracker/core/theme/app_text_styles.dart';
import 'package:field_tracker/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:field_tracker/features/auth/presentation/bloc/auth_event.dart';
import 'package:field_tracker/features/auth/presentation/bloc/auth_state.dart';
import 'package:field_tracker/features/auth/presentation/widgets/auth_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _emailFocus = FocusNode();
  final _passwordFocus = FocusNode();
  bool _passwordVisible = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(
          LoginRequested(
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? AppColors.primaryDark : AppColors.primaryLight;
    final bgColor =
        isDark ? AppColors.backgroundDark : AppColors.backgroundLight;
    final textPrimary =
        isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight;
    final textSecondary =
        isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          context.go(RouteNames.locations);
        } else if (state is AuthFailureState) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor:
                    isDark ? AppColors.errorDark : AppColors.errorLight,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            );
        }
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 16),

                    // ── Logo ────────────────────────────────────────────────
                    _AppLogo(primary: primary),

                    const SizedBox(height: 28),

                    // ── Heading ─────────────────────────────────────────────
                    Text(
                      'Welcome back',
                      style: AppTextStyles.headingLarge.copyWith(
                        color: textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Sign in to start your shift',
                      style: AppTextStyles.subtitle.copyWith(
                        color: textSecondary,
                      ),
                    ),

                    const SizedBox(height: 32),

                    // ── Email ───────────────────────────────────────────────
                    AuthTextField(
                      label: 'Email',
                      hint: 'john.doe@example.com',
                      prefixIcon: Icons.email_outlined,
                      controller: _emailController,
                      focusNode: _emailFocus,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_passwordFocus),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(v)) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),

                    const SizedBox(height: 16),

                    // ── Password ────────────────────────────────────────────
                    AuthTextField(
                      label: 'Password',
                      hint: '••••••••',
                      prefixIcon: Icons.lock_outline,
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      obscureText: !_passwordVisible,
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _submit(),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _passwordVisible
                              ? Icons.visibility_off_outlined
                              : Icons.visibility_outlined,
                          size: 18,
                          color: textSecondary,
                        ),
                        onPressed: () =>
                            setState(() => _passwordVisible = !_passwordVisible),
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Password is required';
                        return null;
                      },
                    ),

                    // ── Forgot password ─────────────────────────────────────
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {
                          // TODO: navigate to forgot-password screen
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: primary,
                          padding: const EdgeInsets.only(top: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: Text(
                          'Forgot password?',
                          style: AppTextStyles.link.copyWith(color: primary),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // ── Sign in button ──────────────────────────────────────
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        final isLoading = state is AuthLoading;
                        return SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _submit,
                            child: isLoading
                                ? const SizedBox(
                                    height: 22,
                                    width: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.5,
                                      color: Colors.white,
                                    ),
                                  )
                                : Text(
                                    'Sign in',
                                    style: AppTextStyles.button.copyWith(
                                      color: isDark
                                          ? AppColors.onPrimaryDark
                                          : AppColors.onPrimaryLight,
                                    ),
                                  ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 24),

                    // ── Register link ───────────────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: AppTextStyles.subtitle.copyWith(
                            color: textSecondary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => context.push(RouteNames.register),
                          child: Text(
                            'Register',
                            style: AppTextStyles.link.copyWith(color: primary),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared logo widget ────────────────────────────────────────────────────────

class _AppLogo extends StatelessWidget {
  final Color primary;
  const _AppLogo({required this.primary});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          decoration: BoxDecoration(
            color: primary,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.location_on,
            color: Colors.white,
            size: 36,
          ),
        ),
        const SizedBox(height: 14),
        RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Field',
                style: AppTextStyles.title.copyWith(
                  color: isDark
                      ? AppColors.textPrimaryDark
                      : AppColors.textPrimaryLight,
                ),
              ),
              TextSpan(
                text: 'Track',
                style: AppTextStyles.title.copyWith(color: primary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

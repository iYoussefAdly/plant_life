import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/service_locator.dart';
import '../../../../core/localization/l10n.dart';
import '../../../../core/networking/socket_service.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';
import '../widgets/auth_footer.dart';
import '../widgets/auth_header.dart';
import '../widgets/login_form.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AuthCubit>(),
      child: Scaffold(
        body: BlocListener<AuthCubit, AuthState>(
          listener: (context, state) {
            if (state is AuthSuccess) {
              sl<SocketService>().connect();
              context.go(AppRoutes.home);
            } else if (state is AuthError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizeMessage(context, state.message)),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 60),
                  AuthHeader(
                    icon: Icons.eco,
                    title: context.l10n.welcomeBack,
                    subtitle: context.l10n.signInSubtitle,
                  ),
                  const SizedBox(height: 48),
                  const LoginForm(),
                  const SizedBox(height: 24),
                  AuthFooter(
                    promptText: context.l10n.dontHaveAccount,
                    actionText: context.l10n.signUp,
                    onAction: () => context.go(AppRoutes.register),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

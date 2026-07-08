import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/auth_cubit.dart';
import '../bloc/auth_state.dart';

class RegisterForm extends StatefulWidget {
  const RegisterForm({super.key});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  // UI only for now — only one option exists and it isn't sent to the
  // register API yet.
  String _plantType = 'tomato';

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Form(
      key: _formKey,
      child: Column(
        children: [
          AppTextField(
            label: l10n.fullName,
            hint: l10n.enterYourFullName,
            controller: _nameController,
            keyboardType: TextInputType.name,
            prefixIcon: const Icon(Icons.person_outlined, size: 20),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterName;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: l10n.email,
            hint: l10n.enterYourEmail,
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            prefixIcon: const Icon(Icons.email_outlined, size: 20),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return l10n.pleaseEnterEmail;
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(l10n.plantType, style: AppTextStyles.labelLarge),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _plantType,
                icon: const Icon(Icons.keyboard_arrow_down, size: 20),
                items: [
                  DropdownMenuItem(
                    value: 'tomato',
                    child: Text(l10n.plantTypeTomato),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _plantType = value);
                },
              ),
            ],
          ),
          const SizedBox(height: 16),
          AppTextField(
            label: l10n.password,
            hint: l10n.createAPassword,
            controller: _passwordController,
            obscureText: _obscurePassword,
            prefixIcon: const Icon(Icons.lock_outlined, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () {
                setState(() => _obscurePassword = !_obscurePassword);
              },
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return l10n.pleaseEnterAPassword;
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          BlocBuilder<AuthCubit, AuthState>(
            builder: (context, state) {
              final isLoading = state is AuthLoading;
              return AppButton(
                text: l10n.createAccount,
                isLoading: isLoading,
                width: double.infinity,
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    context.read<AuthCubit>().register(
                          name: _nameController.text.trim(),
                          email: _emailController.text.trim(),
                          password: _passwordController.text,
                        );
                  }
                },
              );
            },
          ),
        ],
      ),
    );
  }
}

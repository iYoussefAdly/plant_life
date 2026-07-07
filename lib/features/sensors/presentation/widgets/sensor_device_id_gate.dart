import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/localization/l10n.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/widgets/app_button.dart';
import '../../../../core/widgets/app_text_field.dart';
import '../bloc/sensors_cubit.dart';

/// Onboarding/empty state shown until the user configures a sensor Device ID.
/// The Sensors feature stays locked behind this gate.
class SensorDeviceIdGate extends StatefulWidget {
  const SensorDeviceIdGate({super.key});

  @override
  State<SensorDeviceIdGate> createState() => _SensorDeviceIdGateState();
}

class _SensorDeviceIdGateState extends State<SensorDeviceIdGate> {
  final _controller = TextEditingController();
  bool _canSubmit = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      final canSubmit = _controller.text.trim().isNotEmpty;
      if (canSubmit != _canSubmit) setState(() => _canSubmit = canSubmit);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final id = _controller.text.trim();
    if (id.isEmpty) return;
    FocusScope.of(context).unfocus();
    context.read<SensorsCubit>().saveDeviceId(id);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 32),
            Center(
              child: Container(
                width: 96,
                height: 96,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.sensors_outlined,
                  size: 48,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              l10n.connectYourDevice,
              textAlign: TextAlign.center,
              style: AppTextStyles.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              l10n.connectYourDeviceSubtitle,
              textAlign: TextAlign.center,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            AppTextField(
              label: l10n.deviceIdLabel,
              hint: l10n.deviceIdHint,
              controller: _controller,
              prefixIcon: const Icon(Icons.qr_code_2_outlined),
              onChanged: (_) {},
            ),
            const SizedBox(height: 20),
            AppButton(
              text: l10n.connectDevice,
              icon: Icons.link_outlined,
              onPressed: _canSubmit ? _submit : null,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline,
                    size: 15, color: AppColors.textHint),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    l10n.deviceIdHelp,
                    style: AppTextStyles.bodySmall
                        .copyWith(color: AppColors.textHint),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

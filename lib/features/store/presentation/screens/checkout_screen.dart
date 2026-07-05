import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_text_styles.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../core/localization/l10n.dart';
import '../../domain/entities/shipping_address.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/cart_state.dart';
import '../bloc/checkout_cubit.dart';

enum _PayMethod { cash, card }

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _city = TextEditingController();
  final _street = TextEditingController();
  final _phone = TextEditingController();
  final _details = TextEditingController();
  _PayMethod _method = _PayMethod.cash;

  @override
  void dispose() {
    _city.dispose();
    _street.dispose();
    _phone.dispose();
    _details.dispose();
    super.dispose();
  }

  ShippingAddress get _address => ShippingAddress(
        city: _city.text.trim(),
        street: _street.text.trim(),
        phone: _phone.text.trim(),
        details: _details.text.trim(),
      );

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    // Guard against a deep-linked/empty-cart checkout (button is otherwise
    // only reachable with items in the cart).
    if (context.read<CartCubit>().itemCount == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.cartEmptyTitle)),
      );
      return;
    }
    final cubit = context.read<CheckoutCubit>();
    if (_method == _PayMethod.cash) {
      cubit.placeCashOrder(_address);
    } else {
      cubit.startStripeCheckout(_address);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.l10n.checkout, style: AppTextStyles.headlineMedium),
      ),
      body: BlocConsumer<CheckoutCubit, CheckoutState>(
        listener: _onState,
        builder: (context, state) {
          final submitting = state is CheckoutSubmitting;
          return Column(
            children: [
              Expanded(
                child: Form(
                  key: _formKey,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      Text(context.l10n.shippingAddress,
                          style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 12),
                      _field(_city, context.l10n.city, Icons.location_city_outlined),
                      _field(_street, context.l10n.street, Icons.signpost_outlined),
                      _field(_phone, context.l10n.phone, Icons.phone_outlined,
                          keyboard: TextInputType.phone),
                      _field(_details, context.l10n.detailsOptional, Icons.home_outlined,
                          required: false),
                      const SizedBox(height: 20),
                      Text(context.l10n.paymentMethod,
                          style: AppTextStyles.headlineSmall),
                      const SizedBox(height: 12),
                      _PaymentOption(
                        icon: Icons.payments_outlined,
                        title: context.l10n.cashOnDelivery,
                        subtitle: context.l10n.payWhenArrives,
                        selected: _method == _PayMethod.cash,
                        onTap: () => setState(() => _method = _PayMethod.cash),
                      ),
                      const SizedBox(height: 10),
                      _PaymentOption(
                        icon: Icons.credit_card,
                        title: context.l10n.payWithCardStripe,
                        subtitle: context.l10n.secureOnlinePayment,
                        selected: _method == _PayMethod.card,
                        onTap: () => setState(() => _method = _PayMethod.card),
                      ),
                    ],
                  ),
                ),
              ),
              _SummaryBar(submitting: submitting, onSubmit: _submit),
            ],
          );
        },
      ),
    );
  }

  Future<void> _onState(BuildContext context, CheckoutState state) async {
    if (state is CheckoutOrderPlaced) {
      // Order created + backend emptied the cart — refresh the shared cart.
      context.read<CartCubit>().load(silent: true);
      context.read<CheckoutCubit>().reset();
      context.go('${AppRoutes.orderDetails}/${state.order.id}');
    } else if (state is CheckoutRedirect) {
      final launched = await launchUrl(
        Uri.parse(state.url),
        mode: LaunchMode.externalApplication,
      );
      if (!context.mounted) return;
      context.read<CheckoutCubit>().reset();
      if (launched) {
        // The order is created by Stripe's webhook after payment completes.
        context.read<CartCubit>().load(silent: true);
        context.go(AppRoutes.orders);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.couldNotOpenPayment)),
        );
      }
    } else if (state is CheckoutError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  }

  Widget _field(
    TextEditingController controller,
    String label,
    IconData icon, {
    TextInputType? keyboard,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboard,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, size: 20),
        ),
        validator: required
            ? (v) => (v == null || v.trim().isEmpty)
                ? context.l10n.requiredField
                : null
            : null,
      ),
    );
  }
}

class _SummaryBar extends StatelessWidget {
  final bool submitting;
  final VoidCallback onSubmit;

  const _SummaryBar({required this.submitting, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          16, 14, 16, 14 + MediaQuery.of(context).padding.bottom),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<CartCubit, CartState>(
            builder: (context, state) {
              final subtotal = state is CartLoaded ? state.cart.subtotal : 0;
              return Row(
                children: [
                  Text(context.l10n.subtotal, style: AppTextStyles.bodyMedium),
                  const Spacer(),
                  Text(formatPrice(subtotal),
                      style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700)),
                ],
              );
            },
          ),
          const SizedBox(height: 4),
          Text(
            context.l10n.shippingCalculated,
            style: AppTextStyles.bodySmall
                .copyWith(color: AppColors.textHint, fontSize: 11),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: submitting ? null : onSubmit,
              child: submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(context.l10n.placeOrder),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  const _PaymentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withValues(alpha: 0.06) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected
                ? AppColors.primary
                : AppColors.textHint.withValues(alpha: 0.3),
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: AppTextStyles.bodyMedium
                          .copyWith(fontWeight: FontWeight.w600)),
                  Text(subtitle,
                      style: AppTextStyles.bodySmall
                          .copyWith(color: AppColors.textSecondary)),
                ],
              ),
            ),
            Icon(
              selected ? Icons.radio_button_checked : Icons.radio_button_off,
              color: selected ? AppColors.primary : AppColors.textHint,
            ),
          ],
        ),
      ),
    );
  }
}

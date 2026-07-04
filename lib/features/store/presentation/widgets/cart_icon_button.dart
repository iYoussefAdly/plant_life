import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../bloc/cart_cubit.dart';
import '../bloc/cart_state.dart';

/// App-bar cart button with a live count badge, backed by the shared [CartCubit]
/// so it updates everywhere the moment the cart changes.
class CartIconButton extends StatelessWidget {
  const CartIconButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CartCubit, CartState>(
      builder: (context, state) {
        final count = state is CartLoaded ? state.cart.totalQuantity : 0;
        return IconButton(
          icon: Badge(
            isLabelVisible: count > 0,
            backgroundColor: AppColors.error,
            textColor: Colors.white,
            label: Text('$count'),
            child: const Icon(Icons.shopping_cart_outlined),
          ),
          onPressed: () => context.push(AppRoutes.cart),
        );
      },
    );
  }
}

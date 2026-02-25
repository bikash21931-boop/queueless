import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/cart_item.dart';
import '../../scanner/domain/product.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return [];
  }

  // Add Item to Cart
  void addProduct(Product product) {
    final stateList = state.toList();
    final index = stateList.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      // Increase quantity if item exists (Duplicate Scan Prevention)
      stateList[index] = stateList[index].copyWith(
        quantity: stateList[index].quantity + 1,
      );
    } else {
      // Add new item
      stateList.add(CartItem(product: product, quantity: 1));
    }
    state = stateList;
  }

  // Remove completely
  void removeItem(String productId) {
    state = state.where((item) => item.product.id != productId).toList();
  }

  // Increase quantity
  void increaseQuantity(String productId) {
    state = [
      for (final item in state)
        if (item.product.id == productId)
          item.copyWith(quantity: item.quantity + 1)
        else
          item,
    ];
  }

  // Decrease quantity
  void decreaseQuantity(String productId) {
    final stateList = state.toList();
    final index = stateList.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      if (stateList[index].quantity > 1) {
        stateList[index] = stateList[index].copyWith(
          quantity: stateList[index].quantity - 1,
        );
        state = stateList;
      } else {
        // Remove item if quantity drops to 0
        removeItem(productId);
      }
    }
  }

  // Clear cart
  void clear() {
    state = [];
  }

  // Total amount
  double get totalAmount {
    return state.fold(0, (total, item) => total + item.totalPrice);
  }
}

final cartProvider = NotifierProvider<CartNotifier, List<CartItem>>(() {
  return CartNotifier();
});

final cartTotalProvider = Provider<double>((ref) {
  final cart = ref.watch(cartProvider);
  return cart.fold(0, (total, item) => total + item.totalPrice);
});

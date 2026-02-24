import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/cart_item.dart';
import '../../scanner/domain/product.dart';

class CartNotifier extends Notifier<List<CartItem>> {
  @override
  List<CartItem> build() {
    return [
      CartItem(
        product: Product(
          id: 'mock_123',
          name: 'Premium Organic Coffee Roast',
          price: 14.99,
          qrCode: 'mock_123',
          imageUrl:
              'https://images.unsplash.com/photo-1559525839-b184a4d698c7?auto=format&fit=crop&q=80&w=200',
          category: 'Beverages',
        ),
        quantity: 1,
      ),
      CartItem(
        product: Product(
          id: 'mock_456',
          name: 'Artisan Sourdough Bread',
          price: 6.50,
          qrCode: 'mock_456',
          imageUrl:
              'https://images.unsplash.com/photo-1589367920969-ab8e050eb0e9?auto=format&fit=crop&q=80&w=200',
          category: 'Bakery',
        ),
        quantity: 2,
      ),
    ];
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
    state = [
      for (final item in state)
        if (item.product.id == productId && item.quantity > 1)
          item.copyWith(quantity: item.quantity - 1)
        else
          item,
    ];
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

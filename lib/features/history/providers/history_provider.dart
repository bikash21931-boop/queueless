import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/providers/auth_provider.dart';
import '../domain/transaction_model.dart';
import 'package:flutter/foundation.dart';

class HistoryState {
  final List<TransactionModel> transactions;
  final bool isLoading;
  final String? error;

  HistoryState({
    this.transactions = const [],
    this.isLoading = false,
    this.error,
  });

  HistoryState copyWith({
    List<TransactionModel>? transactions,
    bool? isLoading,
    String? error,
  }) {
    return HistoryState(
      transactions: transactions ?? this.transactions,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class HistoryNotifier extends Notifier<HistoryState> {
  @override
  HistoryState build() {
    // Automatically load history when the notifier is initialized
    _loadHistory();
    return HistoryState(isLoading: true);
  }

  Future<void> _loadHistory() async {
    final user = ref.read(authProvider).user;

    if (user == null) {
      state = state.copyWith(isLoading: false, error: 'User not logged in');
      return;
    }

    state = state.copyWith(isLoading: true, error: null);

    try {
      // Fetch from API
      // final response = await ApiClient.fetchUserTransactions(user.id);

      // MOCK DATA for Hackathon UI evaluation
      await Future.delayed(const Duration(seconds: 1));

      final mockTransactions = [
        TransactionModel(
          id: 'TXN-102938',
          userId: user.id,
          totalAmount: 14.99,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
          receiptQr: 'verify:TXN-102938:mock',
          items: [
            TransactionItem(
              productId: 'mock_123',
              name: 'Premium Organic Coffee (Mock)',
              price: 14.99,
              quantity: 1,
            ),
          ],
        ),
        TransactionModel(
          id: 'TXN-093847',
          userId: user.id,
          totalAmount: 34.50,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          receiptQr: 'verify:TXN-093847:mock',
          items: [
            TransactionItem(
              productId: 'mock_124',
              name: 'Artisan Bread',
              price: 6.50,
              quantity: 2,
            ),
            TransactionItem(
              productId: 'mock_125',
              name: 'Oat Milk',
              price: 5.99,
              quantity: 1,
            ),
            TransactionItem(
              productId: 'mock_126',
              name: 'Fresh Strawberries',
              price: 15.51,
              quantity: 1,
            ),
          ],
        ),
      ];

      state = state.copyWith(isLoading: false, transactions: mockTransactions);
    } catch (e) {
      debugPrint('Error loading history: \$e');
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load receipt history.',
      );
    }
  }

  Future<void> refresh() => _loadHistory();
}

final historyProvider = NotifierProvider<HistoryNotifier, HistoryState>(() {
  return HistoryNotifier();
});

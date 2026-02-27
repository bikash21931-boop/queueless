import 'package:flutter_riverpod/flutter_riverpod.dart';
// Removed unused auth_provider import
import '../domain/transaction_model.dart';
import 'package:flutter/foundation.dart';

import '../../../core/network/api_client.dart';

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
    Future.microtask(() => _loadHistory());
    return HistoryState(isLoading: true);
  }

  Future<void> _loadHistory() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final rawTransactions = await ApiClient.fetchHistory();

      final parsedTransactions = rawTransactions.map((t) {
        return TransactionModel.fromJson(t);
      }).toList();

      state = state.copyWith(
        isLoading: false,
        transactions: parsedTransactions,
      );
    } catch (e) {
      debugPrint('Error loading history: $e');
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

import 'api_client.dart';

/// Mirrors app/accounts/schemas.py::BalanceResponse.
class BalanceResponse {
  BalanceResponse({required this.balanceMinor, required this.balanceFormatted, required this.narration});

  final int balanceMinor;
  final String balanceFormatted;
  final String narration;

  factory BalanceResponse.fromJson(Map<String, dynamic> json) => BalanceResponse(
    balanceMinor: json['balance_minor'] as int,
    balanceFormatted: json['balance_formatted'] as String,
    narration: json['narration'] as String,
  );
}

/// Mirrors app/accounts/schemas.py::CategoryBreakdown.
class CategoryBreakdown {
  CategoryBreakdown({required this.category, required this.totalFormatted, required this.transactionCount});

  final String category;
  final String totalFormatted;
  final int transactionCount;

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) => CategoryBreakdown(
    category: json['category'] as String,
    totalFormatted: json['total_formatted'] as String,
    transactionCount: json['transaction_count'] as int,
  );
}

/// Mirrors app/accounts/schemas.py::SpendSummaryResponse.
class SpendSummaryResponse {
  SpendSummaryResponse({
    required this.totalSpentFormatted,
    required this.breakdown,
    required this.narration,
  });

  final String totalSpentFormatted;
  final List<CategoryBreakdown> breakdown;
  final String narration;

  factory SpendSummaryResponse.fromJson(Map<String, dynamic> json) => SpendSummaryResponse(
    totalSpentFormatted: json['total_spent_formatted'] as String,
    breakdown: (json['breakdown'] as List).map((e) => CategoryBreakdown.fromJson(e as Map<String, dynamic>)).toList(),
    narration: json['narration'] as String,
  );
}

/// Mirrors app/accounts/schemas.py::TransactionOut.
class TransactionOut {
  TransactionOut({
    required this.id,
    required this.occurredAt,
    required this.direction,
    required this.amountFormatted,
    required this.category,
    required this.counterparty,
    required this.description,
  });

  final String id;
  final DateTime occurredAt;
  final String direction;
  final String amountFormatted;
  final String category;
  final String counterparty;
  final String description;

  factory TransactionOut.fromJson(Map<String, dynamic> json) => TransactionOut(
    id: json['id'] as String,
    occurredAt: DateTime.parse(json['occurred_at'] as String),
    direction: json['direction'] as String,
    amountFormatted: json['amount_formatted'] as String,
    category: json['category'] as String,
    counterparty: json['counterparty'] as String,
    description: json['description'] as String,
  );
}

/// Mirrors app/accounts/schemas.py::TransactionHistoryResponse.
class TransactionHistoryResponse {
  TransactionHistoryResponse({required this.count, required this.transactions, required this.narration});

  final int count;
  final List<TransactionOut> transactions;
  final String narration;

  factory TransactionHistoryResponse.fromJson(Map<String, dynamic> json) => TransactionHistoryResponse(
    count: json['count'] as int,
    transactions: (json['transactions'] as List).map((e) => TransactionOut.fromJson(e as Map<String, dynamic>)).toList(),
    narration: json['narration'] as String,
  );
}

class AccountsApi {
  AccountsApi(this._client);

  final ApiClient _client;

  Future<BalanceResponse> getBalance(String userId) async {
    final json = await _client.get('/accounts/$userId/balance');
    return BalanceResponse.fromJson(json);
  }

  /// Mock-instant top-up of fake test money — no real funding rail exists
  /// (every balance in this app is fake). Powers the dashboard's "Add
  /// Money" button and the voice "add money"/"fund my account" intent.
  Future<BalanceResponse> fund(String userId, int amountMinor) async {
    final json = await _client.post('/accounts/$userId/fund', {'amount_minor': amountMinor});
    return BalanceResponse.fromJson(json);
  }

  Future<SpendSummaryResponse> getSpendSummary(String userId, {String period = 'month', String? category}) async {
    final json = await _client.get(
      '/accounts/$userId/spend-summary',
      query: {'period': period, if (category != null) 'category': category},
    );
    return SpendSummaryResponse.fromJson(json);
  }

  Future<TransactionHistoryResponse> getTransactions(String userId, {String period = 'month', String? category}) async {
    final json = await _client.get(
      '/accounts/$userId/transactions',
      query: {'period': period, if (category != null) 'category': category},
    );
    return TransactionHistoryResponse.fromJson(json);
  }
}

import 'api_client.dart';

/// Mirrors app/wallets/schemas.py::WalletOut. Additional-currency wallets
/// opened on top of the default Naira account — that account is unrelated
/// to this API and keeps coming from accounts_api.dart/balance as always.
class WalletOut {
  WalletOut({
    required this.walletId,
    required this.currency,
    required this.accountNumber,
    required this.balanceMinor,
    required this.balanceFormatted,
    required this.createdAt,
  });

  final String walletId;
  final String currency;
  final String accountNumber;
  final int balanceMinor;
  final String balanceFormatted;
  final DateTime createdAt;

  factory WalletOut.fromJson(Map<String, dynamic> json) => WalletOut(
    walletId: json['wallet_id'] as String,
    currency: json['currency'] as String,
    accountNumber: json['account_number'] as String,
    balanceMinor: json['balance_minor'] as int,
    balanceFormatted: json['balance_formatted'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

class WalletsApi {
  WalletsApi(this._client);
  final ApiClient _client;

  /// Currencies a user can open a wallet in — kept in sync with
  /// app/wallets/interfaces.py::SUPPORTED_WALLET_CURRENCIES.
  static const supportedCurrencies = ['USD', 'GBP', 'EUR'];

  Future<List<WalletOut>> listWallets(String userId) async {
    final json = await _client.get('/wallets/$userId');
    return (json['wallets'] as List).map((e) => WalletOut.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<WalletOut> createWallet(String userId, String currency) async {
    final json = await _client.post('/wallets/$userId', {'currency': currency});
    return WalletOut.fromJson(json);
  }

  /// Mock-instant top-up of fake test money — same posture as
  /// AccountsApi.fund() for the main Naira account.
  Future<WalletOut> fundWallet(String userId, String walletId, int amountMinor) async {
    final json = await _client.post('/wallets/$userId/$walletId/fund', {'amount_minor': amountMinor});
    return WalletOut.fromJson(json);
  }
}

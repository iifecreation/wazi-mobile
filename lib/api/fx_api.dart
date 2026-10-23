import 'api_client.dart';

/// Mirrors app/fx/router.py::RateQuoteResponse.
class RateQuoteResponse {
  RateQuoteResponse({
    required this.fromCurrency,
    required this.toCurrency,
    required this.fromAmountMinor,
    required this.toAmountMinor,
    required this.toAmountFormatted,
    required this.rate,
    required this.rateWithMargin,
    required this.feeFormatted,
    required this.expiresInSeconds,
  });

  final String fromCurrency;
  final String toCurrency;
  final int fromAmountMinor;
  final int toAmountMinor;
  final String toAmountFormatted;
  final double rate;
  final double rateWithMargin;
  final String feeFormatted;
  final int expiresInSeconds;

  factory RateQuoteResponse.fromJson(Map<String, dynamic> json) =>
      RateQuoteResponse(
        fromCurrency: json['from_currency'] as String,
        toCurrency: json['to_currency'] as String,
        fromAmountMinor: json['from_amount_minor'] as int,
        toAmountMinor: json['to_amount_minor'] as int,
        toAmountFormatted: json['to_amount_formatted'] as String,
        rate: (json['rate'] as num).toDouble(),
        rateWithMargin: (json['rate_with_margin'] as num).toDouble(),
        feeFormatted: json['fee_formatted'] as String,
        expiresInSeconds: json['expires_in_seconds'] as int,
      );
}

/// Mirrors app/fx/router.py::ConvertResponse.
class ConvertResponse {
  ConvertResponse({
    required this.fromAmountFormatted,
    required this.toAmountFormatted,
    required this.feeFormatted,
    required this.rate,
    required this.fromCurrency,
    required this.toCurrency,
    this.walletId,
  });

  final String fromAmountFormatted;
  final String toAmountFormatted;
  final String feeFormatted;
  final double rate;
  final String fromCurrency;
  final String toCurrency;
  final String? walletId;

  factory ConvertResponse.fromJson(Map<String, dynamic> json) =>
      ConvertResponse(
        fromAmountFormatted: json['from_amount_formatted'] as String,
        toAmountFormatted: json['to_amount_formatted'] as String,
        feeFormatted: json['fee_formatted'] as String,
        rate: (json['rate'] as num).toDouble(),
        fromCurrency: json['from_currency'] as String,
        toCurrency: json['to_currency'] as String,
        walletId: json['wallet_id'] as String?,
      );
}

class FxApi {
  FxApi(this._client);
  final ApiClient _client;

  /// Mid-market rates from NGN to all supported currencies.
  Future<Map<String, double>> getRates() async {
    final json = await _client.get('/fx/rates');
    final rates = json['rates'] as Map<String, dynamic>;
    return rates.map((k, v) => MapEntry(k, (v as num).toDouble()));
  }

  /// Live quote for a specific conversion amount.
  Future<RateQuoteResponse> getQuote({
    required String fromCurrency,
    required String toCurrency,
    required int fromAmountMinor,
  }) async {
    final json = await _client.get('/fx/quote', query: {
      'from_currency': fromCurrency,
      'to_currency': toCurrency,
      'from_amount_minor': fromAmountMinor.toString(),
    });
    return RateQuoteResponse.fromJson(json);
  }

  /// Execute an FX conversion: debit NGN → credit foreign wallet.
  Future<ConvertResponse> convert({
    required String userId,
    required String fromCurrency,
    required String toCurrency,
    required int fromAmountMinor,
  }) async {
    final json = await _client.post('/fx/$userId/convert', {
      'from_currency': fromCurrency,
      'to_currency': toCurrency,
      'from_amount_minor': fromAmountMinor,
    });
    return ConvertResponse.fromJson(json);
  }
}

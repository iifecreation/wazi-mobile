import 'api_client.dart';

class FdProduct {
  FdProduct({required this.termMonths, required this.ratePercent, required this.name});
  final int termMonths;
  final double ratePercent;
  final String name;

  factory FdProduct.fromJson(Map<String, dynamic> json) => FdProduct(
    termMonths: json['term_months'] as int,
    ratePercent: (json['rate_percent'] as num).toDouble(),
    name: json['name'] as String,
  );
}

class FdDeposit {
  FdDeposit({
    required this.depositId,
    required this.amountFormatted,
    required this.termMonths,
    required this.ratePercent,
    required this.interestFormatted,
    required this.maturityAmountFormatted,
    required this.maturityDate,
    required this.status,
  });
  final String depositId;
  final String amountFormatted;
  final int termMonths;
  final double ratePercent;
  final String interestFormatted;
  final String maturityAmountFormatted;
  final String maturityDate;
  final String status;

  factory FdDeposit.fromJson(Map<String, dynamic> json) => FdDeposit(
    depositId: json['deposit_id'] as String,
    amountFormatted: json['amount_formatted'] as String,
    termMonths: json['term_months'] as int,
    ratePercent: (json['rate_percent'] as num).toDouble(),
    interestFormatted: json['interest_formatted'] as String,
    maturityAmountFormatted: json['maturity_amount_formatted'] as String,
    maturityDate: json['maturity_date'] as String,
    status: json['status'] as String,
  );
}

class FixedDepositsApi {
  FixedDepositsApi(this._client);
  final ApiClient _client;

  Future<List<FdProduct>> listProducts() async {
    final json = await _client.get('/fixed-deposits/products');
    return (json['products'] as List)
        .map((e) => FdProduct.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<FdDeposit>> listDeposits(String userId) async {
    final json = await _client.get('/fixed-deposits/$userId');
    return (json['deposits'] as List)
        .map((e) => FdDeposit.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FdDeposit> createDeposit(String userId, int amountMinor, int termMonths) async {
    final json = await _client.post('/fixed-deposits/$userId', {
      'amount_minor': amountMinor,
      'term_months': termMonths,
    });
    return FdDeposit.fromJson(json);
  }
}

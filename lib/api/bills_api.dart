import 'api_client.dart';

/// Mirrors app/bills/schemas.py::BillOut — real utility/airtime payments
/// derived from the user's own transactions (app/baas/), not a hardcoded
/// stub. `category` is one of app/categorization/service.py's SpendCategory
/// values — always "utilities" or "airtime_data" here.
class BillOut {
  BillOut({required this.title, required this.amountFormatted, required this.occurredAt, required this.category});

  final String title;
  final String amountFormatted;
  final DateTime occurredAt;
  final String category;

  factory BillOut.fromJson(Map<String, dynamic> json) => BillOut(
    title: json['title'] as String,
    amountFormatted: json['amount_formatted'] as String,
    occurredAt: DateTime.parse(json['occurred_at'] as String),
    category: json['category'] as String,
  );
}

class BillsResponse {
  BillsResponse({required this.recentBills});
  final List<BillOut> recentBills;

  factory BillsResponse.fromJson(Map<String, dynamic> json) => BillsResponse(
    recentBills: (json['recent_bills'] as List).map((i) => BillOut.fromJson(i as Map<String, dynamic>)).toList(),
  );
}

class BillsApi {
  BillsApi(this._client);
  final ApiClient _client;

  Future<BillsResponse> getBills(String userId) async {
    final json = await _client.get('/bills/$userId');
    return BillsResponse.fromJson(json);
  }
}

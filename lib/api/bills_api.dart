import 'api_client.dart';

class BillOut {
  final String title;
  final String amount;
  final String date;
  final String icon;
  final String color;

  BillOut({
    required this.title,
    required this.amount,
    required this.date,
    required this.icon,
    required this.color,
  });

  factory BillOut.fromJson(Map<String, dynamic> json) {
    return BillOut(
      title: json['title'] as String,
      amount: json['amount'] as String,
      date: json['date'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
    );
  }
}

class BillsResponse {
  final List<BillOut> recentBills;

  BillsResponse({
    required this.recentBills,
  });

  factory BillsResponse.fromJson(Map<String, dynamic> json) {
    return BillsResponse(
      recentBills: (json['recent_bills'] as List).map((i) => BillOut.fromJson(i as Map<String, dynamic>)).toList(),
    );
  }
}

class BillsApi {
  final ApiClient _client;

  BillsApi(this._client);

  Future<BillsResponse> getBills(String userId) async {
    final json = await _client.get('/bills/$userId');
    return BillsResponse.fromJson(json);
  }
}

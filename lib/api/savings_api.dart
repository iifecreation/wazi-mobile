import 'api_client.dart';

class SavingsGoalOut {
  final String title;
  final String current;
  final String target;
  final double progress;
  final String color;
  final String icon;

  SavingsGoalOut({
    required this.title,
    required this.current,
    required this.target,
    required this.progress,
    required this.color,
    required this.icon,
  });

  factory SavingsGoalOut.fromJson(Map<String, dynamic> json) {
    return SavingsGoalOut(
      title: json['title'] as String,
      current: json['current'] as String,
      target: json['target'] as String,
      progress: (json['progress'] as num).toDouble(),
      color: json['color'] as String,
      icon: json['icon'] as String,
    );
  }
}

class SavingsResponse {
  final String totalSavings;
  final String interestEarned;
  final List<SavingsGoalOut> goals;

  SavingsResponse({
    required this.totalSavings,
    required this.interestEarned,
    required this.goals,
  });

  factory SavingsResponse.fromJson(Map<String, dynamic> json) {
    return SavingsResponse(
      totalSavings: json['total_savings'] as String,
      interestEarned: json['interest_earned'] as String,
      goals: (json['goals'] as List).map((i) => SavingsGoalOut.fromJson(i as Map<String, dynamic>)).toList(),
    );
  }
}

class SavingsApi {
  final ApiClient _client;

  SavingsApi(this._client);

  Future<SavingsResponse> getSavings(String userId) async {
    final json = await _client.get('/savings/$userId');
    return SavingsResponse.fromJson(json);
  }
}

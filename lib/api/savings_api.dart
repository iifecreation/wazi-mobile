import 'api_client.dart';

/// Mirrors app/savings/schemas.py::SavingsGoalOut. Real per-user state —
/// deposits/withdrawals move real money against the main Naira account.
class SavingsGoalOut {
  SavingsGoalOut({
    required this.goalId,
    required this.title,
    required this.savedMinor,
    required this.savedFormatted,
    required this.targetMinor,
    required this.targetFormatted,
    required this.progress,
  });

  final String goalId;
  final String title;
  final int savedMinor;
  final String savedFormatted;
  final int? targetMinor;
  final String? targetFormatted;
  final double? progress;

  factory SavingsGoalOut.fromJson(Map<String, dynamic> json) => SavingsGoalOut(
    goalId: json['goal_id'] as String,
    title: json['title'] as String,
    savedMinor: json['saved_minor'] as int,
    savedFormatted: json['saved_formatted'] as String,
    targetMinor: json['target_minor'] as int?,
    targetFormatted: json['target_formatted'] as String?,
    progress: (json['progress'] as num?)?.toDouble(),
  );
}

/// Mirrors app/savings/schemas.py::SavingsResponse.
class SavingsResponse {
  SavingsResponse({
    required this.totalSavedMinor,
    required this.totalSavedFormatted,
    required this.interestEarnedFormatted,
    required this.goals,
  });

  final int totalSavedMinor;
  final String totalSavedFormatted;
  final String interestEarnedFormatted;
  final List<SavingsGoalOut> goals;

  factory SavingsResponse.fromJson(Map<String, dynamic> json) => SavingsResponse(
    totalSavedMinor: json['total_saved_minor'] as int,
    totalSavedFormatted: json['total_saved_formatted'] as String,
    interestEarnedFormatted: json['interest_earned_formatted'] as String,
    goals: (json['goals'] as List).map((i) => SavingsGoalOut.fromJson(i as Map<String, dynamic>)).toList(),
  );
}

class SavingsApi {
  SavingsApi(this._client);
  final ApiClient _client;

  Future<SavingsResponse> getSavings(String userId) async {
    final json = await _client.get('/savings/$userId');
    return SavingsResponse.fromJson(json);
  }

  Future<SavingsGoalOut> createGoal(String userId, String title, {int? targetMinor}) async {
    final json = await _client.post('/savings/$userId/goals', {
      'title': title,
      if (targetMinor != null) 'target_minor': targetMinor,
    });
    return SavingsGoalOut.fromJson(json);
  }

  Future<SavingsGoalOut> deposit(String userId, int amountMinor, {String? goalId}) async {
    final json = await _client.post('/savings/$userId/deposit', {
      'amount_minor': amountMinor,
      if (goalId != null) 'goal_id': goalId,
    });
    return SavingsGoalOut.fromJson(json);
  }

  Future<SavingsGoalOut> withdraw(String userId, int amountMinor, {String? goalId}) async {
    final json = await _client.post('/savings/$userId/withdraw', {
      'amount_minor': amountMinor,
      if (goalId != null) 'goal_id': goalId,
    });
    return SavingsGoalOut.fromJson(json);
  }
}

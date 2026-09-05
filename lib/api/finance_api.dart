import 'api_client.dart';

/// Mirrors app/finance/schemas.py::FinanceCategoryOut — this month's real
/// spend breakdown (same categorizer as Insights' spend-summary).
class FinanceCategoryOut {
  FinanceCategoryOut({required this.title, required this.amountFormatted, required this.percent});

  final String title;
  final String amountFormatted;
  final double percent;

  factory FinanceCategoryOut.fromJson(Map<String, dynamic> json) => FinanceCategoryOut(
    title: json['title'] as String,
    amountFormatted: json['amount_formatted'] as String,
    percent: (json['percent'] as num).toDouble(),
  );
}

/// Mirrors app/finance/schemas.py::FinanceGoalOut — real savings goals
/// (app/savings/), not a separate fake goal list.
class FinanceGoalOut {
  FinanceGoalOut({
    required this.goalId,
    required this.title,
    required this.currentFormatted,
    required this.targetFormatted,
    required this.progress,
  });

  final String goalId;
  final String title;
  final String currentFormatted;
  final String? targetFormatted;
  final double? progress;

  factory FinanceGoalOut.fromJson(Map<String, dynamic> json) => FinanceGoalOut(
    goalId: json['goal_id'] as String,
    title: json['title'] as String,
    currentFormatted: json['current_formatted'] as String,
    targetFormatted: json['target_formatted'] as String?,
    progress: (json['progress'] as num?)?.toDouble(),
  );
}

/// Mirrors app/finance/schemas.py::FinanceResponse.
class FinanceResponse {
  FinanceResponse({required this.incomeFormatted, required this.spentFormatted, required this.categories, required this.goals});

  final String incomeFormatted;
  final String spentFormatted;
  final List<FinanceCategoryOut> categories;
  final List<FinanceGoalOut> goals;

  factory FinanceResponse.fromJson(Map<String, dynamic> json) => FinanceResponse(
    incomeFormatted: json['income_formatted'] as String,
    spentFormatted: json['spent_formatted'] as String,
    categories: (json['categories'] as List).map((i) => FinanceCategoryOut.fromJson(i as Map<String, dynamic>)).toList(),
    goals: (json['goals'] as List).map((i) => FinanceGoalOut.fromJson(i as Map<String, dynamic>)).toList(),
  );
}

class FinanceApi {
  FinanceApi(this._client);
  final ApiClient _client;

  Future<FinanceResponse> getFinance(String userId) async {
    final json = await _client.get('/finance/$userId');
    return FinanceResponse.fromJson(json);
  }
}

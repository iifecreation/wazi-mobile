import 'api_client.dart';

class FinanceCategoryOut {
  final String title;
  final String amount;
  final double percent;
  final String color;

  FinanceCategoryOut({
    required this.title,
    required this.amount,
    required this.percent,
    required this.color,
  });

  factory FinanceCategoryOut.fromJson(Map<String, dynamic> json) {
    return FinanceCategoryOut(
      title: json['title'] as String,
      amount: json['amount'] as String,
      percent: (json['percent'] as num).toDouble(),
      color: json['color'] as String,
    );
  }
}

class FinanceGoalOut {
  final String title;
  final String current;
  final String target;
  final double progress;

  FinanceGoalOut({
    required this.title,
    required this.current,
    required this.target,
    required this.progress,
  });

  factory FinanceGoalOut.fromJson(Map<String, dynamic> json) {
    return FinanceGoalOut(
      title: json['title'] as String,
      current: json['current'] as String,
      target: json['target'] as String,
      progress: (json['progress'] as num).toDouble(),
    );
  }
}

class FinanceResponse {
  final String income;
  final String spent;
  final List<FinanceCategoryOut> categories;
  final List<FinanceGoalOut> goals;

  FinanceResponse({
    required this.income,
    required this.spent,
    required this.categories,
    required this.goals,
  });

  factory FinanceResponse.fromJson(Map<String, dynamic> json) {
    return FinanceResponse(
      income: json['income'] as String,
      spent: json['spent'] as String,
      categories: (json['categories'] as List).map((i) => FinanceCategoryOut.fromJson(i as Map<String, dynamic>)).toList(),
      goals: (json['goals'] as List).map((i) => FinanceGoalOut.fromJson(i as Map<String, dynamic>)).toList(),
    );
  }
}

class FinanceApi {
  final ApiClient _client;

  FinanceApi(this._client);

  Future<FinanceResponse> getFinance(String userId) async {
    final json = await _client.get('/finance/$userId');
    return FinanceResponse.fromJson(json);
  }
}

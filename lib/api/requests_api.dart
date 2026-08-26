import 'api_client.dart';

/// Mirrors app/requests/schemas.py::MoneyRequestOut. Inbound contextual
/// voice requests — someone else spoke "I need X from [you] for Y, due Z"
/// and it landed here as a structured, approvable item instead of a
/// WhatsApp voice note.
class MoneyRequestOut {
  MoneyRequestOut({
    required this.requestId,
    required this.requesterUserId,
    required this.payerUserId,
    required this.payerName,
    required this.amountFormatted,
    required this.reason,
    required this.deadline,
    required this.status,
    required this.createdAt,
    required this.newBalanceFormatted,
  });

  final String requestId;
  final String requesterUserId;
  final String payerUserId;
  final String payerName;
  final String amountFormatted;
  final String reason;
  final String? deadline;
  final String status;
  final DateTime createdAt;
  final String? newBalanceFormatted;

  factory MoneyRequestOut.fromJson(Map<String, dynamic> json) => MoneyRequestOut(
    requestId: json['request_id'] as String,
    requesterUserId: json['requester_user_id'] as String,
    payerUserId: json['payer_user_id'] as String,
    payerName: json['payer_name'] as String,
    amountFormatted: json['amount_formatted'] as String,
    reason: json['reason'] as String,
    deadline: json['deadline'] as String?,
    status: json['status'] as String,
    createdAt: DateTime.parse(json['created_at'] as String),
    newBalanceFormatted: json['new_balance_formatted'] as String?,
  );
}

class RequestsApi {
  RequestsApi(this._client);

  final ApiClient _client;

  /// Requests waiting for `userId` to approve/decline.
  Future<List<MoneyRequestOut>> getInbox(String userId) async {
    final json = await _client.get('/requests/$userId/inbox');
    return (json['requests'] as List).map((e) => MoneyRequestOut.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Requests `userId` has asked for, with their current status.
  Future<List<MoneyRequestOut>> getSent(String userId) async {
    final json = await _client.get('/requests/$userId/sent');
    return (json['requests'] as List).map((e) => MoneyRequestOut.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<MoneyRequestOut> approve(String requestId, String userId, String pin) async {
    final json = await _client.post('/requests/$requestId/approve', {'user_id': userId, 'pin': pin});
    return MoneyRequestOut.fromJson(json['request'] as Map<String, dynamic>);
  }

  Future<MoneyRequestOut> decline(String requestId, String userId) async {
    final json = await _client.post('/requests/$requestId/decline', {'user_id': userId});
    return MoneyRequestOut.fromJson(json);
  }
}

import 'api_client.dart';

class SupportTicket {
  SupportTicket({
    required this.ticketId,
    required this.subject,
    required this.message,
    required this.category,
    required this.status,
    required this.autoReply,
    required this.createdAt,
  });
  final String ticketId;
  final String subject;
  final String message;
  final String category;
  final String status;
  final String autoReply;
  final DateTime createdAt;

  factory SupportTicket.fromJson(Map<String, dynamic> json) => SupportTicket(
    ticketId: json['ticket_id'] as String,
    subject: json['subject'] as String,
    message: json['message'] as String,
    category: json['category'] as String? ?? 'general',
    status: json['status'] as String? ?? 'open',
    autoReply: json['auto_reply'] as String? ?? '',
    createdAt: DateTime.parse(json['created_at'] as String),
  );
}

class SupportApi {
  SupportApi(this._client);
  final ApiClient _client;

  Future<SupportTicket> createTicket({
    required String userId,
    required String subject,
    required String message,
    String category = 'general',
  }) async {
    final json = await _client.post('/support', {
      'user_id': userId,
      'subject': subject,
      'message': message,
      'category': category,
    });
    return SupportTicket.fromJson(json);
  }

  Future<List<SupportTicket>> listTickets(String userId) async {
    final json = await _client.get('/support/$userId');
    return (json['tickets'] as List)
        .map((e) => SupportTicket.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

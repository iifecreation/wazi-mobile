import 'api_client.dart';

class NotificationOut {
  NotificationOut({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    required this.type,
    required this.unread,
  });

  final String id;
  final String title;
  final String body;
  final String time;
  final String type;
  final bool unread;

  factory NotificationOut.fromJson(Map<String, dynamic> json) => NotificationOut(
        id: json['id'] as String,
        title: json['title'] as String,
        body: json['body'] as String,
        time: json['time'] as String,
        type: json['type'] as String,
        unread: json['unread'] as bool,
      );
}

class NotificationListResponse {
  NotificationListResponse({required this.notifications});

  final List<NotificationOut> notifications;

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) =>
      NotificationListResponse(
        notifications: (json['notifications'] as List)
            .map((e) => NotificationOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class NotificationsApi {
  NotificationsApi(this._client);

  final ApiClient _client;

  Future<NotificationListResponse> getNotifications(String userId) async {
    final json = await _client.get('/notifications/$userId');
    return NotificationListResponse.fromJson(json);
  }
}

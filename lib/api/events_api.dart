import 'api_client.dart';

class EventOut {
  EventOut({
    required this.eventId,
    required this.title,
    required this.category,
    required this.date,
    required this.location,
    required this.priceMinor,
    required this.priceFormatted,
    required this.available,
  });
  final String eventId;
  final String title;
  final String category;
  final String date;
  final String location;
  final int priceMinor;
  final String priceFormatted;
  final bool available;

  factory EventOut.fromJson(Map<String, dynamic> json) => EventOut(
    eventId: json['event_id'] as String,
    title: json['title'] as String,
    category: json['category'] as String,
    date: json['date'] as String,
    location: json['location'] as String,
    priceMinor: json['price_minor'] as int,
    priceFormatted: json['price_formatted'] as String,
    available: json['available'] as bool? ?? true,
  );
}

class TicketPurchaseResult {
  TicketPurchaseResult({
    required this.purchaseId,
    required this.eventTitle,
    required this.quantity,
    required this.totalFormatted,
    required this.status,
  });
  final String purchaseId;
  final String eventTitle;
  final int quantity;
  final String totalFormatted;
  final String status;

  factory TicketPurchaseResult.fromJson(Map<String, dynamic> json) =>
      TicketPurchaseResult(
        purchaseId: json['purchase_id'] as String,
        eventTitle: json['event_title'] as String,
        quantity: json['quantity'] as int,
        totalFormatted: json['total_formatted'] as String,
        status: json['status'] as String,
      );
}

class EventsApi {
  EventsApi(this._client);
  final ApiClient _client;

  Future<List<EventOut>> listEvents({String? category}) async {
    final json = await _client.get('/events', query: category != null ? {'category': category} : null);
    return (json['events'] as List)
        .map((e) => EventOut.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<TicketPurchaseResult> purchase(String userId, String eventId, int quantity) async {
    final json = await _client.post('/events/$userId/purchase', {
      'event_id': eventId,
      'quantity': quantity,
    });
    return TicketPurchaseResult.fromJson(json);
  }
}

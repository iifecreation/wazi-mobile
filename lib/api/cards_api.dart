import 'api_client.dart';

class CardOut {
  CardOut({
    required this.id,
    required this.type,
    required this.name,
    required this.last4,
    required this.cardholder,
    required this.expires,
    required this.brand,
  });

  final String id;
  final String type;
  final String name;
  final String last4;
  final String cardholder;
  final String expires;
  final String brand;

  factory CardOut.fromJson(Map<String, dynamic> json) => CardOut(
        id: json['id'] as String,
        type: json['type'] as String,
        name: json['name'] as String,
        last4: json['last4'] as String,
        cardholder: json['cardholder'] as String,
        expires: json['expires'] as String,
        brand: json['brand'] as String,
      );
}

class CardListResponse {
  CardListResponse({required this.cards});

  final List<CardOut> cards;

  factory CardListResponse.fromJson(Map<String, dynamic> json) => CardListResponse(
        cards: (json['cards'] as List)
            .map((e) => CardOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CardTransactionOut {
  CardTransactionOut({
    required this.id,
    required this.title,
    required this.date,
    required this.amount,
    required this.icon,
  });

  final String id;
  final String title;
  final String date;
  final String amount;
  final String icon;

  factory CardTransactionOut.fromJson(Map<String, dynamic> json) => CardTransactionOut(
        id: json['id'] as String,
        title: json['title'] as String,
        date: json['date'] as String,
        amount: json['amount'] as String,
        icon: json['icon'] as String,
      );
}

class CardActivityResponse {
  CardActivityResponse({required this.transactions});

  final List<CardTransactionOut> transactions;

  factory CardActivityResponse.fromJson(Map<String, dynamic> json) =>
      CardActivityResponse(
        transactions: (json['transactions'] as List)
            .map((e) => CardTransactionOut.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class CardsApi {
  CardsApi(this._client);

  final ApiClient _client;

  Future<CardListResponse> getCards(String userId) async {
    final json = await _client.get('/cards/$userId');
    return CardListResponse.fromJson(json);
  }

  Future<CardActivityResponse> getCardActivity(String userId) async {
    final json = await _client.get('/cards/$userId/activity');
    return CardActivityResponse.fromJson(json);
  }
}

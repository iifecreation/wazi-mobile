import 'api_client.dart';
import 'accounts_api.dart' show TransactionOut;

/// Mirrors app/cards/schemas.py::CardOut. Real per-user state — one
/// virtual card is auto-issued the first time this is fetched.
class CardOut {
  CardOut({
    required this.cardId,
    required this.brand,
    required this.last4,
    required this.cardholderName,
    required this.isFrozen,
    required this.expiresDisplay,
  });

  final String cardId;
  final String brand;
  final String last4;
  final String cardholderName;
  final bool isFrozen;
  final String expiresDisplay;

  factory CardOut.fromJson(Map<String, dynamic> json) => CardOut(
    cardId: json['card_id'] as String,
    brand: json['brand'] as String,
    last4: json['last4'] as String,
    cardholderName: json['cardholder_name'] as String,
    isFrozen: json['is_frozen'] as bool,
    expiresDisplay: json['expires_display'] as String,
  );
}

class CardListResponse {
  CardListResponse({required this.cards});
  final List<CardOut> cards;

  factory CardListResponse.fromJson(Map<String, dynamic> json) => CardListResponse(
    cards: (json['cards'] as List).map((e) => CardOut.fromJson(e as Map<String, dynamic>)).toList(),
  );
}

/// Mirrors app/cards/schemas.py::CardActivityResponse — the user's real
/// recent transactions (app/baas/), not a second fake ledger.
class CardActivityResponse {
  CardActivityResponse({required this.transactions});
  final List<TransactionOut> transactions;

  factory CardActivityResponse.fromJson(Map<String, dynamic> json) => CardActivityResponse(
    transactions: (json['transactions'] as List).map((e) => TransactionOut.fromJson(e as Map<String, dynamic>)).toList(),
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

  Future<CardOut> freeze(String userId, String cardId) async {
    final json = await _client.post('/cards/$userId/$cardId/freeze', {});
    return CardOut.fromJson(json);
  }

  Future<CardOut> unfreeze(String userId, String cardId) async {
    final json = await _client.post('/cards/$userId/$cardId/unfreeze', {});
    return CardOut.fromJson(json);
  }
}

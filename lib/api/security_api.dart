import 'api_client.dart';

/// Mirrors app/security/duress_schemas.py::DuressStatusResponse. Setup-only
/// endpoints — the duress PIN itself is never sent here during a real
/// payment, only through the same submit-PIN call a real PIN would use
/// (see PaymentsApi). That's the whole point: nothing about how a duress
/// PIN gets used looks different from a normal one.
class DuressStatus {
  DuressStatus({required this.hasDuressPin, required this.hasTrustedContact, required this.accountFrozen});

  final bool hasDuressPin;
  final bool hasTrustedContact;
  final bool accountFrozen;

  factory DuressStatus.fromJson(Map<String, dynamic> json) => DuressStatus(
    hasDuressPin: json['has_duress_pin'] as bool,
    hasTrustedContact: json['has_trusted_contact'] as bool,
    accountFrozen: json['account_frozen'] as bool,
  );
}

class SecurityApi {
  SecurityApi(this._client);

  final ApiClient _client;

  Future<DuressStatus> getStatus(String userId) async {
    final json = await _client.get('/security/$userId/status');
    return DuressStatus.fromJson(json);
  }

  Future<DuressStatus> setDuressPin(String userId, String pin) async {
    final json = await _client.post('/security/$userId/duress-pin', {'pin': pin});
    return DuressStatus.fromJson(json);
  }

  Future<DuressStatus> setTrustedContact(String userId, String name, String phoneNumber) async {
    final json = await _client.post('/security/$userId/trusted-contact', {'name': name, 'phone_number': phoneNumber});
    return DuressStatus.fromJson(json);
  }
}

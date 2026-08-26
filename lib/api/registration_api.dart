import 'api_client.dart';

/// Mirrors app/registration/schemas.py::TierLimitsOut.
class TierLimits {
  TierLimits({required this.dailyLimitFormatted, required this.maxBalanceFormatted});

  final String dailyLimitFormatted;
  final String? maxBalanceFormatted;

  factory TierLimits.fromJson(Map<String, dynamic> json) => TierLimits(
    dailyLimitFormatted: json['daily_limit_formatted'] as String,
    maxBalanceFormatted: json['max_balance_formatted'] as String?,
  );
}

/// Mirrors app/registration/schemas.py::RegistrationStatusResponse.
class RegistrationStatus {
  RegistrationStatus({
    required this.userId,
    required this.phoneNumber,
    required this.tier,
    required this.bvnVerified,
    required this.ninVerified,
    required this.addressVerified,
    required this.faceVerified,
    required this.limits,
    required this.nextStep,
  });

  final String userId;
  final String phoneNumber;
  final int tier;
  final bool bvnVerified;
  final bool ninVerified;
  final bool addressVerified;
  final bool faceVerified;
  final TierLimits limits;
  final String? nextStep;

  factory RegistrationStatus.fromJson(Map<String, dynamic> json) => RegistrationStatus(
    userId: json['user_id'] as String,
    phoneNumber: json['phone_number'] as String,
    tier: json['tier'] as int,
    bvnVerified: json['bvn_verified'] as bool,
    ninVerified: json['nin_verified'] as bool,
    addressVerified: json['address_verified'] as bool,
    faceVerified: json['face_verified'] as bool,
    limits: TierLimits.fromJson(json['limits'] as Map<String, dynamic>),
    nextStep: json['next_step'] as String?,
  );
}

class RegistrationApi {
  RegistrationApi(this._client);

  final ApiClient _client;

  Future<RegistrationStatus> register(String phoneNumber, String pin) async {
    final json = await _client.post('/registration/register', {'phone_number': phoneNumber, 'pin': pin});
    return RegistrationStatus.fromJson(json);
  }

  Future<RegistrationStatus> login(String phoneNumber, String pin) async {
    final json = await _client.post('/registration/login', {'phone_number': phoneNumber, 'pin': pin});
    return RegistrationStatus.fromJson(json);
  }

  Future<RegistrationStatus> getStatus(String userId) async {
    final json = await _client.get('/registration/$userId/status');
    return RegistrationStatus.fromJson(json);
  }

  Future<RegistrationStatus> submitBvn(String userId, String bvn) async {
    final json = await _client.post('/registration/$userId/kyc/bvn', {'bvn': bvn});
    return RegistrationStatus.fromJson(json);
  }

  Future<RegistrationStatus> submitNin(String userId, String nin) async {
    final json = await _client.post('/registration/$userId/kyc/nin', {'nin': nin});
    return RegistrationStatus.fromJson(json);
  }

  Future<RegistrationStatus> submitAddress(String userId, String documentRef) async {
    final json = await _client.post('/registration/$userId/kyc/address', {'document_ref': documentRef});
    return RegistrationStatus.fromJson(json);
  }

  Future<RegistrationStatus> submitFace(String userId, String faceSampleId) async {
    final json = await _client.post('/registration/$userId/kyc/face', {'face_sample_id': faceSampleId});
    return RegistrationStatus.fromJson(json);
  }
}

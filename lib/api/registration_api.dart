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
    this.country,
    this.email,
    this.emailVerified = false,
    this.firstName,
    this.lastName,
    this.otherName,
    this.dob,
    this.gender,
    this.voiceEnrolled = false,
    this.pinSetup = false,
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
  final String? country;
  final String? email;
  final bool emailVerified;
  final String? firstName;
  final String? lastName;
  final String? otherName;
  final String? dob;
  final String? gender;
  final bool voiceEnrolled;
  final bool pinSetup;
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
    country: json['country'] as String?,
    email: json['email'] as String?,
    emailVerified: json['email_verified'] as bool? ?? false,
    firstName: json['first_name'] as String?,
    lastName: json['last_name'] as String?,
    otherName: json['other_name'] as String?,
    dob: json['dob'] as String?,
    gender: json['gender'] as String?,
    voiceEnrolled: json['voice_enrolled'] as bool? ?? false,
    pinSetup: json['pin_setup'] as bool? ?? false,
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

  // Keep this for legacy / login compatibility
  Future<RegistrationStatus> register(String phoneNumber, String pin) async {
    final res = await _client.post('/registration/register', {'phone_number': phoneNumber, 'pin': pin});
    return RegistrationStatus.fromJson(res);
  }

  Future<RegistrationStatus> login(String phoneNumber, String password) async {
    final res = await _client.post('/registration/login', {'phone_number': phoneNumber, 'password': password});
    return RegistrationStatus.fromJson(res);
  }

  Future<RegistrationStatus> getStatus(String userId) async {
    final res = await _client.get('/registration/$userId/status');
    return RegistrationStatus.fromJson(res);
  }

  /// Requires the *current* password — unlike register()'s pin, which has
  /// nothing to check yet. See app/registration/service.py::change_password.
  Future<RegistrationStatus> changePassword(String userId, String oldPassword, String newPassword) async {
    final res = await _client.post('/registration/$userId/change-password', {
      'old_password': oldPassword,
      'new_password': newPassword,
    });
    return RegistrationStatus.fromJson(res);
  }

  Future<RegistrationStatus> changeTransactionPin(String userId, String oldPin, String newPin) async {
    final res = await _client.post('/registration/$userId/change-pin', {'old_pin': oldPin, 'new_pin': newPin});
    return RegistrationStatus.fromJson(res);
  }

  /// Mocked exactly like every other OTP step in this backend — no real
  /// SMS is sent, and forgotPasswordReset() below accepts any well-formed
  /// code.
  Future<void> forgotPasswordStart(String phoneNumber) async {
    await _client.post('/registration/forgot-password/start', {'phone_number': phoneNumber});
  }

  Future<RegistrationStatus> forgotPasswordReset(String phoneNumber, String otp, String newPassword) async {
    final res = await _client.post('/registration/forgot-password/reset', {
      'phone_number': phoneNumber,
      'otp': otp,
      'new_password': newPassword,
    });
    return RegistrationStatus.fromJson(res);
  }

  // --- Multi-step Registration Flow ---

  Future<void> startPhone(String phoneNumber) async {
    await _client.post('/registration/phone/start', {'phone_number': phoneNumber});
  }

  Future<RegistrationStatus> verifyPhone(String phoneNumber, String otp) async {
    final res = await _client.post('/registration/phone/verify', {'phone_number': phoneNumber, 'otp': otp});
    return RegistrationStatus.fromJson(res);
  }

  Future<RegistrationStatus> submitCountry(String userId, String country) async {
    final res = await _client.post('/registration/$userId/country', {'country': country});
    return RegistrationStatus.fromJson(res);
  }

  Future<void> startEmail(String userId, String email) async {
    await _client.post('/registration/$userId/email/start', {'email': email});
  }

  Future<RegistrationStatus> verifyEmail(String userId, String email, String otp) async {
    final res = await _client.post('/registration/$userId/email/verify', {'email': email, 'otp': otp});
    return RegistrationStatus.fromJson(res);
  }

  Future<RegistrationStatus> submitPassword(String userId, String password) async {
    final res = await _client.post('/registration/$userId/password', {'password': password});
    return RegistrationStatus.fromJson(res);
  }

  Future<RegistrationStatus> submitProfileDetails(String userId, String firstName, String lastName, String? otherName, String dob, String gender) async {
    final res = await _client.post('/registration/$userId/profile', {
      'first_name': firstName,
      'last_name': lastName,
      'other_name': otherName,
      'dob': dob,
      'gender': gender,
    });
    return RegistrationStatus.fromJson(res);
  }

  Future<RegistrationStatus> submitVoice(String userId, String voiceSampleId) async {
    final res = await _client.post('/registration/$userId/kyc/voice', {'voice_sample_id': voiceSampleId});
    return RegistrationStatus.fromJson(res);
  }

  Future<RegistrationStatus> submitTransactionPin(String userId, String pin) async {
    final res = await _client.post('/registration/$userId/transaction_pin', {'pin': pin});
    return RegistrationStatus.fromJson(res);
  }

  // --- KYC Steps ---

  Future<RegistrationStatus> submitBvn(String userId, String bvn) async {
    final res = await _client.post('/registration/$userId/kyc/bvn', {'bvn': bvn});
    return RegistrationStatus.fromJson(res);
  }

  Future<RegistrationStatus> submitNin(String userId, String nin) async {
    final res = await _client.post('/registration/$userId/kyc/nin', {'nin': nin});
    return RegistrationStatus.fromJson(res);
  }

  Future<RegistrationStatus> submitAddress(String userId, String documentRef) async {
    final res = await _client.post('/registration/$userId/kyc/address', {'document_ref': documentRef});
    return RegistrationStatus.fromJson(res);
  }

  Future<RegistrationStatus> submitFace(String userId, String faceSampleId) async {
    final res = await _client.post('/registration/$userId/kyc/face', {'face_sample_id': faceSampleId});
    return RegistrationStatus.fromJson(res);
  }
}

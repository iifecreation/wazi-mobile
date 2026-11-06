import 'api_client.dart';

// ── Flights ───────────────────────────────────────────────────────────────

class FlightOut {
  FlightOut({
    required this.flightId, required this.airline,
    required this.fromCode, required this.fromCity,
    required this.toCode, required this.toCity,
    required this.departTime, required this.arriveTime, required this.duration,
    required this.priceFormatted, required this.stops,
  });
  final String flightId, airline, fromCode, fromCity, toCode, toCity;
  final String departTime, arriveTime, duration, priceFormatted;
  final int stops;

  factory FlightOut.fromJson(Map<String, dynamic> j) => FlightOut(
    flightId: j['flight_id'] as String, airline: j['airline'] as String,
    fromCode: j['from_code'] as String, fromCity: j['from_city'] as String,
    toCode: j['to_code'] as String, toCity: j['to_city'] as String,
    departTime: j['depart_time'] as String, arriveTime: j['arrive_time'] as String,
    duration: j['duration'] as String, priceFormatted: j['price_formatted'] as String,
    stops: j['stops'] as int? ?? 0,
  );
}

// ── Hotels ─────────────────────────────────────────────────────────────────

class HotelOut {
  HotelOut({
    required this.hotelId, required this.name, required this.city,
    required this.starRating, required this.priceFormatted, required this.amenities,
  });
  final String hotelId, name, city, priceFormatted;
  final int starRating;
  final List<String> amenities;

  factory HotelOut.fromJson(Map<String, dynamic> j) => HotelOut(
    hotelId: j['hotel_id'] as String, name: j['name'] as String, city: j['city'] as String,
    starRating: j['star_rating'] as int? ?? 4, priceFormatted: j['price_formatted'] as String,
    amenities: (j['amenities'] as List?)?.cast<String>() ?? [],
  );
}

// ── Booking ───────────────────────────────────────────────────────────────

class BookingResult {
  BookingResult({required this.bookingId, required this.route, required this.priceFormatted, required this.status});
  final String bookingId, route, priceFormatted, status;
  factory BookingResult.fromJson(Map<String, dynamic> j) => BookingResult(
    bookingId: j['booking_id'] as String, route: j['route'] as String,
    priceFormatted: j['price_formatted'] as String, status: j['status'] as String? ?? 'confirmed',
  );
}

// ── USSD ──────────────────────────────────────────────────────────────────

class UssdInfo {
  UssdInfo({required this.balanceCheck, required this.transfer, required this.airtime, required this.miniStatement, required this.defaultCode, required this.note});
  final String balanceCheck, transfer, airtime, miniStatement, defaultCode, note;
  factory UssdInfo.fromJson(Map<String, dynamic> j) => UssdInfo(
    balanceCheck: j['balance_check'] as String, transfer: j['transfer'] as String,
    airtime: j['airtime'] as String, miniStatement: j['mini_statement'] as String,
    defaultCode: j['default_code'] as String, note: j['note'] as String,
  );
}

// ── Referral ──────────────────────────────────────────────────────────────

class ReferralInfo {
  ReferralInfo({required this.referralCode, required this.referralLink, required this.bonusAmountFormatted, required this.totalInvited, required this.totalEarnedFormatted});
  final String referralCode, referralLink, bonusAmountFormatted, totalEarnedFormatted;
  final int totalInvited;
  factory ReferralInfo.fromJson(Map<String, dynamic> j) => ReferralInfo(
    referralCode: j['referral_code'] as String, referralLink: j['referral_link'] as String,
    bonusAmountFormatted: j['bonus_amount_formatted'] as String, totalInvited: j['total_invited'] as int? ?? 0,
    totalEarnedFormatted: j['total_earned_formatted'] as String,
  );
}

// ── Merchant ──────────────────────────────────────────────────────────────

class MerchantInfo {
  MerchantInfo({required this.merchantId, required this.businessName, required this.qrCode, required this.isActive});
  final String merchantId, businessName, qrCode;
  final bool isActive;
  factory MerchantInfo.fromJson(Map<String, dynamic> j) => MerchantInfo(
    merchantId: j['merchant_id'] as String, businessName: j['business_name'] as String,
    qrCode: j['qr_code'] as String, isActive: j['is_active'] as bool? ?? true,
  );
}

// ── Junior ────────────────────────────────────────────────────────────────

class JuniorAccountOut {
  JuniorAccountOut({required this.juniorId, required this.childName, required this.childDob, required this.accountNumber, required this.balanceFormatted, required this.weeklyAllowanceFormatted, required this.cardFrozen});
  final String juniorId, childName, childDob, accountNumber, balanceFormatted, weeklyAllowanceFormatted;
  final bool cardFrozen;
  factory JuniorAccountOut.fromJson(Map<String, dynamic> j) => JuniorAccountOut(
    juniorId: j['junior_id'] as String, childName: j['child_name'] as String,
    childDob: j['child_dob'] as String, accountNumber: j['account_number'] as String,
    balanceFormatted: j['balance_formatted'] as String, weeklyAllowanceFormatted: j['weekly_allowance_formatted'] as String,
    cardFrozen: j['card_frozen'] as bool? ?? false,
  );
}

// ── API ───────────────────────────────────────────────────────────────────

class LifestyleApi {
  LifestyleApi(this._client);
  final ApiClient _client;

  Future<List<FlightOut>> searchFlights({String? fromCode, String? toCode}) async {
    final json = await _client.get('/lifestyle/flights/search', query: {
      if (fromCode != null) 'from_code': fromCode, if (toCode != null) 'to_code': toCode,
    });
    return (json['flights'] as List).map((e) => FlightOut.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BookingResult> bookFlight(String userId, String flightId) async {
    final json = await _client.post('/lifestyle/flights/$userId/book', {'flight_id': flightId});
    return BookingResult.fromJson(json);
  }

  Future<List<HotelOut>> searchHotels({String? city}) async {
    final json = await _client.get('/lifestyle/hotels/search', query: city != null ? {'city': city} : null);
    return (json['hotels'] as List).map((e) => HotelOut.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<BookingResult> bookHotel(String userId, String hotelId, int nights) async {
    final json = await _client.post('/lifestyle/hotels/$userId/book', {'hotel_id': hotelId, 'nights': nights});
    return BookingResult.fromJson(json);
  }

  Future<UssdInfo> getUssd(String userId) async {
    final json = await _client.get('/lifestyle/$userId/ussd');
    return UssdInfo.fromJson(json);
  }

  Future<ReferralInfo> getReferral(String userId) async {
    final json = await _client.get('/lifestyle/$userId/referral');
    return ReferralInfo.fromJson(json);
  }

  Future<MerchantInfo> upgradeToMerchant(String userId, String businessName) async {
    final json = await _client.post('/lifestyle/$userId/merchant', {'business_name': businessName});
    return MerchantInfo.fromJson(json);
  }

  Future<MerchantInfo> getMerchant(String userId) async {
    final json = await _client.get('/lifestyle/$userId/merchant');
    return MerchantInfo.fromJson(json);
  }

  Future<JuniorAccountOut> createJuniorAccount(String userId, String childName, String childDob, {int weeklyAllowanceMinor = 0}) async {
    final json = await _client.post('/lifestyle/$userId/junior', {
      'child_name': childName, 'child_dob': childDob, 'weekly_allowance_minor': weeklyAllowanceMinor,
    });
    return JuniorAccountOut.fromJson(json);
  }

  Future<List<JuniorAccountOut>> listJuniorAccounts(String userId) async {
    final json = await _client.get('/lifestyle/$userId/junior');
    return (json as List).map((e) => JuniorAccountOut.fromJson(e as Map<String, dynamic>)).toList();
  }
}

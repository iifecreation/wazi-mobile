import 'api_client.dart';

/// Mirrors app/transfers/interfaces.py::NIGERIAN_BANKS.
class BankInfo {
  BankInfo({required this.code, required this.name});
  final String code;
  final String name;

  factory BankInfo.fromJson(Map<String, dynamic> json) =>
      BankInfo(code: json['code'] as String, name: json['name'] as String);
}

/// Mirrors app/transfers/schemas.py::NameEnquiryResponse.
class NameEnquiryResponse {
  NameEnquiryResponse({
    required this.accountNumber,
    required this.bankCode,
    required this.bankName,
    required this.beneficiaryName,
  });
  final String accountNumber;
  final String bankCode;
  final String bankName;
  final String beneficiaryName;

  factory NameEnquiryResponse.fromJson(Map<String, dynamic> json) =>
      NameEnquiryResponse(
        accountNumber: json['account_number'] as String,
        bankCode: json['bank_code'] as String,
        bankName: json['bank_name'] as String,
        beneficiaryName: json['beneficiary_name'] as String,
      );
}

/// Mirrors app/transfers/schemas.py::BankTransferOut.
class BankTransferOut {
  BankTransferOut({
    required this.transferId,
    required this.amountMinor,
    required this.amountFormatted,
    required this.feeFormatted,
    required this.bankName,
    required this.accountNumber,
    required this.beneficiaryName,
    required this.narration,
    required this.status,
    required this.createdAt,
  });

  final String transferId;
  final int amountMinor;
  final String amountFormatted;
  final String feeFormatted;
  final String bankName;
  final String accountNumber;
  final String beneficiaryName;
  final String narration;
  final String status;
  final DateTime createdAt;

  factory BankTransferOut.fromJson(Map<String, dynamic> json) =>
      BankTransferOut(
        transferId: json['transfer_id'] as String,
        amountMinor: json['amount_minor'] as int,
        amountFormatted: json['amount_formatted'] as String,
        feeFormatted: json['fee_formatted'] as String,
        bankName: json['bank_name'] as String,
        accountNumber: json['account_number'] as String,
        beneficiaryName: json['beneficiary_name'] as String,
        narration: json['narration'] as String? ?? '',
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

class TransfersApi {
  TransfersApi(this._client);
  final ApiClient _client;

  Future<List<BankInfo>> listBanks() async {
    final json = await _client.get('/transfers/banks');
    return (json['banks'] as List)
        .map((e) => BankInfo.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<NameEnquiryResponse> nameEnquiry({
    required String userId,
    required String accountNumber,
    required String bankCode,
  }) async {
    final json = await _client.get(
      '/transfers/$userId/name-enquiry',
      query: {'account_number': accountNumber, 'bank_code': bankCode},
    );
    return NameEnquiryResponse.fromJson(json);
  }

  Future<BankTransferOut> transfer({
    required String userId,
    required int amountMinor,
    required String bankCode,
    required String accountNumber,
    String narration = 'Transfer',
  }) async {
    final json = await _client.post('/transfers/$userId', {
      'amount_minor': amountMinor,
      'bank_code': bankCode,
      'account_number': accountNumber,
      'narration': narration,
    });
    return BankTransferOut.fromJson(json);
  }

  Future<List<BankTransferOut>> history(String userId) async {
    final json = await _client.get('/transfers/$userId/history');
    return (json['transfers'] as List)
        .map((e) => BankTransferOut.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

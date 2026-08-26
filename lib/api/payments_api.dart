import 'api_client.dart';

/// Mirrors app/payments/schemas.py::PaymentResponse *and*
/// ContactPaymentResponse — they're structurally identical apart from the
/// recipient-name field name (`merchant_name` vs `contact_name`), so this
/// unifies them as `recipientName` for one shared client-side type.
class PaymentResult {
  PaymentResult({
    required this.paymentId,
    required this.status,
    required this.recipientName,
    required this.amountFormatted,
    required this.replyText,
    required this.newBalanceFormatted,
  });

  final String paymentId;
  final String status;
  final String recipientName;
  final String amountFormatted;
  final String replyText;
  final String? newBalanceFormatted;

  factory PaymentResult.fromBarcodeJson(Map<String, dynamic> json) => PaymentResult(
    paymentId: json['payment_id'] as String,
    status: json['status'] as String,
    recipientName: json['merchant_name'] as String,
    amountFormatted: json['amount_formatted'] as String,
    replyText: json['reply_text'] as String,
    newBalanceFormatted: json['new_balance_formatted'] as String?,
  );

  factory PaymentResult.fromContactJson(Map<String, dynamic> json) => PaymentResult(
    paymentId: json['payment_id'] as String,
    status: json['status'] as String,
    recipientName: json['contact_name'] as String,
    amountFormatted: json['amount_formatted'] as String,
    replyText: json['reply_text'] as String,
    newBalanceFormatted: json['new_balance_formatted'] as String?,
  );
}

class PaymentsApi {
  PaymentsApi(this._client);

  final ApiClient _client;

  Future<PaymentResult> scanBarcode(String userId, String barcode) async {
    final json = await _client.post('/payments/barcode/scan', {'user_id': userId, 'barcode': barcode});
    return PaymentResult.fromBarcodeJson(json);
  }

  Future<PaymentResult> confirmBarcode(String paymentId, String userId, String transcript, {String? voiceSampleId}) async {
    final json = await _client.post('/payments/barcode/$paymentId/confirm', {
      'user_id': userId,
      'transcript': transcript,
      if (voiceSampleId != null) 'voice_sample_id': voiceSampleId,
    });
    return PaymentResult.fromBarcodeJson(json);
  }

  Future<PaymentResult> submitBarcodePin(String paymentId, String userId, String pin) async {
    final json = await _client.post('/payments/barcode/$paymentId/pin', {'user_id': userId, 'pin': pin});
    return PaymentResult.fromBarcodeJson(json);
  }

  /// Contact payments are only ever *initiated* and *confirmed* through
  /// `/voice/query` (see VoiceApi + app/payments/contact_router.py's own
  /// docstring on why) — PIN submission is the one REST call this API
  /// needs for that flow.
  Future<PaymentResult> submitContactPin(String paymentId, String userId, String pin) async {
    final json = await _client.post('/payments/contact/$paymentId/pin', {'user_id': userId, 'pin': pin});
    return PaymentResult.fromContactJson(json);
  }
}

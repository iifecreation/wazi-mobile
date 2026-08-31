import 'api_client.dart';

/// POST /voice/transcribe — the "high grade" (noisy-environment-capable)
/// speech-to-text path, when Wazi-server has a Google Cloud Speech-to-Text
/// key configured. The recorded audio never gets a transcript request
/// answered locally; the credential lives server-side on purpose (see
/// app/transcription/ in Wazi-server). Returns a 503-shaped ApiException
/// when the server has no key configured — callers should treat that as
/// "fall back to on-device recognition", not a real error to surface.
class TranscriptionApi {
  TranscriptionApi(this._client);

  final ApiClient _client;

  Future<String> transcribe(List<int> wavBytes, {String languageCode = 'en-NG', int sampleRateHz = 16000}) async {
    final json = await _client.postMultipart(
      '/voice/transcribe',
      fileFieldName: 'audio',
      fileBytes: wavBytes,
      fileName: 'clip.wav',
      fields: {'language_code': languageCode, 'sample_rate_hz': sampleRateHz.toString()},
    );
    return json['transcript'] as String;
  }
}

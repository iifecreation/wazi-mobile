import 'api_client.dart';

/// Mirrors app/dialogue/schemas.py::DialogueTurnResponse.
class DialogueTurnResponse {
  DialogueTurnResponse({
    required this.intent,
    required this.replyText,
    required this.needsClarification,
    required this.clarificationOptions,
    required this.data,
    this.clientAction,
  });

  final String intent;
  final String replyText;
  final bool needsClarification;
  final List<String>? clarificationOptions;
  final Map<String, dynamic>? data;
  // Set only mid a change_pin/change_password voice flow (see
  // app/dialogue/manager.py) — "open_pin_modal" / "open_password_modal",
  // same vocabulary as onboarding's VoiceOnboardingResponse.clientAction.
  final String? clientAction;

  factory DialogueTurnResponse.fromJson(Map<String, dynamic> json) => DialogueTurnResponse(
    intent: json['intent'] as String,
    replyText: json['reply_text'] as String,
    needsClarification: json['needs_clarification'] as bool? ?? false,
    clarificationOptions: (json['clarification_options'] as List?)?.cast<String>(),
    data: json['data'] as Map<String, dynamic>?,
    clientAction: json['client_action'] as String?,
  );
}

class VoiceApi {
  VoiceApi(this._client);

  final ApiClient _client;

  /// The ASR -> NLU handoff point (see app/voice/router.py). `transcript`
  /// is whatever text the user "said" — this mobile build has no ASR
  /// vendor wired up either (same as the server), so it's either the
  /// literal suggestion-chip phrase or free-typed chat text.
  Future<DialogueTurnResponse> query({
    required String sessionId,
    required String userId,
    required String transcript,
    String? voiceSampleId,
  }) async {
    final json = await _client.post('/voice/query', {
      'session_id': sessionId,
      'user_id': userId,
      'transcript': transcript,
      if (voiceSampleId != null) 'voice_sample_id': voiceSampleId,
    });
    return DialogueTurnResponse.fromJson(json);
  }

  Future<VoiceOnboardingResponse> onboarding({
    required String sessionId,
    required String transcript,
  }) async {
    final json = await _client.post('/voice/onboarding', {
      'session_id': sessionId,
      'transcript': transcript,
    });
    return VoiceOnboardingResponse.fromJson(json);
  }
}

class VoiceOnboardingResponse {
  VoiceOnboardingResponse({
    required this.replyText,
    required this.sessionId,
    this.clientAction,
    this.userId,
  });

  final String replyText;
  final String sessionId;
  final String? clientAction;
  // Set as soon as the draft account exists (right after phone
  // verification) — this channel has no other way to learn its user_id.
  final String? userId;

  factory VoiceOnboardingResponse.fromJson(Map<String, dynamic> json) => VoiceOnboardingResponse(
    replyText: json['reply_text'] as String,
    sessionId: json['session_id'] as String,
    clientAction: json['client_action'] as String?,
    userId: json['user_id'] as String?,
  );
}

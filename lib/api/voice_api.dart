import 'api_client.dart';

/// Mirrors app/dialogue/schemas.py::DialogueTurnResponse — includes the
/// Wazi assistant persona fields added in the banking-assistant milestone.
class DialogueTurnResponse {
  DialogueTurnResponse({
    required this.intent,
    required this.replyText,
    required this.needsClarification,
    required this.clarificationOptions,
    required this.data,
    this.clientAction,
    this.isAuthenticated = false,
    this.suggestedActions,
    this.requiresAuth = false,
  });

  final String intent;
  final String replyText;
  final bool needsClarification;
  final List<String>? clarificationOptions;
  final Map<String, dynamic>? data;
  /// "open_pin_modal" / "open_password_modal" — mid credential-change flow.
  final String? clientAction;
  /// True when the session is authenticated (auth_token was accepted).
  final bool isAuthenticated;
  /// Quick-reply chip labels the UI can surface as suggestion buttons.
  final List<String>? suggestedActions;
  /// True when this turn was blocked by auth/KYC policy — client should
  /// show a sign-in or KYC-upgrade CTA alongside reply_text.
  final bool requiresAuth;

  factory DialogueTurnResponse.fromJson(Map<String, dynamic> json) =>
      DialogueTurnResponse(
        intent: json['intent'] as String,
        replyText: json['reply_text'] as String,
        needsClarification: json['needs_clarification'] as bool? ?? false,
        clarificationOptions:
            (json['clarification_options'] as List?)?.cast<String>(),
        data: json['data'] as Map<String, dynamic>?,
        clientAction: json['client_action'] as String?,
        isAuthenticated: json['is_authenticated'] as bool? ?? false,
        suggestedActions:
            (json['suggested_actions'] as List?)?.cast<String>(),
        requiresAuth: json['requires_auth'] as bool? ?? false,
      );
}

class VoiceApi {
  VoiceApi(this._client);

  final ApiClient _client;

  /// Primary Wazi assistant endpoint — auth-aware, returns suggested_actions
  /// and requires_auth so the UI can show sign-in CTAs and quick-reply chips.
  /// Pass [authToken] (the userId from a completed login) to unlock financial
  /// intents. Without it the assistant works as a helpful unauthenticated
  /// agent (greet, product info, help) and prompts sign-in for anything financial.
  Future<DialogueTurnResponse> assistant({
    required String sessionId,
    required String transcript,
    String? authToken,
    String? voiceSampleId,
  }) async {
    final json = await _client.post('/voice/assistant', {
      'session_id': sessionId,
      'transcript': transcript,
      if (authToken != null) 'auth_token': authToken,
      if (voiceSampleId != null) 'voice_sample_id': voiceSampleId,
    });
    return DialogueTurnResponse.fromJson(json);
  }

  /// Legacy /voice/query endpoint — kept for backwards compatibility with
  /// existing payment confirm flows that are already mid-session. New code
  /// should use [assistant] instead.
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
  final String? userId;

  factory VoiceOnboardingResponse.fromJson(Map<String, dynamic> json) =>
      VoiceOnboardingResponse(
        replyText: json['reply_text'] as String,
        sessionId: json['session_id'] as String,
        clientAction: json['client_action'] as String?,
        userId: json['user_id'] as String?,
      );
}

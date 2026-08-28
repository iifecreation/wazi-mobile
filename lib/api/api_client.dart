import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thrown for any non-2xx response. Carries the server's `detail` message
/// (FastAPI's standard error shape: `{"detail": "..."}`) so callers can
/// show it directly, and the status code for callers that need to branch
/// on it (401 vs 403 vs 429, etc. — mirroring exactly how Wazi-server
/// itself maps its domain errors to status codes).
class ApiException implements Exception {
  ApiException(this.statusCode, this.detail, {this.retryAfterSeconds});

  final int statusCode;
  final String detail;
  final int? retryAfterSeconds;

  @override
  String toString() => 'ApiException($statusCode): $detail';
}

/// Thin wrapper over package:http talking to Wazi-server. Default base URL
/// is the iOS Simulator's view of the host Mac's loopback — the Simulator
/// shares the host's network stack, so `127.0.0.1` reaches `uvicorn`
/// running on the same machine with no special-casing. Override via
/// `--dart-define=WAZI_API_BASE_URL=...` for a physical device or a
/// non-default port.
class ApiClient {
  ApiClient({String? baseUrl})
    : baseUrl = baseUrl ?? const String.fromEnvironment('WAZI_API_BASE_URL', defaultValue: 'http://127.0.0.1:8001');

  final String baseUrl;
  final http.Client _http = http.Client();

  Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('$baseUrl$path').replace(queryParameters: query?.isEmpty ?? true ? null : query);
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return const {};
      return jsonDecode(response.body) as Map<String, dynamic>;
    }
    String detail = response.reasonPhrase ?? 'Request failed';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      if (body['detail'] is String) detail = body['detail'] as String;
    } catch (_) {
      // Non-JSON error body — fall back to the reason phrase above.
    }
    final retryAfter = response.headers['retry-after'];
    throw ApiException(response.statusCode, detail, retryAfterSeconds: retryAfter != null ? int.tryParse(retryAfter) : null);
  }

  Future<Map<String, dynamic>> get(String path, {Map<String, String>? query}) async {
    final response = await _http.get(_uri(path, query));
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final response = await _http.post(
      _uri(path),
      headers: const {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    return _decode(response);
  }
}

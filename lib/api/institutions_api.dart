import 'api_client.dart';

/// Mirrors app/institutions/schemas.py::InstitutionOut — the verified
/// registry voice payments already resolve against; this just makes it
/// listable for the traditional (non-voice) payment screens' pickers.
class InstitutionOut {
  InstitutionOut({required this.institutionId, required this.name, required this.category, required this.obligationLabel});

  final String institutionId;
  final String name;
  final String category;
  final String obligationLabel;

  factory InstitutionOut.fromJson(Map<String, dynamic> json) => InstitutionOut(
    institutionId: json['institution_id'] as String,
    name: json['name'] as String,
    category: json['category'] as String,
    obligationLabel: json['obligation_label'] as String,
  );
}

class InstitutionsApi {
  InstitutionsApi(this._client);
  final ApiClient _client;

  Future<List<InstitutionOut>> listInstitutions({String? category}) async {
    final json = await _client.get('/institutions', query: {if (category != null) 'category': category});
    return (json['institutions'] as List).map((e) => InstitutionOut.fromJson(e as Map<String, dynamic>)).toList();
  }
}

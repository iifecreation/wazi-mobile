import 'api_client.dart';

/// Mirrors app/contacts/schemas.py::ContactOut.
class ContactOut {
  ContactOut({required this.contactId, required this.name});

  final String contactId;
  final String name;

  factory ContactOut.fromJson(Map<String, dynamic> json) => ContactOut(
    contactId: json['contact_id'] as String,
    name: json['name'] as String,
  );
}

class ContactsApi {
  ContactsApi(this._client);
  final ApiClient _client;

  Future<List<ContactOut>> listContacts(String userId) async {
    final json = await _client.get('/contacts/$userId');
    return (json['contacts'] as List).map((e) => ContactOut.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ContactOut> addContact(String userId, String name) async {
    final json = await _client.post('/contacts/$userId', {'name': name});
    return ContactOut.fromJson(json);
  }
}

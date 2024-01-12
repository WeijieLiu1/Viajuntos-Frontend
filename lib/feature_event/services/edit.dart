import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:viajuntos/utils/globals.dart';

class EditEventsAPI {
  final String url = baseLocalUrl + '/v3/events/';

  Future<bool> updateEvent(String id, List event) async {
    String body = jsonEncode(event[0]);

    final String putUrl = url + id;
    final response = await http.put(Uri.parse(putUrl),
        body: body, headers: {'Content-Type': 'application/json'});

    if (response.statusCode == 200) {
      return true;
    }
    return false;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:viajuntos/utils/globals.dart';

class DeleteEventAPI {
  final String url = baseUrl + '/v3/events/';

  Future<List> deleteEventById(String eventId) async {
    final response = await http.delete(Uri.parse(url + eventId));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    return [];
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:viajuntos/utils/globals.dart';

class GetEventsAPI {
  final String url = baseLocalUrl + '/v2/events/';

  Future<List> getEventById(String id) async {
    final response = await http.get(Uri.parse(url + id));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    return [];
  }

  // PENDING OF BACKEND URL DEFINITION
  Future<List> getUserEventsByCreator(String creatorId) async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    return [];
  }
}

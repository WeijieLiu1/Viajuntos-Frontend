import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../utils/globals.dart';

class EventsAPI {
  final String url = baseUrl + "/v1/events/";

  Future<List> getBestEvents() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
      //debugPrint(tmp[0]["longitud"].toString());
    }

    return [];
  }

  Future<List> getRecentlyAdded() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
      //debugPrint(tmp[0]["longitud"].toString());
    }

    return [];
  }
}

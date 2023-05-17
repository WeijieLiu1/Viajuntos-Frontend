import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../utils/globals.dart';

class EventsAPI {
  final String url = baseLocalUrl + "/v1/events/";

  Future<List> getAllEvents() async {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    }

    return [];
  }
}

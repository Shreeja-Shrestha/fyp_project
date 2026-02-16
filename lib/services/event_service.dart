import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/event_model.dart';

class EventService {
  static Future<List<Event>> fetchEvents(int tourId) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:3000/tours/$tourId/events'),
    );

    if (response.statusCode == 200) {
      List data = json.decode(response.body);
      return data.map((e) => Event.fromJson(e)).toList();
    } else {
      throw Exception("Failed to load events");
    }
  }
}

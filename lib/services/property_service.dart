import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/property_model.dart';

class PropertyService {
  static const String apiUrl =
      "http://api.staging.mera-ashiana.com/api/properties";

  static Future<List<PropertyModel>> fetchProperties() async {
    final response = await http.get(Uri.parse(apiUrl));

    if (response.statusCode == 200) {
      final decoded = json.decode(response.body);
      final List list = decoded['data'];

      return list.map((e) => PropertyModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load properties');
    }
  }
}

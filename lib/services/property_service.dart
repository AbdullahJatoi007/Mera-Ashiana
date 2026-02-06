import '../models/property_model.dart';
import '../core/api_client.dart';
import '../network/endpoints.dart';

class PropertyService {
  static Future<List<PropertyModel>> fetchProperties() async {
    final response = await ApiClient.get(Endpoints.properties);
    // Dio automatically decodes JSON into response.data
    final List list = response.data['data'];
    return list.map((e) => PropertyModel.fromJson(e)).toList();
  }
}

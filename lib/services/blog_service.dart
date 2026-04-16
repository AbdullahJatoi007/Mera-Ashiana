import '../models/blog_model.dart';
import '../core/api_client.dart';
import '../network/endpoints.dart';

class BlogService {
  /// Fetches all blogs from the /api/blogs endpoint
  static Future<List<Blog>> fetchAllBlogs() async {
    try {
      // Updated to use Endpoints.blogs -> "$apiBase/blogs"
      final response = await ApiClient.get(Endpoints.blogs);

      // Dio automatically decodes the response body into a Map
      final List blogList = response.data['data'] ?? [];

      return blogList.map((json) => Blog.fromJson(json)).toList();
    } catch (e) {
      // Rethrowing allows the UI to handle error states (e.g., showing a snackbar)
      rethrow;
    }
  }

  /// Fetches a single blog by its ID from /api/blogs/$id
  static Future<Blog> fetchBlogById(int id) async {
    try {
      // Updated to use Endpoints.blog(id) -> "$apiBase/blogs/$id"
      final response = await ApiClient.get(Endpoints.blog(id));

      // Handling potential nested data key
      final data = response.data['data'] ?? response.data;

      return Blog.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
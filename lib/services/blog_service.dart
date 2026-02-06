import '../models/blog_model.dart';
import '../core/api_client.dart';
import '../network/endpoints.dart';

class BlogService {
  static Future<List<Blog>> fetchAllBlogs() async {
    final response = await ApiClient.get(Endpoints.allBlogs);
    final List blogList = response.data['data'] ?? [];
    return blogList.map((json) => Blog.fromJson(json)).toList();
  }

  static Future<Blog> fetchBlogById(int id) async {
    final response = await ApiClient.get(Endpoints.blogById(id));
    return Blog.fromJson(response.data['data']);
  }
}

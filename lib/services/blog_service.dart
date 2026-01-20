import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mera_ashiana/models/blog_model.dart';

class BlogService {
  // Corrected Base URL based on your app.js: app.use("/admin/blogs", blogs);
  static const String baseUrl =
      "http://api.staging.mera-ashiana.com/admin/blogs";

  /// Fetches the list of all blogs from the backend
  static Future<List<Blog>> fetchAllBlogs() async {
    try {
      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      debugPrint("--- BLOG API DEBUG ---");
      debugPrint("Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Match backend: your controller returns { success: true, data: [...] }
        final List<dynamic> blogList = responseBody['data'] ?? [];

        return blogList.map((json) => Blog.fromJson(json)).toList();
      } else {
        throw "Failed to load blogs (Status: ${response.statusCode})";
      }
    } catch (e) {
      debugPrint("BlogService Error: $e");
      rethrow;
    }
  }

  /// Fetches a single blog post by its ID
  static Future<Blog> fetchBlogById(int id) async {
    try {
      final response = await http.get(
        Uri.parse("$baseUrl/$id"),
        headers: {'Accept': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = jsonDecode(response.body);

        // Match backend: your controller returns { success: true, data: {...} }
        return Blog.fromJson(responseBody['data']);
      } else {
        throw "Blog post not found";
      }
    } catch (e) {
      debugPrint("BlogService Detail Error: $e");
      rethrow;
    }
  }
}

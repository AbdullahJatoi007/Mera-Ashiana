import 'package:flutter/material.dart';
import 'package:mera_ashiana/models/blog_model.dart';
import 'package:mera_ashiana/services/blog_service.dart'; // Using the service
import 'package:mera_ashiana/screens/blog_detail_screen.dart'; // New Detail Screen
import 'package:intl/intl.dart';

class BlogsScreen extends StatefulWidget {
  const BlogsScreen({super.key});

  @override
  State<BlogsScreen> createState() => _BlogsScreenState();
}

class _BlogsScreenState extends State<BlogsScreen> {
  List<Blog> _blogs = [];
  bool _isLoading = true;
  final String _imageBaseUrl = "https://api-staging.mera-ashiana.com";

  @override
  void initState() {
    super.initState();
    _fetchBlogs();
  }

  Future<void> _fetchBlogs() async {
    setState(() => _isLoading = true);
    try {
      final blogs = await BlogService.fetchAllBlogs();
      setState(() {
        _blogs = blogs;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Blog fetch error: $e");
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Could not load blogs. Check your connection.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Real Estate Insights", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchBlogs,
        child: _blogs.isEmpty
            ? const Center(child: Text("No blogs found"))
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _blogs.length,
          itemBuilder: (context, index) {
            final blog = _blogs[index];
            if (index == 0) return _buildFeaturedBlog(blog);
            return _buildBlogCard(blog);
          },
        ),
      ),
    );
  }

  Widget _buildFeaturedBlog(Blog blog) {
    return GestureDetector(
      onTap: () => _openBlogDetail(blog),
      child: Card(
        margin: const EdgeInsets.only(bottom: 24),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        clipBehavior: Clip.antiAlias,
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.network(
              _imageBaseUrl + (blog.image ?? ""),
              height: 220,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
                  Container(color: Colors.grey[300], height: 220, child: const Icon(Icons.image, size: 50)),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      blog.category?.toUpperCase() ?? "GENERAL",
                      style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 10),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(blog.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(
                      blog.content,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[700], height: 1.4)
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlogCard(Blog blog) {
    return GestureDetector(
      onTap: () => _openBlogDetail(blog),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                _imageBaseUrl + (blog.image ?? ""),
                width: 110,
                height: 110,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    Container(width: 110, height: 110, color: Colors.grey[200], child: const Icon(Icons.broken_image)),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                      blog.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, height: 1.2)
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${blog.author} • ${blog.createdAt != null ? DateFormat('MMM dd, yyyy').format(blog.createdAt!) : ''}",
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openBlogDetail(Blog blog) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BlogDetailScreen(blog: blog)),
    );
  }
}
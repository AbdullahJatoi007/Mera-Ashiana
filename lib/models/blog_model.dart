class Blog {
  final int id;
  final String title;
  final String content;
  final String? image;
  final String? author;
  final String? category;
  final String? slug;
  final DateTime? createdAt;

  Blog({
    required this.id,
    required this.title,
    required this.content,
    this.image,
    this.author,
    this.category,
    this.slug,
    this.createdAt,
  });

  factory Blog.fromJson(Map<String, dynamic> json) {
    return Blog(
      id: json['id'],
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      image: json['image'],
      // Path like /uploads/blogs/filename.jpg
      author: json['author'],
      category: json['category'],
      slug: json['slug'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }
}

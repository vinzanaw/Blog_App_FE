import 'package:flutter/material.dart';
import 'package:blog_app_ats/api/api.services.dart';

class detailPage extends StatefulWidget {
  final int postId;

  const detailPage({
    super.key,
    required this.postId,
  });

  @override
  State<detailPage> createState() => _detailPageState();
}

class _detailPageState extends State<detailPage> {
  dynamic post;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getDetail();
  }

  Future<void> getDetail() async {
    try {
      final result = await ApiService.getPostById(widget.postId);

      setState(() {
        post = result;
        isLoading = false;
      });
    } catch (e) {
      print('ERROR: $e');

      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String? date) {
    if (date == null || date.isEmpty) {
      return '';
    }

    try {
      final dateTime = DateTime.parse(date);

      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    } catch (e) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      appBar: AppBar(
        backgroundColor: const Color(0xFF405778),

        iconTheme: const IconThemeData(
          color: Colors.white,
        ),

        title: const Text(
          'Detail Blog',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : post == null
              ? const Center(
                  child: Text(
                    'Blog tidak ditemukan',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                )
              : ScrollConfiguration(
                  behavior: const ScrollBehavior().copyWith(
                    overscroll: false,
                  ),

                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),

                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [

                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),

                          child: Image.network(
                            post['imageUrl'] ?? '',

                            width: double.infinity,
                            height: 220,

                            fit: BoxFit.cover,

                            errorBuilder: (
                              context,
                              error,
                              stackTrace,
                            ) {
                              return Container(
                                width: double.infinity,
                                height: 220,
                                color: Colors.grey[300],

                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                  size: 40,
                                ),
                              );
                            },
                          ),
                        ),

                        const SizedBox(height: 20),

                        Text(
                          post['title'] ?? 'Tanpa Judul',

                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 12),

                        Row(
                          children: [

                            const CircleAvatar(
                              radius: 20,

                              backgroundImage: AssetImage(
                                'assets/im.jpeg',
                              ),
                            ),

                            const SizedBox(width: 10),

                            const Text(
                              'Nafinza Imut',

                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(width: 8),

                            const Text(
                              '•',

                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),

                            const SizedBox(width: 8),

                            Text(
                              formatDate(
                                post['createdAt']?.toString(),
                              ),

                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        Text(
                          post['description'] ?? '',

                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.grey[700],
                            height: 1.5,
                          ),
                        ),

                        const SizedBox(height: 20),

                      ],
                    ),
                  ),
                ),
    );
  }
}
  import 'dart:convert';
  import 'package:flutter/material.dart';
  import 'package:shared_preferences/shared_preferences.dart';

  class savedPage extends StatefulWidget {
    const savedPage({super.key});

    @override
    State<savedPage> createState() => savedPageState();
  }

  class savedPageState extends State<savedPage> {
    List<dynamic> savedPosts = [];

    @override
    void initState() {
      super.initState();
      loadSavedPosts();
    }

    Future<void> loadSavedPosts() async {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList('savedPosts') ?? [];

      setState(() {
        savedPosts = data.map((item) => jsonDecode(item)).toList();
      });
    }

    Future<void> removeSavedPost(int id) async {
      final prefs = await SharedPreferences.getInstance();
      final data = prefs.getStringList('savedPosts') ?? [];

      data.removeWhere((item) {
        final post = jsonDecode(item);
        return post['id'] == id;
      });

      await prefs.setStringList('savedPosts', data);
      loadSavedPosts();
    }

    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: const Color(0xFF405778),
          toolbarHeight: 70,
          title: const Text(
            'Saved Blog',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: savedPosts.isEmpty
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bookmark_border,
                      size: 70,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 15),
                    Text(
                      'Belum ada blog yang disimpan',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(20),
                itemCount: savedPosts.length,
                itemBuilder: (context, index) {
                  final post = savedPosts[index];

                  return Container(
                    height: 145,
                    margin: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(5),
                          child: Image.network(
                            post['imageUrl'] ?? '',
                            width: 145,
                            height: 145,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 145,
                                height: 145,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported,
                                  color: Colors.grey,
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                post['title'] ?? 'Tanpa Judul',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                post['description'] ?? '',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              const Spacer(),
                              Row(
                                children: [
                                  const CircleAvatar(
                                    radius: 12,
                                    backgroundImage:
                                        AssetImage('assets/im.jpeg'),
                                  ),
                                  const SizedBox(width: 6),
                                  const Text(
                                    'Nafinza Imut',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      removeSavedPost(post['id']);
                                    },
                                    child: const Icon(
                                      Icons.bookmark,
                                      size: 23,
                                      color: Color(0xFF405778),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
      );
    }
  }
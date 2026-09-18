import 'package:flutter/material.dart';
import 'package:blog_app_ats/api/api.services.dart';
import 'package:blog_app_ats/pages/detailpage.dart';

class searchPage extends StatefulWidget {
  const searchPage({super.key});

  @override
  State<searchPage> createState() => _searchPageState();
}

class _searchPageState extends State<searchPage> {
  List<dynamic> posts = [];
  List<dynamic> filteredPosts = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    getPosts();
  }

  Future<void> getPosts() async {
    try {
      final data = await ApiService.getPosts();

      if (!mounted) return;

      setState(() {
        posts = data;
        filteredPosts = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  void searchPost(String value) {
    setState(() {
      filteredPosts = posts.where((post) {
        final title = post['title']?.toString().toLowerCase() ?? '';
        final description =
            post['description']?.toString().toLowerCase() ?? '';
        final search = value.toLowerCase();

        return title.contains(search) || description.contains(search);
      }).toList();
    });
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

  Widget buildPostCard(dynamic post) {
    final postId = post['id'];

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => detailPage(postId: postId),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildPostImage(post),
            const SizedBox(width: 12),
            Expanded(
              child: buildPostInfo(post),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPostImage(dynamic post) {
    final imageUrl = post['imageUrl'];

    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: imageUrl != null && imageUrl.toString().isNotEmpty
          ? Image.network(
              imageUrl,
              width: 125,
              height: 145,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  width: 125,
                  height: 145,
                  color: Colors.grey[300],
                  child: const Icon(
                    Icons.image_not_supported,
                    color: Colors.grey,
                    size: 35,
                  ),
                );
              },
            )
          : Container(
              width: 125,
              height: 145,
              color: Colors.grey[300],
              child: const Icon(
                Icons.image,
                color: Colors.grey,
                size: 35,
              ),
            ),
    );
  }

  Widget buildPostInfo(dynamic post) {
    return SizedBox(
      height: 145,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            post['title'] ?? 'Tanpa Judul',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 3,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFF405778).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              post['categoriesId']?.toString() ?? 'Uncategorized',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: Color(0xFF405778),
              ),
            ),
          ),

          const SizedBox(height: 6),

          Text(
            post['description'] ?? '',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey[600],
              height: 1.3,
            ),
          ),

          const Spacer(),

          Row(
            children: [
              const CircleAvatar(
                radius: 11,
                backgroundImage: AssetImage(
                  'assets/im.jpeg',
                ),
              ),

              const SizedBox(width: 5),

              const Expanded(
                child: Text(
                  'Nafinza Imut',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),

              const SizedBox(width: 4),

              const Text(
                '•',
                style: TextStyle(
                  fontSize: 9,
                ),
              ),

              const SizedBox(width: 4),

              Text(
                formatDate(post['createdAt']?.toString()),
                style: const TextStyle(
                  fontSize: 9,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(width: 5),

              const Icon(
                Icons.bookmark_border,
                size: 20,
                color: Colors.black,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget categoryButton(String category) {
    return GestureDetector(
      onTap: () {
        setState(() {
          filteredPosts = posts.where((post) {
            return post['categoriesId']?.toString().toLowerCase() ==
                category.toLowerCase();
          }).toList();
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(
          horizontal: 18,
          vertical: 10,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          category,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F5),

      appBar: AppBar(
        title: const Text(
          'Search',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF405778),
        foregroundColor: Colors.white,
      ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: searchPost,
              decoration: InputDecoration(
                hintText: 'Cari artikel...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Category',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          const SizedBox(height: 10),

          SizedBox(
            height: 45,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                categoryButton('Technology'),
                categoryButton('Programming'),
                categoryButton('Education'),
                categoryButton('News'),
                categoryButton('Food'),
              ],
            ),
          ),

          const SizedBox(height: 15),

          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredPosts.isEmpty
                    ? const Center(
                        child: Text(
                          'Post tidak ditemukan',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                        ),
                        itemCount: filteredPosts.length,
                        itemBuilder: (context, index) {
                          return buildPostCard(
                            filteredPosts[index],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blog_app_ats/api/api.services.dart';

class homePage extends StatefulWidget {
  const homePage({super.key});

  @override
  State<homePage> createState() => _homePageState();
}

class _homePageState extends State<homePage> {
  int selectedIndex = 0;

  List<dynamic> posts = [];
  bool isLoading = true;
  List<int> savedPostIds = [];

  static const List<Widget> pages = [
    SizedBox(),
    searchPage(),
    savedPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
    getPosts();
    loadSavedPosts();
  }

  Future<void> getPosts() async {
    try {
      final result = await ApiService.getPosts();

      if (!mounted) return;

      setState(() {
        posts = result;
        isLoading = false;
      });
    } catch (e) {
      print('ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> loadSavedPosts() async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList('savedPosts') ?? [];

    List<int> ids = [];

    for (var item in savedList) {
      final post = jsonDecode(item);
      ids.add(post['id']);
    }

    if (!mounted) return;

    setState(() {
      savedPostIds = ids;
    });
  }

  Future<void> toggleBookmark(dynamic post) async {
    final prefs = await SharedPreferences.getInstance();
    final savedList = prefs.getStringList('savedPosts') ?? [];
    final postId = post['id'];

    bool alreadySaved = savedPostIds.contains(postId);

    if (alreadySaved) {
      savedList.removeWhere((item) {
        final savedPost = jsonDecode(item);
        return savedPost['id'] == postId;
      });

      if (!mounted) return;

      setState(() {
        savedPostIds.remove(postId);
      });

      showMessage('Blog dihapus dari Saved');
    } else {
      savedList.add(jsonEncode(post));

      if (!mounted) return;

      setState(() {
        savedPostIds.add(postId);
      });

      showMessage('Blog berhasil ditambahkan ke Saved');
    }

    await prefs.setStringList('savedPosts', savedList);
  }

  Future<void> deletePost(dynamic post) async {
    final postId = post['id'];

    bool? confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hapus Blog'),
          content: const Text('Yakin mau hapus blog ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text(
                'Hapus',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await ApiService.deletePost(postId);

      if (!mounted) return;

      setState(() {
        posts.removeWhere((p) => p['id'] == postId);
      });

      showMessage('Blog berhasil dihapus');
    } catch (e) {
      showMessage('Gagal hapus: $e');
    }
  }

  void showMessage(String text) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(text),
        duration: const Duration(seconds: 1),
      ),
    );
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
    final isSaved = savedPostIds.contains(postId);

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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildPostImage(post),
            const SizedBox(width: 12),
            Expanded(
              child: buildPostInfo(post, isSaved),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildPostImage(dynamic post) {
    return ClipRRect(
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
    );
  }

  Widget buildPostInfo(dynamic post, bool isSaved) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                post['title'] ?? 'Tanpa Judul',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            buildEditDeleteButton(post),
          ],
        ),
        const SizedBox(height: 4),
        buildCategoryBadge(post['categoriesId']),
        const SizedBox(height: 6),
        Text(
          post['description'] ?? '',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const CircleAvatar(
              radius: 12,
              backgroundImage: AssetImage('assets/im.jpeg'),
            ),
            const SizedBox(width: 6),
            const Flexible(
              child: Text(
                'Nafinza Imut',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              '•',
              style: TextStyle(fontSize: 10),
            ),
            const SizedBox(width: 6),
            Text(
              formatDate(post['createdAt']?.toString()),
              style: const TextStyle(fontSize: 10),
            ),
            const Spacer(),
            GestureDetector(
              onTap: () => toggleBookmark(post),
              child: Icon(
                isSaved
                    ? Icons.bookmark
                    : Icons.bookmark_border,
                size: 23,
                color: isSaved
                    ? const Color(0xFF405778)
                    : Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildCategoryBadge(dynamic categoryName) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF405778).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        categoryName?.toString() ?? 'Uncategorized',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Color(0xFF405778),
        ),
      ),
    );
  }

  Widget buildEditDeleteButton(dynamic post) {
    return PopupMenuButton<String>(
      icon: const Icon(
        Icons.more_vert,
        size: 22,
      ),
      onSelected: (value) {
        if (value == 'edit') {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => createPage(
                postToEdit: post,
              ),
            ),
          ).then((updated) {
            if (updated == true) {
              getPosts();
            }
          });
        }

        if (value == 'delete') {
          deletePost(post);
        }
      },
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'edit',
          child: Row(
            children: [
              Icon(
                Icons.edit_outlined,
                size: 18,
              ),
              SizedBox(width: 8),
              Text('Edit'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(
                Icons.delete_outline,
                size: 18,
                color: Colors.red,
              ),
              SizedBox(width: 8),
              Text(
                'Delete',
                style: TextStyle(
                  color: Colors.red,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget homeContent() {
    return Scaffold(
      appBar: buildAppBar(),
      body: Stack(
        children: [
          buildPostList(),
          buildAddButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget buildAppBar() {
    return AppBar(
      toolbarHeight: 70,
      backgroundColor: const Color(0xFF405778),
      title: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              'Hii, Good Day!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(height: 5),
          Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              "Let's go work or reading blog",
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
      actions: const [
        Padding(
          padding: EdgeInsets.only(right: 20),
          child: CircleAvatar(
            radius: 25,
            backgroundImage: AssetImage('assets/im.jpeg'),
          ),
        ),
      ],
    );
  }

  Widget buildPostList() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (posts.isEmpty) {
      return const Center(
        child: Text(
          'Belum ada blog',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.only(
        left: 23,
        right: 15,
        top: 20,
        bottom: 100,
      ),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        return buildPostCard(posts[index]);
      },
    );
  }

  Widget buildAddButton() {
    return Positioned(
      right: 20,
      bottom: 20,
      child: FloatingActionButton(
        backgroundColor: const Color(0xFF405778),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const createPage(),
            ),
          ).then((created) {
            if (created == true) {
              getPosts();
            }
          });
        },
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 30,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: selectedIndex == 0
          ? homeContent()
          : pages[selectedIndex],
      bottomNavigationBar: buildBottomNav(),
    );
  }

  Widget buildBottomNav() {
    return Container(
      color: const Color(0xFFDDE6ED),
      padding: const EdgeInsets.symmetric(
        horizontal: 20,
        vertical: 20,
      ),
      child: GNav(
        gap: 8,
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        selectedIndex: selectedIndex,
        color: Colors.black,
        activeColor: Colors.white,
        tabBackgroundColor: const Color(0xFF57738B),
        tabBorderRadius: 50,
        onTabChange: (index) {
          setState(() {
            selectedIndex = index;
          });
        },
        tabs: const [
          GButton(
            icon: Icons.home,
            text: 'Home',
          ),
          GButton(
            icon: Icons.search_outlined,
            text: 'Search',
          ),
          GButton(
            icon: Icons.bookmark,
            text: 'Saved',
          ),
          GButton(
            icon: Icons.person_sharp,
            text: 'Profile',
          ),
        ],
      ),
    );
  }
}
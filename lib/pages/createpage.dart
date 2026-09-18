import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:blog_app_ats/api/api.services.dart';

class createPage extends StatefulWidget {
  final dynamic postToEdit;
  const createPage({super.key, this.postToEdit});

  @override
  State<createPage> createState() => _createPageState();
}

class _createPageState extends State<createPage> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();

  File? selectedImage;
  int? selectedCategory;
  bool isLoading = false;

  bool get isEdit => widget.postToEdit != null;

  final List<Map<String, dynamic>> categories = [
    {'id': 1, 'name': 'Technology'},
    {'id': 2, 'name': 'Programming'},
    {'id': 3, 'name': 'Education'},
    {'id': 4, 'name': 'News'},
    {'id': 5, 'name': 'Food'},
  ];

  @override
  void initState() {
    super.initState();
    if (isEdit) {
      titleController.text = widget.postToEdit['title']?.toString() ?? '';
      descriptionController.text = widget.postToEdit['description']?.toString() ?? '';
      selectedCategory = int.tryParse(widget.postToEdit['categoriesId']?.toString() ?? '');
    }
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) setState(() => selectedImage = File(image.path));
  }

  Future<void> savePost() async {
    if (titleController.text.trim().isEmpty) return showMessage('Judul belum diisi');
    if (selectedCategory == null) return showMessage('Kategori belum dipilih');
    if (descriptionController.text.trim().isEmpty) return showMessage('Deskripsi belum diisi');

    setState(() => isLoading = true);

    try {
      if (isEdit) {
        await ApiService.updatePost(
          id: int.parse(widget.postToEdit['id'].toString()),
          title: titleController.text.trim(),
          categoriesId: selectedCategory!,
          description: descriptionController.text.trim(),
          image: selectedImage, content: '',
        );
        if (!mounted) return;
        showMessage('Blog berhasil diupdate');
        Navigator.pop(context, true);
      } else {
        await ApiService.createPost(
          authorId: 1,
          categoriesId: selectedCategory!,
          title: titleController.text.trim(),
          description: descriptionController.text.trim(),
          image: selectedImage, content: '',
        );
        if (!mounted) return;
        showMessage('Blog berhasil dibuat');
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('ERROR SAVE POST: $e');
      if (!mounted) return;
      showMessage(isEdit ? 'Gagal mengupdate blog' : 'Gagal membuat blog');
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF405778),
        foregroundColor: Colors.white,
        title: Text(isEdit ? 'Edit Blog' : 'Create Blog', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: pickImage,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(12)),
                child: selectedImage != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(selectedImage!, width: double.infinity, height: 200, fit: BoxFit.cover),
                      )
                    : isEdit && widget.postToEdit['imageUrl'] != null && widget.postToEdit['imageUrl'].toString().isNotEmpty
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              widget.postToEdit['imageUrl'],
                              width: double.infinity,
                              height: 200,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => const Center(child: Icon(Icons.image, size: 50, color: Colors.grey)),
                            ),
                          )
                        : const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.add_photo_alternate_outlined, size: 50, color: Colors.grey),
                                SizedBox(height: 8),
                                Text('Pilih gambar', style: TextStyle(color: Colors.grey)),
                              ],
                            ),
                          ),
              ),
            ),

            const SizedBox(height: 20),
            const Text('Title', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: 'Masukkan judul blog',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 20),
            const Text('Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: categories.any((c) => c['id'] == selectedCategory) ? selectedCategory : null,
                  hint: const Text('Pilih kategori'),
                  isExpanded: true,
                  items: categories.map((c) => DropdownMenuItem<int>(value: c['id'], child: Text(c['name']))).toList(),
                  onChanged: (value) => setState(() => selectedCategory = value),
                ),
              ),
            ),

            const SizedBox(height: 20),
            const Text('Description', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Masukkan deskripsi blog',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),

            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: isLoading ? null : savePost,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF405778),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: isLoading
                    ? const SizedBox(width: 25, height: 25, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : Text(isEdit ? 'Update Blog' : 'Create Blog', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
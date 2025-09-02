import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/auth_service.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _title = TextEditingController();
  final _content = TextEditingController();
  final _notes = FirebaseFirestore.instance.collection('notes');
  final _auth = AuthService();

  File? _image;

  Future<void> _pick(ImageSource source) async {
    if (source == ImageSource.camera) {
      if (!await Permission.camera.request().isGranted) return;
    } else {
      if (!await Permission.photos.request().isGranted) return;
    }
    final picked = await ImagePicker().pickImage(source: source);
    if (picked != null) setState(() => _image = File(picked.path));
  }

  Future<String?> _upload(String id) async {
    if (_image == null) return null;
    final ref = FirebaseStorage.instance.ref("note_images/$id.jpg");
    await ref.putFile(_image!);
    return ref.getDownloadURL();
  }

  Future<void> _save() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final t = _title.text.trim();
    final c = _content.text.trim();
    if (t.isEmpty && c.isEmpty && _image == null) return;

    final id = _notes.doc().id;
    final url = await _upload(id);

    await _notes.doc(id).set({
      'uid': user.uid,
      'title': t,
      'content': c,
      'imageUrl': url,
      'createdAt': FieldValue.serverTimestamp(),
    });

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Add Note"),
        actions: [
          IconButton(onPressed: _save, icon: const Icon(Icons.check)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _title,
              decoration: const InputDecoration(hintText: "Title"),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: _content,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(hintText: "Write your note"),
              ),
            ),
            if (_image != null) ...[
              const SizedBox(height: 8),
              Image.file(_image!, height: 200),
            ],
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.photo, size: 28),
                  onPressed: () => _pick(ImageSource.gallery),
                ),
                const SizedBox(width: 12),
                IconButton(
                  icon: const Icon(Icons.camera_alt, size: 28),
                  onPressed: () => _pick(ImageSource.camera),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AddNotePage extends StatefulWidget {
  const AddNotePage({super.key});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();
  final _notes = FirebaseFirestore.instance.collection('notes');
  final _auth = AuthService();
  bool _saving = false;

  Future<void> _saveNote() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (_titleController.text.trim().isEmpty &&
        _bodyController.text.trim().isEmpty) return;

    setState(() => _saving = true);

    await _notes.add({
      'uid': user.uid,
      'title': _titleController.text.trim(),
      'content': _bodyController.text.trim(),
      'createdAt': FieldValue.serverTimestamp(),
    });

    if (mounted) {
      Navigator.pop(context); // go back to NotesPage
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Note'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saving ? null : _saveNote,
        child: _saving
            ? const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              )
            : const Icon(Icons.check),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                hintText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TextField(
                controller: _bodyController,
                maxLines: null,
                expands: true,
                decoration: const InputDecoration(
                  hintText: 'Write your note...',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


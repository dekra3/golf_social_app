import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../rounds/presentation/providers/rounds_provider.dart';
import '../../../tournaments/presentation/providers/tournaments_provider.dart';
import '../providers/feed_provider.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final _contentController = TextEditingController();
  String? _roundId;
  String? _tournamentId;
  Uint8List? _imageBytes;
  String? _imageExt;
  bool _isSaving = false;

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 1200);
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    setState(() {
      _imageBytes = bytes;
      _imageExt = picked.path.split('.').last;
    });
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider);
    if (user == null) return;
    if (_contentController.text.trim().isEmpty && _imageBytes == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add some text or a photo first')),
      );
      return;
    }

    setState(() => _isSaving = true);
    try {
      String? imageUrl;
      final bytes = _imageBytes;
      if (bytes != null) {
        imageUrl = await ref
            .read(feedRepositoryProvider)
            .uploadPostImage(user.id, bytes, _imageExt ?? 'jpg');
      }

      await ref.read(feedRepositoryProvider).createPost(
            userId: user.id,
            content:
                _contentController.text.trim().isEmpty ? null : _contentController.text.trim(),
            roundId: _roundId,
            tournamentId: _tournamentId,
            imageUrl: imageUrl,
          );
      ref.invalidate(feedProvider);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final roundsAsync = ref.watch(roundHistoryProvider);
    final tournamentsAsync = ref.watch(myTournamentsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('New post')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          TextField(
            controller: _contentController,
            decoration: const InputDecoration(labelText: "What's on your mind?"),
            maxLines: 4,
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: _pickImage,
            child: Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(10),
              ),
              child: _imageBytes != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                    )
                  : const Center(child: Icon(Icons.add_a_photo, size: 32)),
            ),
          ),
          const SizedBox(height: 16),
          roundsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (err, _) => const SizedBox.shrink(),
            data: (rounds) => DropdownButtonFormField<String?>(
              initialValue: _roundId,
              decoration: const InputDecoration(labelText: 'Attach a round (optional)'),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('None')),
                ...rounds.map(
                  (r) => DropdownMenuItem<String?>(
                    value: r.id,
                    child: Text('${r.courseName ?? 'Round'} — ${r.totalScore ?? 'in progress'}'),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _roundId = v),
            ),
          ),
          const SizedBox(height: 12),
          tournamentsAsync.when(
            loading: () => const LinearProgressIndicator(),
            error: (err, _) => const SizedBox.shrink(),
            data: (tournaments) => DropdownButtonFormField<String?>(
              initialValue: _tournamentId,
              decoration: const InputDecoration(labelText: 'Attach a tournament (optional)'),
              items: [
                const DropdownMenuItem<String?>(value: null, child: Text('None')),
                ...tournaments.map(
                  (t) => DropdownMenuItem<String?>(value: t.id, child: Text(t.name)),
                ),
              ],
              onChanged: (v) => setState(() => _tournamentId = v),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _isSaving ? null : _save,
            child: _isSaving
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                : const Text('Post'),
          ),
        ],
      ),
    );
  }
}
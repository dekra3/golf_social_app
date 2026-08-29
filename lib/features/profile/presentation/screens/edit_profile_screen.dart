import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../providers/profile_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _fullNameController = TextEditingController();
  final _bioController = TextEditingController();
  final _homeCourseController = TextEditingController();
  final _handicapController = TextEditingController();
  bool _isSaving = false;
  bool _initialized = false;
  bool _isPublic = true;

  @override
  void dispose() {
    _fullNameController.dispose();
    _bioController.dispose();
    _homeCourseController.dispose();
    _handicapController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    if (picked == null) return;

    final profile = ref.read(currentProfileProvider).value;
    if (profile == null) return;

    final bytes = await picked.readAsBytes();
    final ext = picked.path.split('.').last;
    final url = await ref.read(profileRepositoryProvider).uploadAvatar(profile.id, bytes, ext);
    await ref.read(profileRepositoryProvider).updateProfile(profile.copyWith(avatarUrl: url));
    ref.invalidate(currentProfileProvider);
  }

  Future<void> _save() async {
    final profile = ref.read(currentProfileProvider).value;
    if (profile == null) return;

    setState(() => _isSaving = true);
    try {
      final updated = profile.copyWith(
        fullName: _fullNameController.text.trim().isEmpty ? null : _fullNameController.text.trim(),
        bio: _bioController.text.trim().isEmpty ? null : _bioController.text.trim(),
        homeCourse:
            _homeCourseController.text.trim().isEmpty ? null : _homeCourseController.text.trim(),
        handicapIndex: double.tryParse(_handicapController.text.trim()),
        isPublic: _isPublic,
      );
      await ref.read(profileRepositoryProvider).updateProfile(updated);
      ref.invalidate(currentProfileProvider);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(currentProfileProvider);

    // Prefill controllers once the profile has loaded.
    profileAsync.whenData((profile) {
      if (!_initialized && profile != null) {
        _fullNameController.text = profile.fullName ?? '';
        _bioController.text = profile.bio ?? '';
        _homeCourseController.text = profile.homeCourse ?? '';
        _handicapController.text = profile.handicapIndex?.toString() ?? '';
        _isPublic = profile.isPublic;
        _initialized = true;
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
        data: (profile) {
          if (profile == null) return const SizedBox.shrink();
          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Center(
                child: GestureDetector(
                  onTap: _pickAndUploadAvatar,
                  child: CircleAvatar(
                    radius: 44,
                    backgroundImage: profile.avatarUrl != null ? NetworkImage(profile.avatarUrl!) : null,
                    child: profile.avatarUrl == null ? const Icon(Icons.add_a_photo) : null,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'Full name'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _bioController,
                decoration: const InputDecoration(labelText: 'Bio'),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _homeCourseController,
                decoration: const InputDecoration(labelText: 'Home course'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _handicapController,
                decoration: const InputDecoration(labelText: 'Handicap index'),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Public profile'),
                subtitle: const Text(
                  "Off means only accepted connections can see your profile and posts — "
                  "you also won't appear in golfer search for anyone else",
                ),
                value: _isPublic,
                onChanged: (v) => setState(() => _isPublic = v),
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
                    : const Text('Save changes'),
              ),
            ],
          );
        },
      ),
    );
  }
}
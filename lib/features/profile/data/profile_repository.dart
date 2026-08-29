import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/profile_model.dart';

class ProfileRepository {
  ProfileRepository(this._client);

  final SupabaseClient _client;

  Future<Profile> getProfile(String userId) async {
    final data = await _client.from('profiles').select().eq('id', userId).single();
    return Profile.fromJson(data);
  }

  Future<void> updateProfile(Profile profile) async {
    await _client.from('profiles').update(profile.toUpdateJson()).eq('id', profile.id);
  }

  /// Uploads an avatar image to the `avatars` storage bucket and returns
  /// its public URL. Requires a storage bucket named `avatars` to exist.
  Future<String> uploadAvatar(String userId, List<int> fileBytes, String fileExt) async {
    final path = '$userId/avatar.$fileExt';
    await _client.storage.from('avatars').uploadBinary(
          path,
          Uint8List.fromList(fileBytes),
          fileOptions: const FileOptions(upsert: true),
        );
    return _client.storage.from('avatars').getPublicUrl(path);
  }
}

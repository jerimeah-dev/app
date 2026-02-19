import 'dart:io';
import 'supabase_client.dart';

class StorageService {
  final _client = SupabaseClientProvider.client;

  Future<String> uploadFile({
    required String bucket,
    required String path,
    required File file,
  }) async {
    await _client.storage.from(bucket).upload(path, file);

    return _client.storage.from(bucket).getPublicUrl(path);
  }

  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await _client.storage.from(bucket).remove([path]);
  }

  Future<void> deleteFiles({
    required String bucket,
    required List<String> paths,
  }) async {
    if (paths.isEmpty) return;

    await _client.storage.from(bucket).remove(paths);
  }
}

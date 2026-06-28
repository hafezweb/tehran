import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final client = Supabase.instance.client;

  String? get userId => client.auth.currentUser?.id;

  Future<String> uploadAudio(String fileName, dynamic file) async {
    try {
      print("UPLOAD STARTED: $fileName");
      print("FILE EXISTS: ${file.existsSync()}");
      print("FILE PATH: ${file.path}");

      await client.storage
          .from('audio')
          .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

      final url = client.storage.from('audio').getPublicUrl(fileName);

      print("UPLOAD SUCCESS: $url");

      return url;
    } catch (e) {
      print("UPLOAD ERROR: $e");
      rethrow;
    }
  }

  Future<void> incrementPlay(String postId) async {
    final post = await client
        .from('audio_posts')
        .select('plays')
        .eq('id', postId)
        .single();

    final currentPlays = post['plays'] ?? 0;

    await client
        .from('audio_posts')
        .update({'plays': currentPlays + 1})
        .eq('id', postId);
  }

  Future<List<Map<String, dynamic>>> getFeed() async {
    final res = await client
        .from('audio_posts')
        .select()
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(res);
  }

  Stream<List<Map<String, dynamic>>> streamAudioPosts() {
    return client
        .from('audio_posts')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .map((data) => List<Map<String, dynamic>>.from(data));
  }

  Future<void> toggleLike(String postId) async {
    final uid = userId;
    if (uid == null) return;

    final exists = await client
        .from('audio_likes')
        .select('id')
        .eq('user_id', uid)
        .eq('post_id', postId);

    if (exists.isEmpty) {
      await client.from('audio_likes').insert({
        'user_id': uid,
        'post_id': postId,
      });
    } else {
      await client
          .from('audio_likes')
          .delete()
          .eq('user_id', uid)
          .eq('post_id', postId);
    }
  }
}

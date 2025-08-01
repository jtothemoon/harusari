import 'package:harutodo/models/announcement.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AnnouncementRepository {
  final SupabaseClient _client;
  final String _appId;

  AnnouncementRepository(this._client, this._appId);

  Future<List<Announcement>> getAnnouncements() async {
    final response = await _client
        .from('announcements')
        .select()
        .eq('app_id', _appId)
        .eq('is_active', true)
        .order('created_at', ascending: false);
    return response.map((e) => Announcement.fromJson(e)).toList();
  }

  Future<Announcement?> getLatestAnnouncement() async {
    final response =
        await _client
            .from('announcements')
            .select()
            .eq('app_id', _appId)
            .eq('is_active', true)
            .order('created_at', ascending: false)
            .limit(1)
            .maybeSingle();
    if (response == null) return null;
    return Announcement.fromJson(response);
  }
}
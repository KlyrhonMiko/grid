import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/instagram_user.dart';
import '../models/instagram_post.dart';

class InstagramService {
  static const String _graphBaseUrl = 'https://graph.instagram.com/v22.0';

  final String accessToken;

  InstagramService(this.accessToken);

  static Future<String> exchangeCodeForToken({
    required String code,
    required String clientId,
    required String clientSecret,
    required String redirectUri,
  }) async {
    final response = await http.post(
      Uri.parse('https://api.instagram.com/oauth/access_token'),
      body: {
        'client_id': clientId,
        'client_secret': clientSecret,
        'grant_type': 'authorization_code',
        'redirect_uri': redirectUri,
        'code': code,
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'] as String;
    }
    throw Exception('Token exchange failed (${response.statusCode}): ${response.body}');
  }

  static Future<String> getLongLivedToken({
    required String shortLivedToken,
    required String clientSecret,
  }) async {
    final uri = Uri.parse('$_graphBaseUrl/access_token').replace(
      queryParameters: {
        'grant_type': 'ig_exchange_token',
        'client_secret': clientSecret,
        'access_token': shortLivedToken,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['access_token'] as String;
    }
    throw Exception('Long-lived token failed (${response.statusCode}): ${response.body}');
  }

  Future<InstagramUser> getProfile() async {
    final uri = Uri.parse('$_graphBaseUrl/me').replace(
      queryParameters: {
        'fields':
            'id,username,name,profile_picture_url,biography,website,media_count,followers_count,follows_count',
        'access_token': accessToken,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return InstagramUser.fromJson(json.decode(response.body));
    }
    throw Exception('Profile fetch failed (${response.statusCode}): ${response.body}');
  }

  Future<List<InstagramPost>> getMedia({int limit = 30}) async {
    final uri = Uri.parse('$_graphBaseUrl/me/media').replace(
      queryParameters: {
        'fields': 'id,caption,media_type,media_url,thumbnail_url,timestamp,permalink',
        'limit': limit.toString(),
        'access_token': accessToken,
      },
    );

    final response = await http.get(uri);

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final List<dynamic> items = data['data'] ?? [];
      return items
          .map((item) => InstagramPost.fromJson(item as Map<String, dynamic>))
          .toList();
    }
    throw Exception('Media fetch failed (${response.statusCode}): ${response.body}');
  }
}

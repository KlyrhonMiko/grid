import 'package:flutter_dotenv/flutter_dotenv.dart';

class InstagramConfig {
  static String get clientId => dotenv.env['INSTAGRAM_APP_ID'] ?? '';
  static String get clientSecret => dotenv.env['INSTAGRAM_APP_SECRET'] ?? '';
  static String get redirectUri => dotenv.env['INSTAGRAM_REDIRECT_URI'] ?? '';

  static const String scope = 'instagram_business_basic';

  static String get authorizationUrl {
    if (clientId.isEmpty || redirectUri.isEmpty) {
      throw Exception(
        'Missing INSTAGRAM_APP_ID or INSTAGRAM_REDIRECT_URI in .env',
      );
    }
    return 'https://www.instagram.com/oauth/authorize'
        '?client_id=$clientId'
        '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
        '&response_type=code'
        '&scope=${Uri.encodeComponent(scope)}';
  }
}

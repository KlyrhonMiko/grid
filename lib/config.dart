class InstagramConfig {
  // ── Setup ──────────────────────────────────────────────────────────
  //
  // 1. Create an app at https://developers.facebook.com
  // 2. Add the "Instagram" product → configure "Instagram Login"
  // 3. Deploy  auth_redirect/index.html  to any HTTPS host:
  //      • GitHub Pages:  https://<user>.github.io/<repo>/
  //      • Netlify / Vercel / any static host
  // 4. Register that HTTPS URL as a "Valid OAuth Redirect URI" in Meta
  // 5. Paste the same URL into [redirectUri] below
  // 6. Fill in your App ID and App Secret
  //
  // The redirect page bridges HTTPS → grid:// so the app can catch it.
  //
  // IMPORTANT: In production, move the client secret to a backend server.
  // ────────────────────────────────────────────────────────────────────

  static const String clientId = 'YOUR_INSTAGRAM_APP_ID';
  static const String clientSecret = 'YOUR_INSTAGRAM_APP_SECRET';

  /// The HTTPS URL where you deployed  auth_redirect/index.html.
  /// This is what you register with Meta as a Valid OAuth Redirect URI.
  static const String redirectUri =
      'https://YOUR_USERNAME.github.io/YOUR_REPO/';

  static const String scope = 'instagram_business_basic';

  static String get authorizationUrl =>
      'https://www.instagram.com/oauth/authorize'
      '?client_id=$clientId'
      '&redirect_uri=${Uri.encodeComponent(redirectUri)}'
      '&response_type=code'
      '&scope=${Uri.encodeComponent(scope)}';
}

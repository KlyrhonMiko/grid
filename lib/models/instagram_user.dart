class InstagramUser {
  final String id;
  final String username;
  final String? name;
  final String? profilePictureUrl;
  final String? biography;
  final String? website;
  final int mediaCount;
  final int followersCount;
  final int followsCount;

  InstagramUser({
    required this.id,
    required this.username,
    this.name,
    this.profilePictureUrl,
    this.biography,
    this.website,
    this.mediaCount = 0,
    this.followersCount = 0,
    this.followsCount = 0,
  });

  factory InstagramUser.fromJson(Map<String, dynamic> json) {
    return InstagramUser(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      name: json['name'],
      profilePictureUrl: json['profile_picture_url'],
      biography: json['biography'],
      website: json['website'],
      mediaCount: json['media_count'] ?? 0,
      followersCount: json['followers_count'] ?? 0,
      followsCount: json['follows_count'] ?? 0,
    );
  }
}

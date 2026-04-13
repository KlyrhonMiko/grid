class InstagramPost {
  final String id;
  final String? caption;
  final String mediaType;
  final String? mediaUrl;
  final String? thumbnailUrl;
  final String? timestamp;
  final String? permalink;

  InstagramPost({
    required this.id,
    this.caption,
    required this.mediaType,
    this.mediaUrl,
    this.thumbnailUrl,
    this.timestamp,
    this.permalink,
  });

  factory InstagramPost.fromJson(Map<String, dynamic> json) {
    return InstagramPost(
      id: json['id']?.toString() ?? '',
      caption: json['caption'],
      mediaType: json['media_type'] ?? 'IMAGE',
      mediaUrl: json['media_url'],
      thumbnailUrl: json['thumbnail_url'],
      timestamp: json['timestamp'],
      permalink: json['permalink'],
    );
  }

  String get displayUrl {
    if (mediaType == 'VIDEO') {
      return thumbnailUrl ?? mediaUrl ?? '';
    }
    return mediaUrl ?? '';
  }

  bool get isVideo => mediaType == 'VIDEO';
  bool get isCarousel => mediaType == 'CAROUSEL_ALBUM';
}

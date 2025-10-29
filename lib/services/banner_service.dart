import 'dart:convert';
import 'package:http/http.dart' as http;

class BannerService {
  static const String _baseUrl = 'http://dashboard.ebookamd.com/api/dev';

  // Fetch active banners
  static Future<List<BannerData>?> getActiveBanners() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/banner/active'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        if (data['status'] == true && data['data'] != null) {
          final List<dynamic> banners = data['data'];
          return banners.map((banner) => BannerData.fromJson(banner)).toList();
        }
      }

      print(
          '🔴 [BANNER SERVICE] Failed to fetch banners: ${response.statusCode}');
      return null;
    } catch (e) {
      print('🔴 [BANNER SERVICE] Error fetching banners: $e');
      return null;
    }
  }
}

class BannerData {
  final String id;
  final String title;
  final String description;
  final String image;
  final String? link;
  final String startedAt;
  final String endedAt;

  BannerData({
    required this.id,
    required this.title,
    required this.description,
    required this.image,
    this.link,
    required this.startedAt,
    required this.endedAt,
  });

  factory BannerData.fromJson(Map<String, dynamic> json) {
    return BannerData(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      image: json['image'] ?? '',
      link: json['link'],
      startedAt: json['started_at'] ?? '',
      endedAt: json['ended_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image': image,
      'link': link,
      'started_at': startedAt,
      'ended_at': endedAt,
    };
  }
}

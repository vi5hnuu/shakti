import 'package:shakti/models/ReelCategory.dart';

class Reel {
    final String id;
    final String title;
    final String videoUrl;
    final String? description;
    final ReelCategory? category;
    final bool isActive;
    final String? thumbnailUrl;
    final DateTime createdAt;

    Reel({
        required this.id,
        required this.title,
        required this.videoUrl,
        this.description,
        this.category,
        required this.isActive,
        this.thumbnailUrl,
        required this.createdAt});

    factory Reel.fromJson(Map<String,dynamic> json){
        return Reel(
            id: json['id'],
            title:json['title'],
            videoUrl:json['videoUrl'],
            description:json['description'],
            category:json['category']!=null ? ReelCategory.fromJson(json['category']):null,
            isActive:json['active'],
            thumbnailUrl:json['thumbnailUrl'],
            createdAt:DateTime.parse(json['createdAt'])
        );
    }
}
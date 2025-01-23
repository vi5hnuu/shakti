class Aarti {
    final String id;
    final String title;
    final String audioUrl;
    final DateTime createdAt;
    final DateTime updatedAt;

    Aarti({
        required this.id,
        required this.title,
        required this.audioUrl,
        required this.createdAt,
        required this.updatedAt});

    factory Aarti.fromJson(Map<String,dynamic> json){
        return Aarti(
            id: json['id'],
            title: json['title'],
            audioUrl: json['audioUrl'],
            createdAt: DateTime.parse(json['createdAt']),
            updatedAt: DateTime.parse(json['updatedAt']));
    }
}
class ReelCategory {
    final String id; // Primary key
    final String name; // Name of the category

    ReelCategory({required this.id,required this.name});

    factory ReelCategory.fromJson(Map<String,dynamic> json){
        return ReelCategory(
            id: json['id'],
            name: json['name']
        );
    }
}
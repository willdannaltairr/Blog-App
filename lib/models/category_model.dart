class CategoryModel {
  final int id;
  final String name;
  final String? createdAt;

  CategoryModel({required this.id, required this.name, this.createdAt});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    int id = 0;
    if (json['id'] is int) {
      id = json['id'];
    } else {
      id = int.tryParse(json['id']?.toString() ?? '') ?? 0;
    }

    return CategoryModel(
      id: id,
      name: json['name']?.toString() ?? '',
      createdAt:
          json['created_at']?.toString() ?? json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name};
  }
}

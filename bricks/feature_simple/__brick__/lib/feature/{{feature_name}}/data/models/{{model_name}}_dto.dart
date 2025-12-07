import 'package:pixel_love/feature/{{feature_name}}/domain/models/{{model_name}}.dart';

class {{model_name.pascalCase()}}Dto {
  final String id;
  final String? title;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  {{model_name.pascalCase()}}Dto({
    required this.id,
    this.title,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory {{model_name.pascalCase()}}Dto.fromJson(Map<String, dynamic> json) {
    return {{model_name.pascalCase()}}Dto(
      id: json['id']?.toString() ?? '',
      title: json['title'] as String?,
      description: json['description'] as String?,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'].toString())
          : null,
    );
  }

  factory {{model_name.pascalCase()}}Dto.fromDomain({{model_name.pascalCase()}} entity) {
    return {{model_name.pascalCase()}}Dto(
      id: entity.id,
      title: entity.title,
      description: entity.description,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  {{model_name.pascalCase()}} toDomain() {
    return {{model_name.pascalCase()}}(
      id: id,
      title: title,
      description: description,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}


import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'category.g.dart';

/// Category represents item categories with hierarchical structure
@JsonSerializable()
class Category extends BaseModel {
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: 'parentId')
  final int? parentId;

  @JsonKey(name: 'parent')
  final Category? parent;

  @JsonKey(name: 'children')
  final List<Category>? children;

  const Category({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    required this.name,
    this.description,
    this.parentId,
    this.parent,
    this.children,
  });

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  /// Check if this is a root category (no parent)
  bool get isRoot => parentId == null;

  /// Check if this category has children
  bool get hasChildren => children?.isNotEmpty == true;

  /// Get the full path of this category (including parent names)
  String getFullPath() {
    if (parent != null) {
      return '${parent!.getFullPath()} > $name';
    }
    return name;
  }

  @override
  String toString() {
    return 'Category{id: $id, name: $name, parentId: $parentId}';
  }
}

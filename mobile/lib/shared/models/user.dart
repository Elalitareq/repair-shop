import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'user.g.dart';

/// User represents system users
@JsonSerializable()
class User extends BaseModel {
  @JsonKey(name: 'username')
  final String username;

  @JsonKey(name: 'email')
  final String email;

  @JsonKey(name: 'role')
  final String role;

  @JsonKey(name: 'isActive')
  final bool isActive;

  const User({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    required this.username,
    required this.email,
    this.role = 'user',
    this.isActive = true,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$UserToJson(this);

  @override
  String toString() {
    return 'User{id: $id, username: $username, email: $email, role: $role, isActive: $isActive}';
  }
}

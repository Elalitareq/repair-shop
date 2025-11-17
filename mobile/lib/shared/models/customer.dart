import 'package:json_annotation/json_annotation.dart';
import 'base_model.dart';

part 'customer.g.dart';

/// Customer represents both dealers and customers
@JsonSerializable()
class Customer extends BaseModel {
  @JsonKey(name: 'name')
  final String name;

  @JsonKey(name: 'company_name')
  final String? companyName;

  @JsonKey(name: 'type')
  final String type; // dealer, customer

  @JsonKey(name: 'phone_number')
  final String phoneNumber;

  @JsonKey(name: 'address')
  final String? address;

  @JsonKey(name: 'tax_number')
  final String? taxNumber;

  @JsonKey(name: 'location_link')
  final String? locationLink;

  const Customer({
    required super.id,
    required super.createdAt,
    required super.updatedAt,
    super.syncStatus,
    required this.name,
    this.companyName,
    required this.type,
    required this.phoneNumber,
    this.address,
    this.taxNumber,
    this.locationLink,
  });

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$CustomerToJson(this);

  /// Check if this is a dealer
  bool get isDealer => type.toLowerCase() == 'dealer';

  /// Check if this is a customer
  bool get isCustomer => type.toLowerCase() == 'customer';

  /// Get display name (company name if available, otherwise name)
  String get displayName =>
      companyName?.isNotEmpty == true ? companyName! : name;

  @override
  String toString() {
    return 'Customer{id: $id, name: $name, type: $type, phoneNumber: $phoneNumber}';
  }
}

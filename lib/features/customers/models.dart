class Customer {
  final int id;
  final String? name;
  final String? phone;
  final String? address;
  final String? segment;
  final String? updatedAt;
  final String? deletedAt;
  Customer({
    required this.id,
    this.name,
    this.phone,
    this.address,
    this.segment,
    this.updatedAt,
    this.deletedAt,
  });
  factory Customer.fromMap(Map m){
    return Customer(
      id: (m['id']??0) as int,
      name: m['name'] as String?,
      phone: m['phone'] as String?,
      address: m['address'] as String?,
      segment: m['segment'] as String?,
      updatedAt: m['updated_at'] as String?,
      deletedAt: m['deleted_at'] as String?,
    );
  }
}

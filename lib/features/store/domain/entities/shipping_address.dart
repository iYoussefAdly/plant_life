class ShippingAddress {
  final String city;
  final String street;
  final String phone;
  final String details;

  const ShippingAddress({
    required this.city,
    required this.street,
    required this.phone,
    this.details = '',
  });

  Map<String, dynamic> toJson() => {
        'city': city,
        'street': street,
        'phone': phone,
        if (details.trim().isNotEmpty) 'details': details.trim(),
      };

  factory ShippingAddress.fromJson(Map<String, dynamic> json) {
    return ShippingAddress(
      city: json['city'] as String? ?? '',
      street: json['street'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      details: json['details'] as String? ?? '',
    );
  }
}

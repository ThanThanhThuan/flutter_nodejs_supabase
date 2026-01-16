class Contact {
  final int id;
  final String name;
  final String phone;
  final String? imageUrl;

  Contact({
    required this.id,
    required this.name,
    required this.phone,
    this.imageUrl,
  });

  factory Contact.fromJson(Map<String, dynamic> json) {
    return Contact(
      id: json['id'],
      name: json['name'],
      phone: json['phone'] ?? '',
      imageUrl: json['image_url'],
    );
  }
}

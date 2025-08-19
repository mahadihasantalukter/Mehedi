class Student {
  final String id;
  final String name;
  final String email;
  final String address;
  final String imageUrl; 

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
    required this.imageUrl, 
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['Name'] as String,
      email: json['Email'] as String,
      address: json['Address'] as String,
      imageUrl: json['image_url'] ?? '',
    );
  }
}
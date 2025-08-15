class Student {
  final String id;
  final String name;
  final String email;
  final String address;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.address,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'] as String,
      name: json['Name'] as String,
      email: json['Email'] as String,
      address: json['Address'] as String,
    );
  }
}

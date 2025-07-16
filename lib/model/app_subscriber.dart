class AppSubscriber {
  final String id;
  final String fullName;
  final String? email;
  final String address;
  final String gender;
  final String age;
  final String phoneNumber;
  final String? password;
  final String registeredDate;
  final String viaSMS;

  AppSubscriber({
    required this.id,
    required this.fullName,
    this.email,
    required this.address,
    required this.gender,
    required this.age,
    required this.phoneNumber,
    this.password,
    required this.registeredDate,
    required this.viaSMS
  });

  factory AppSubscriber.fromMap(Map<String, dynamic> subscriber) {
    return AppSubscriber(
      id: subscriber['id'] ?? '',
      fullName: subscriber['fullName'] ?? '',
      email: subscriber['email'] ?? '',
      address: subscriber['address'] ?? '',
      gender: subscriber['gender'] ?? '',
      age: subscriber['age'] ?? '',
      phoneNumber: subscriber['phoneNumber'] ?? '',
      password: subscriber['password'] ?? '',
      registeredDate: subscriber['registeredDate'] ?? '',
      viaSMS: subscriber['viaSMS'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'address': address,
      'gender': gender,
      'age': age,
      'phoneNumber': phoneNumber,
      'password': password,
      'registeredDate': registeredDate,
      'viaSMS': viaSMS
    };
  }
}

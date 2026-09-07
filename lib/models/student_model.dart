class StudentModel {
  final String id;
  final String name;
  final String surname;
  final String uniqueId;

  StudentModel({
    required this.id,
    required this.name,
    required this.surname,
    required this.uniqueId,
  });

  factory StudentModel.fromFirestore(String id, Map<String, dynamic> data) {
    return StudentModel(
      id: id,
      name: data['name'] ?? '',
      surname: data['surname'] ?? '',
      uniqueId: data['uniqueId'] ?? '',
    );
  }
}
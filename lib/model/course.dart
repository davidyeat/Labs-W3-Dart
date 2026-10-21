class Course {
  final String id;
  final String name;
  final List<String> studentIds = [];
  final List<String> scoreIds = [];

  Course({required this.id, required this.name});
}

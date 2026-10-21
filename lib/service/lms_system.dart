import '../model/course.dart';
import '../model/student.dart';
import '../model/score.dart';

class LmsSystem {
  final List<Student> students = [];
  final List<Course> courses = [];
  final List<Score> scores = [];

  // Task 1 — Add and remove courses
  void addCourse({required String courseId, required String courseName}) {
    Course? course = _findCourseOrNull(courseId);
    if (course != null) {
      throw Exception('Course $courseId already exists');
    }
    courses.add(Course(id: courseId, name: courseName));
  }

  void removeCourse({required String courseId}) {
    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId not found!');
    }
    courses.removeWhere((course) => course.id == courseId);
  }

  // Task 2 — Enroll a student in a course
  void enrollStudent({required String studentId, required String courseId}) {
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student ID $studentId not enrolled yet!');
    }

    Course? course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course ID $courseId not exists yet!');
    }

    // Check duplicate enrollment
    if (course.studentIds.any((id) => id == studentId)) {
      throw Exception(
          'Student ID $studentId already enrolled in Course ID $courseId');
    }
    // Enroll student into course
    course.studentIds.add(studentId);
  }

  // Task 3 — Remove a student from a course
  void discardStudentFromCourse(
      {required String studentId, required String courseId}) {
    // Validate preconditions
    final course =
        _validateStudentEnrollment(studentId: studentId, courseId: courseId);

    // Un-enroll student from the course
    course.studentIds.remove(studentId);

    // Remove score reference from both the course and LMS
    final scoreId = "$studentId-$courseId";
    course.scoreIds.remove(scoreId);
    scores.removeWhere((score) => score.id == scoreId);
  }

  // Task 4 — Add a result to a course
  void addResult(
      {required String studentId,
      required String courseId,
      required int score}) {
    if (score < 0 || score > 100) {
      throw Exception('Score must be between 0 and 100');
    }

    final course =
        _validateStudentEnrollment(studentId: studentId, courseId: courseId);

    // Create Score ID
    final scoreId = "$studentId-$courseId";

    if (scores.any((score) => score.id == scoreId)) {
      throw Exception(
          'Score already exists for student $studentId in course $courseId');
    }

    scores.add(Score(scoreId, score));
    course.scoreIds.add(scoreId);
  }

  void addStudent({required String studentId, required String studentName}) {
    // ! Student shall not exist already
    Student? student = _findStudentOrNull(studentId);
    if (student != null) {
      throw Exception('Student $student already exists');
    }
    students.add(Student(id: studentId, name: studentName));
  }

  void removeStudent({required String studentId}) {
    Student? student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student $studentId not found');
    }
    // 1- Remove student from the students list
    students.removeWhere((student) => student.id == studentId);
  }

  // Task 5 — Remove a student result
  void removeResult({required String studentId, required String courseId}) {
    // Verify course exists
    final course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course ID $courseId does not exist!');
    }

    // Verify student exists
    final student = _findStudentOrNull(studentId);
    if (student == null) {
      throw Exception('Student ID $studentId does not exist!');
    }

    // Verify result exist
    final scoreId = "$studentId-$courseId";
    final scoreExists = scores.any((score) => score.id == scoreId);
    if (!scoreExists) {
      throw Exception(
          'Result for student $studentId in course $courseId does not exist!');
    }

    // Remove score reference from both the course and the LMS
    course.scoreIds.remove(scoreId);
    scores.removeWhere((score) => score.id == scoreId);
  }

  // Helper function
  Student? _findStudentOrNull(String studentId) {
    for (Student s in students) {
      if (s.id == studentId) {
        return s;
      }
    }
    return null; // not found
  }

  Course? _findCourseOrNull(String courseId) {
    for (Course c in courses) {
      if (c.id == courseId) return c;
    }
    return null; // not found
  }

  Course _validateStudentEnrollment(
      {required String studentId, required String courseId}) {
    if (_findStudentOrNull(studentId) == null) {
      throw Exception('Student $studentId does not exist!');
    }

    final course = _findCourseOrNull(courseId);
    if (course == null) {
      throw Exception('Course $courseId does not exist!');
    }

    if (!course.studentIds.contains(studentId)) {
      throw Exception('Student $studentId is not enrolled in course $courseId');
    }

    return course;
  }
}

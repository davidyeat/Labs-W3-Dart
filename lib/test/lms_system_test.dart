import 'package:test/test.dart';
import '../service/lms_system.dart';

void main() {
  group('LmsSystem#Student', () {
    test('Create & Remove students', () {
      final lms = LmsSystem();

      // Create students
      lms.addStudent(studentId: 'S1', studentName: 'Ronan');
      lms.addStudent(studentId: 'S2', studentName: 'Bob');
      expect(lms.students.first.name, 'Ronan');
      expect(lms.students.length, 2);

      // Remove the student
      lms.removeStudent(studentId: 'S1');
      expect(lms.students.length, 1);
    });
  });

  group('LmsSystem#Course', () {
    final lms = LmsSystem();

    test('Create & Remove courses', () {
      lms.addCourse(courseId: 'C01', courseName: 'Dart');
      lms.addCourse(courseId: 'C02', courseName: 'Java');
      expect(lms.courses.length, 2);

      // Remove the course
      lms.removeCourse(courseId: 'C02');
      expect(lms.courses.length, 1);
    });

    test('Reject a duplicate course ID', () {
      expect(() => lms.addCourse(courseId: 'C01', courseName: 'JavaScript'),
          throwsException);
    });

    test('Reject removal of a nonexistent course', () {
      expect(() => lms.removeCourse(courseId: 'C02'), throwsException);
    });
  });

  group('LmsSystem#enrollStudent', () {
    final lms = LmsSystem();

    // Create student & course
    lms.addStudent(studentId: 'S1', studentName: 'David');
    lms.addStudent(studentId: 'S2', studentName: 'Bob');
    lms.addCourse(courseId: 'C1', courseName: 'Dart');

    test('Enroll student to course', () {
      lms.enrollStudent(studentId: 'S1', courseId: 'C1');
      lms.enrollStudent(studentId: 'S2', courseId: 'C1');
      expect(lms.courses[0].studentIds.length, 2);
    });

    test('Reject enrollment if the student does not exist', () {
      expect(
        () => lms.enrollStudent(studentId: 'S2', courseId: 'C1'),
        throwsException,
      );
    });

    test('Reject enrollment if the course does not exist', () {
      expect(() => lms.enrollStudent(studentId: 'S1', courseId: 'C2'),
          throwsException);
    });

    test('Reject duplicate enrollment', () {
      expect(() => lms.enrollStudent(studentId: 'S1', courseId: 'C1'),
          throwsException);
    });
  });

  group('LmsSystem#UnenrollStudent', () {
    final lms = LmsSystem();

    // 1- Create students and course
    lms.addStudent(studentId: 'S001', studentName: 'David');
    lms.addStudent(studentId: 'S002', studentName: 'Bob');
    lms.addStudent(studentId: 'S003', studentName: 'Leo');
    lms.addCourse(courseId: 'C001', courseName: 'Mobile Development');
    lms.addCourse(courseId: 'C002', courseName: 'Game Development');

    // 2- Enrollment
    lms.enrollStudent(studentId: 'S001', courseId: 'C001');
    lms.enrollStudent(studentId: 'S001', courseId: 'C002');
    lms.enrollStudent(studentId: 'S002', courseId: 'C002');

    // Test-1:
    test('Remove an existing enrollment.', () {
      final c002 = lms.courses.firstWhere((c) => c.id == 'C002');
      expect(c002.studentIds, contains('S002'));

      lms.discardStudentFromCourse(studentId: 'S002', courseId: 'C002');

      expect(c002.studentIds, isNot(contains('S002')));
    });

    // Test-2:
    test('Reject removal of a nonexistent enrollment.', () {
      // S003 is not enrolled in C001
      expect(
        () => lms.discardStudentFromCourse(studentId: 'S003', courseId: 'C001'),
        throwsException,
      );

      // S002 was already removed from C002
      expect(
        () => lms.discardStudentFromCourse(studentId: 'S002', courseId: 'C002'),
        throwsException,
      );

      // Student does not exist
      expect(
        () => lms.discardStudentFromCourse(studentId: 'S999', courseId: 'C001'),
        throwsException,
      );

      // Course does not exist
      expect(
        () => lms.discardStudentFromCourse(studentId: 'S001', courseId: 'C999'),
        throwsException,
      );
    });

    // Test-3:
    test(
        'Verify that the student and course still exist after the enrollment is removed.',
        () {
      // S002 was removed from C002, but both student and course still exist in LMS
      expect(lms.students.any((s) => s.id == 'S002'), isTrue);
      expect(lms.courses.any((c) => c.id == 'C002'), isTrue);

      final c002 = lms.courses.firstWhere((c) => c.id == 'C002');
      expect(c002.studentIds, isNot(contains('S002')));
    });

    // Test-4:
    test('Verify the chosen policy for associated results.', () {
      // Enroll S003 into C001 and add a score result
      lms.enrollStudent(studentId: 'S003', courseId: 'C001');
      lms.addResult(studentId: 'S003', courseId: 'C001', score: 85);

      final c001 = lms.courses.firstWhere((c) => c.id == 'C001');
      final scoreId = 'S003-C001';

      expect(c001.scoreIds, contains(scoreId));
      expect(lms.scores.any((s) => s.id == scoreId), isTrue);

      // Discard S003 from C001
      lms.discardStudentFromCourse(studentId: 'S003', courseId: 'C001');

      // Verify associated results are removed from both course and system
      expect(c001.studentIds, isNot(contains('S003')));
      expect(c001.scoreIds, isNot(contains(scoreId)));
      expect(lms.scores.any((s) => s.id == scoreId), isFalse);
    });

    // Test-5:
    test('Test removing a student who has enrollments in multiple courses.',
        () {
      final c001 = lms.courses.firstWhere((c) => c.id == 'C001');
      final c002 = lms.courses.firstWhere((c) => c.id == 'C002');

      // S001 is enrolled in both C001 and C002
      expect(c001.studentIds, contains('S001'));
      expect(c002.studentIds, contains('S001'));

      // Discard S001 only from C001
      lms.discardStudentFromCourse(studentId: 'S001', courseId: 'C001');

      // S001 is removed from C001, but remains enrolled in C002
      expect(c001.studentIds, isNot(contains('S001')));
      expect(c002.studentIds, contains('S001'));

      // Student S001 still exists in the system
      expect(lms.students.any((s) => s.id == 'S001'), isTrue);
    });
  });

  group('LmsSystem#removeResult', () {
    final lms = LmsSystem();

    // 1- Create students and Courses
    lms.addStudent(studentId: 'S001', studentName: 'David');
    lms.addStudent(studentId: 'S002', studentName: 'Bob');
    lms.addStudent(studentId: 'S003', studentName: 'Leo');
    lms.addCourse(courseId: 'C001', courseName: 'Mobile Development');
    lms.addCourse(courseId: 'C002', courseName: 'Game Development');

    // 2- Enrollments
    lms.enrollStudent(studentId: 'S001', courseId: 'C001');
    lms.enrollStudent(studentId: 'S001', courseId: 'C002');
    lms.enrollStudent(studentId: 'S002', courseId: 'C001');

    // 3 Add scores/results
    lms.addResult(studentId: 'S001', courseId: 'C001', score: 95);
    lms.addResult(studentId: 'S001', courseId: 'C002', score: 88);
    lms.addResult(studentId: 'S002', courseId: 'C001', score: 75);

    // Test-1:
    test('Remove an existing result.', () {
      final c001 = lms.courses.firstWhere((c) => c.id == 'C001');
      final scoreId = 'S001-C001';

      expect(c001.scoreIds, contains(scoreId));
      expect(lms.scores.any((s) => s.id == scoreId), isTrue);

      lms.removeResult(studentId: 'S001', courseId: 'C001');

      expect(c001.scoreIds, isNot(contains(scoreId)));
      expect(lms.scores.any((s) => s.id == scoreId), isFalse);
    });

    // Test-2:
    test('Reject removal of a nonexistent result.', () {
      // Result was already remove in Test-1
      expect(() => lms.removeResult(studentId: 'S001', courseId: 'C001'),
          throwsException);

      // Student exists and course exists, but student has no result in that course
      expect(() => lms.removeResult(studentId: 'S002', courseId: 'C002'),
          throwsException);

      // Student does not exist
      expect(() => lms.removeResult(studentId: 'S999', courseId: 'C001'),
          throwsException);

      // Course does not exist
      expect(() => lms.removeResult(studentId: 'S001', courseId: 'C999'),
          throwsException);
    });

    // Test-3:
    test('Verify that the result is no longer availabe.', () {
      final c001 = lms.courses.firstWhere((c) => c.id == 'C001');
      final scoreId = 'S001-C001';

      // Verify the result is not present in the course's scores list
      expect(c001.scoreIds, isNot(contains(scoreId)));

      // Verify the result is not present in the LMS global scores list
      expect(lms.scores.any((s) => s.id == scoreId), isFalse);

      // Verify removing result duplicate is rejected
      expect(() => lms.removeResult(studentId: 'S001', courseId: 'C001'),
          throwsException);
    });

    // Test-4:
    test(
        'Verify that the student, course, and unrelated result remain unchanged.',
        () {
      // Verify student S001 still exists in LMS
      expect(lms.students.any((s) => s.id == 'S001'), isTrue);
      final s001 = lms.students.firstWhere((s) => s.id == 'S001');
      expect(s001.name, 'David');

      // Verify course C001 still exists in LMS
      expect(lms.courses.any((c) => c.id == 'C001'), isTrue);
      final c001 = lms.courses.firstWhere((c) => c.id == 'C001');
      expect(c001.name, 'Mobile Development');

      // Verify removing score does not uneroll
      expect(c001.studentIds, contains('S001'));

      // Verify unrelated result for the same student in a different course (S001 in C002)
      final c002 = lms.courses.firstWhere((c) => c.id == 'C002');
      expect(c002.scoreIds, contains('S001-C002'));
      final scoreS001C002 = lms.scores.firstWhere((s) => s.id == 'S001-C002');
      expect(scoreS001C002.score, 88);

      // Verify unrelated result from another student in the same course (S002 in C001)
      expect(c001.scoreIds, contains('S002-C001'));
      final scoreS002C001 = lms.scores.firstWhere((s) => s.id == 'S002-C001');
      expect(scoreS002C001.score, 75);
    });
  });
}

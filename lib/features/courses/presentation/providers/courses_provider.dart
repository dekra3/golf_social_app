import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/courses_repository.dart';
import '../../data/models/course_model.dart';

final coursesRepositoryProvider = Provider<CoursesRepository>((ref) {
  return CoursesRepository(ref.watch(supabaseClientProvider));
});

final coursesListProvider = FutureProvider.autoDispose<List<Course>>((ref) async {
  return ref.watch(coursesRepositoryProvider).getCourses();
});
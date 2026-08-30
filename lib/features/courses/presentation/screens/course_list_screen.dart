import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../profile/presentation/providers/profile_provider.dart';
import '../providers/courses_provider.dart';

/// Shown when starting a round: pick an existing course. Adding a new
/// course is course-admin only — the FAB only shows for admins.
class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesListProvider);
    final isAdmin = ref.watch(currentProfileProvider).value?.isCourseAdmin ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Choose a course')),
      floatingActionButton: isAdmin
          ? FloatingActionButton(
              onPressed: () => context.push('/courses/add'),
              child: const Icon(Icons.add),
            )
          : null,
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Could not load courses: $err')),
        data: (courses) {
          if (courses.isEmpty) {
            return Center(
              child: Text(
                isAdmin
                    ? 'No courses yet — tap + to add one.'
                    : 'No courses yet — ask a course admin to add one.',
              ),
            );
          }
          return ListView.builder(
            itemCount: courses.length,
            itemBuilder: (context, index) {
              final course = courses[index];
              return ListTile(
                title: Text(course.name),
                subtitle: course.city != null ? Text(course.city!) : null,
                onTap: () => context.push('/rounds/start/${course.id}'),
                trailing: IconButton(
                  icon: const Icon(Icons.info_outline),
                  tooltip: 'View tees',
                  onPressed: () => context.push('/courses/${course.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
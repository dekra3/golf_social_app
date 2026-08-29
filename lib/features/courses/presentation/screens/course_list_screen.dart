import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/courses_provider.dart';

/// Shown when starting a round: pick an existing course, or add a new one.
class CourseListScreen extends ConsumerWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final coursesAsync = ref.watch(coursesListProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Choose a course')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/courses/add'),
        child: const Icon(Icons.add),
      ),
      body: coursesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Could not load courses: $err')),
        data: (courses) {
          if (courses.isEmpty) {
            return const Center(child: Text('No courses yet — tap + to add one.'));
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
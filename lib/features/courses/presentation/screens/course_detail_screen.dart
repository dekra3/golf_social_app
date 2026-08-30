import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../profile/presentation/providers/profile_provider.dart';
import '../../data/models/course_model.dart';
import '../../data/models/tee_model.dart';
import '../providers/courses_provider.dart';

class CourseDetailScreen extends ConsumerStatefulWidget {
  const CourseDetailScreen({super.key, required this.courseId});

  final String courseId;

  @override
  ConsumerState<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends ConsumerState<CourseDetailScreen> {
  Course? _course;
  List<Tee>? _tees;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final course = await ref.read(coursesRepositoryProvider).getCourseById(widget.courseId);
      final tees = await ref.read(coursesRepositoryProvider).getTeesForCourse(widget.courseId);
      setState(() {
        _course = course;
        _tees = tees;
      });
    } catch (e) {
      setState(() => _error = 'Could not load course: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final course = _course;
    final tees = _tees;
    final isAdmin = ref.watch(currentProfileProvider).value?.isCourseAdmin ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(course?.name ?? 'Course')),
      floatingActionButton: (course == null || !isAdmin)
          ? null
          : FloatingActionButton.extended(
              icon: const Icon(Icons.add),
              label: const Text('Add tee'),
              onPressed: () async {
                await context.push('/courses/${course.id}/add-tee');
                _load();
              },
            ),
      body: _error != null
          ? Center(child: Text(_error!))
          : (course == null || tees == null)
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(24),
                  children: [
                    if (course.city != null || course.country != null)
                      Text([course.city, course.country].whereType<String>().join(', ')),
                    const SizedBox(height: 16),
                    Text('Tees', style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    if (tees.isEmpty) const Text('No tees set up yet.'),
                    ...tees.map(
                      (tee) => Card(
                        child: ListTile(
                          title: Text(tee.name),
                          subtitle: Text(
                            [
                              'Par ${tee.par}',
                              if (tee.yardage != null) '${tee.yardage} yds',
                              if (tee.rating != null) 'Rating ${tee.rating}',
                              if (tee.slope != null) 'Slope ${tee.slope}',
                            ].join(' • '),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
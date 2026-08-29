import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../courses/data/models/course_model.dart';
import '../../../courses/data/models/tee_model.dart';
import '../../../courses/presentation/providers/courses_provider.dart';
import '../../../groups/data/models/group_model.dart';
import '../../../groups/presentation/providers/groups_provider.dart';
import '../providers/tournaments_provider.dart';

const _formats = {
  'stroke_play': 'Stroke play',
  'match_play': 'Match play',
  'scramble': 'Scramble',
  'stableford': 'Stableford',
};

class CreateTournamentScreen extends ConsumerStatefulWidget {
  const CreateTournamentScreen({super.key});

  @override
  ConsumerState<CreateTournamentScreen> createState() => _CreateTournamentScreenState();
}

class _CreateTournamentScreenState extends ConsumerState<CreateTournamentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  String _format = 'stroke_play';
  Course? _selectedCourse;
  Tee? _selectedTee;
  List<Tee> _teesForCourse = [];
  Group? _selectedGroup;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _onCourseSelected(Course? course) async {
    setState(() {
      _selectedCourse = course;
      _selectedTee = null;
      _teesForCourse = [];
    });
    if (course == null) return;
    final tees = await ref.read(coursesRepositoryProvider).getTeesForCourse(course.id);
    setState(() => _teesForCourse = tees);
  }

  Future<void> _pickDate({required bool isStart}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isStart ? _startDate : (_endDate ?? _startDate),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
      } else {
        _endDate = picked;
      }
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCourse == null || _selectedTee == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pick a course and tee')),
      );
      return;
    }
    final user = ref.read(currentUserProvider);
    if (user == null) return;

    setState(() => _isSaving = true);
    try {
      final tournament = await ref.read(tournamentsRepositoryProvider).createTournament(
            name: _nameController.text.trim(),
            format: _format,
            courseId: _selectedCourse!.id,
            teeId: _selectedTee!.id,
            startDate: _startDate,
            endDate: _endDate,
            groupId: _selectedGroup?.id,
            createdBy: user.id,
          );
      ref.invalidate(myTournamentsProvider);
      if (mounted) context.pushReplacement('/tournaments/${tournament.id}');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final coursesAsync = ref.watch(coursesListProvider);
    final myGroupsAsync = ref.watch(myGroupsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Create a tournament')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tournament name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: _format,
              decoration: const InputDecoration(labelText: 'Format'),
              items: _formats.entries
                  .map((e) => DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: (v) => setState(() => _format = v ?? _format),
            ),
            const SizedBox(height: 16),
            coursesAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Could not load courses: $err'),
              data: (courses) => DropdownButtonFormField<Course>(
                initialValue: _selectedCourse,
                decoration: const InputDecoration(labelText: 'Course'),
                items: courses
                    .map((c) => DropdownMenuItem(value: c, child: Text(c.name)))
                    .toList(),
                onChanged: _onCourseSelected,
                validator: (v) => v == null ? 'Required' : null,
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<Tee>(
              initialValue: _selectedTee,
              decoration: const InputDecoration(labelText: 'Tee'),
              items: _teesForCourse
                  .map((t) => DropdownMenuItem(value: t, child: Text('${t.name} (par ${t.par})')))
                  .toList(),
              onChanged: _teesForCourse.isEmpty ? null : (v) => setState(() => _selectedTee = v),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            myGroupsAsync.when(
              loading: () => const LinearProgressIndicator(),
              error: (err, _) => Text('Could not load groups: $err'),
              data: (groups) => DropdownButtonFormField<Group?>(
                initialValue: _selectedGroup,
                decoration: const InputDecoration(labelText: 'Restrict to a group (optional)'),
                items: [
                  const DropdownMenuItem<Group?>(value: null, child: Text('Open to everyone')),
                  ...groups.map((g) => DropdownMenuItem(value: g, child: Text(g.name))),
                ],
                onChanged: (v) => setState(() => _selectedGroup = v),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start date'),
              subtitle: Text('${_startDate.month}/${_startDate.day}/${_startDate.year}'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isStart: true),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('End date (optional)'),
              subtitle: Text(
                _endDate == null
                    ? 'Not set'
                    : '${_endDate!.month}/${_endDate!.day}/${_endDate!.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () => _pickDate(isStart: false),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Create tournament'),
            ),
          ],
        ),
      ),
    );
  }
}
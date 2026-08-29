import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/courses_provider.dart';

class AddCourseScreen extends ConsumerStatefulWidget {
  const AddCourseScreen({super.key});

  @override
  ConsumerState<AddCourseScreen> createState() => _AddCourseScreenState();
}

class _AddCourseScreenState extends ConsumerState<AddCourseScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _teeNameController = TextEditingController(text: 'White');
  late final List<TextEditingController> _parControllers;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    // Default every hole to par 4 — a reasonable starting point users can edit.
    _parControllers = List.generate(18, (_) => TextEditingController(text: '4'));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _teeNameController.dispose();
    for (final c in _parControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final pars = _parControllers.map((c) => int.parse(c.text)).toList();
      await ref.read(coursesRepositoryProvider).createCourseWithFirstTee(
            name: _nameController.text.trim(),
            city: _cityController.text.trim().isEmpty ? null : _cityController.text.trim(),
            country:
                _countryController.text.trim().isEmpty ? null : _countryController.text.trim(),
            teeName: _teeNameController.text.trim(),
            holePars: pars,
          );
      ref.invalidate(coursesListProvider);
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add a course')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Course name'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cityController,
              decoration: const InputDecoration(labelText: 'City (optional)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _countryController,
              decoration: const InputDecoration(labelText: 'Country (optional)'),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _teeNameController,
              decoration: const InputDecoration(labelText: 'Tee name (e.g. White, Blue, Red)'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            Text('Par per hole', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 18,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                return TextFormField(
                  controller: _parControllers[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(labelText: 'H${index + 1}'),
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    return (n == null || n < 3 || n > 6) ? '3-6' : null;
                  },
                );
              },
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
                  : const Text('Save course'),
            ),
          ],
        ),
      ),
    );
  }
}
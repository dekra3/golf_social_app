import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/models/tee_model.dart';
import '../providers/courses_provider.dart';

/// Pars aren't editable here — same reasoning as AddTeeScreen, they're
/// fixed per course, not per tee. Only name/rating/slope/yardage change.
class EditTeeScreen extends ConsumerStatefulWidget {
  const EditTeeScreen({super.key, required this.teeId});

  final String teeId;

  @override
  ConsumerState<EditTeeScreen> createState() => _EditTeeScreenState();
}

class _EditTeeScreenState extends ConsumerState<EditTeeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ratingController = TextEditingController();
  final _slopeController = TextEditingController();
  late final List<TextEditingController> _yardageControllers;

  List<Hole>? _holes;
  bool _isSaving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _yardageControllers = List.generate(18, (_) => TextEditingController());
    _load();
  }

  Future<void> _load() async {
    try {
      final tee = await ref.read(coursesRepositoryProvider).getTeeById(widget.teeId);
      final holes = await ref.read(coursesRepositoryProvider).getHolesForTee(widget.teeId);

      _nameController.text = tee.name;
      _ratingController.text = tee.rating?.toString() ?? '';
      _slopeController.text = tee.slope?.toString() ?? '';
      for (var i = 0; i < holes.length && i < 18; i++) {
        _yardageControllers[i].text = holes[i].yardage?.toString() ?? '';
      }

      setState(() => _holes = holes);
    } catch (e) {
      setState(() => _error = 'Could not load tee: $e');
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ratingController.dispose();
    _slopeController.dispose();
    for (final c in _yardageControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      final yardages = _yardageControllers.map((c) => int.tryParse(c.text.trim())).toList();
      await ref.read(coursesRepositoryProvider).updateTee(
            teeId: widget.teeId,
            name: _nameController.text.trim(),
            rating: double.tryParse(_ratingController.text.trim()),
            slope: int.tryParse(_slopeController.text.trim()),
            holeYardages: yardages,
          );
      if (mounted) context.pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Scaffold(appBar: AppBar(title: const Text('Edit tee')), body: Center(child: Text(_error!)));
    }
    final holes = _holes;
    if (holes == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit tee')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Tee name (e.g. Blue, Red)'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _ratingController,
                    decoration: const InputDecoration(labelText: 'Rating (optional)'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _slopeController,
                    decoration: const InputDecoration(labelText: 'Slope (optional)'),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text('Par (fixed per course)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final hole in holes) Chip(label: Text('H${hole.holeNumber} · Par ${hole.par}')),
              ],
            ),
            const SizedBox(height: 24),
            Text('Yardage per hole (optional)', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 18,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
                childAspectRatio: 2,
              ),
              itemBuilder: (context, index) {
                return TextFormField(
                  controller: _yardageControllers[index],
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(labelText: 'H${index + 1} yds'),
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
                  : const Text('Save changes'),
            ),
          ],
        ),
      ),
    );
  }
}
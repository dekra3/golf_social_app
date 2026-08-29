import 'package:supabase_flutter/supabase_flutter.dart';

import 'models/course_model.dart';
import 'models/tee_model.dart';

class CoursesRepository {
  CoursesRepository(this._client);

  final SupabaseClient _client;

  Future<List<Course>> getCourses() async {
    final data = await _client.from('courses').select().order('name');
    return (data as List).map((row) => Course.fromJson(row)).toList();
  }

  Future<Course> getCourseById(String courseId) async {
    final data = await _client.from('courses').select().eq('id', courseId).single();
    return Course.fromJson(data);
  }

  Future<List<Tee>> getTeesForCourse(String courseId) async {
    final data = await _client.from('tees').select().eq('course_id', courseId);
    return (data as List).map((row) => Tee.fromJson(row)).toList();
  }

  Future<List<Hole>> getHolesForTee(String teeId) async {
    final data =
        await _client.from('holes').select().eq('tee_id', teeId).order('hole_number');
    return (data as List).map((row) => Hole.fromJson(row)).toList();
  }

  /// Creates a course with its first named tee and 18 holes in one go.
  /// [holePars] must have exactly 18 entries.
  Future<Tee> createCourseWithFirstTee({
    required String name,
    String? city,
    String? country,
    required String teeName,
    required List<int> holePars,
  }) async {
    final courseRow = await _client
        .from('courses')
        .insert({'name': name, 'city': city, 'country': country})
        .select()
        .single();
    final course = Course.fromJson(courseRow);

    return addTee(courseId: course.id, name: teeName, holePars: holePars);
  }

  /// Adds another tee to an existing course. Pars don't vary by tee in real
  /// golf — only yardage/rating/slope do — so callers should pass the same
  /// [holePars] as the course's existing tees; [holeYardages] is the part
  /// that actually differs per tee. [holePars] must have exactly 18 entries.
  Future<Tee> addTee({
    required String courseId,
    required String name,
    required List<int> holePars,
    List<int?>? holeYardages,
    double? rating,
    int? slope,
  }) async {
    assert(holePars.length == 18, 'Provide a par for all 18 holes');
    assert(holeYardages == null || holeYardages.length == 18);

    final totalPar = holePars.reduce((a, b) => a + b);
    final hasFullYardage = holeYardages != null && holeYardages.every((y) => y != null);
    final totalYardage = hasFullYardage ? holeYardages.cast<int>().reduce((a, b) => a + b) : null;

    final teeRow = await _client
        .from('tees')
        .insert({
          'course_id': courseId,
          'name': name,
          'par': totalPar,
          'rating': rating,
          'slope': slope,
          'yardage': totalYardage,
        })
        .select()
        .single();
    final tee = Tee.fromJson(teeRow);

    await _client.from('holes').insert([
      for (var i = 0; i < 18; i++)
        {
          'tee_id': tee.id,
          'hole_number': i + 1,
          'par': holePars[i],
          'yardage': holeYardages != null ? holeYardages[i] : null,
        },
    ]);

    return tee;
  }
}
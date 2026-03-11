import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:task_companion/core/log/logger.dart';

class ResourceServices {
  final supabase = Supabase.instance.client;

  Future<bool> addResource(Map<String, dynamic> resource) async {
    try {
      final response = await supabase
          .from('resources')
          .insert({
            'project_id': resource['project_id'],
            'name': resource['name'],
            'type': resource['type'],
            'allocated_amount': resource['allocated_amount'],
            'unit': resource['unit'],
          })
          .select()
          .maybeSingle();

      return response != null;
    } catch (e, st) {
      appLogger.e(
        "Erro creating resource quantity",
        error: e,
        stackTrace: st,
        time: DateTime.now(),
      );
      return false;
    }
  }

  Future<void> deleteResource(String resourceId) async {
    try {
      await supabase.from('resources').delete().eq("id", resourceId);

      appLogger.i("Resource quantity deleted");
    } catch (e, st) {
      appLogger.e(
        "Erro deleting resource quantity",
        error: e,
        stackTrace: st,
        time: DateTime.now(),
      );
    }
  }

  Future<void> updateResourceQuantity(
    String resourceId,
    double quantity,
  ) async {
    try {
      await supabase
          .from('resources')
          .update({'allocated_amount': quantity})
          .eq("id", resourceId);

      appLogger.i("Resource quantity updated");
    } catch (e, st) {
      appLogger.e(
        "Erro updating resource quantity",
        error: e,
        stackTrace: st,
        time: DateTime.now(),
      );
    }
  }
}

final resourceServiceProvider = Provider((ref) => ResourceServices());

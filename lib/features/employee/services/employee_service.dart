import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import 'dart:math';
import '../models/employee.dart';

class EmployeeService {
  final supabase.SupabaseClient _supabase = supabase.Supabase.instance.client;

  Future<String> generateEmployeeNumber() async {
    try {
      final year = DateTime.now().year;
      final random = Random();
      final randomNum = random.nextInt(9000) + 1000; // 4-digit random number

      // Get the last employee to determine sequence number
      final response = await _supabase
          .from('employees')
          .select('employee_number')
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      int sequenceNum = 1;
      if (response != null) {
        final lastNumber = response['employee_number'] as String;
        final parts = lastNumber.split('-');
        if (parts.length == 4) {
          sequenceNum = int.parse(parts[3]) + 1;
        }
      }

      return 'EMP-$year-$randomNum-$sequenceNum';
    } catch (e) {
      print('Error generating employee number: $e');
      // Fallback format if there's an error
      final random = Random();
      return 'EMP-${DateTime.now().year}-${1000 + random.nextInt(9000)}-1';
    }
  }

  Future<Employee?> getEmployeeById(String id) async {
    try {
      final response =
          await _supabase.from('employees').select().eq('id', id).single();

      return Employee.fromJson(response);
    } catch (e) {
      return null;
    }
  }

  Future<List<Employee>> getAllEmployees() async {
    final response = await _supabase
        .from('employees')
        .select()
        .order('employee_number', ascending: false);

    return response
        .map((json) => Employee.fromJson(json))
        .toList();
  }

  Future<Employee> createEmployee(Employee employee) async {
    final response = await _supabase
        .from('employees')
        .insert(employee.toJson())
        .select()
        .single();

    return Employee.fromJson(response);
  }

  Future<Employee> updateEmployee(Employee employee) async {
    final response = await _supabase
        .from('employees')
        .update(employee.toJson())
        .eq('id', employee.id)
        .select()
        .single();

    return Employee.fromJson(response);
  }

  Future<void> deleteEmployee(String id) async {
    await _supabase.from('employees').delete().eq('id', id);
  }
}

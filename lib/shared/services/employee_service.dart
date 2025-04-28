import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/employee.dart';
import '../../core/config/supabase_config.dart';

class EmployeeService {
  final SupabaseClient _client = Supabase.instance.client;

  // Get all employees
  Future<List<Employee>> getAllEmployees() async {
    final response = await _client.from(SupabaseConfig.employeesTable).select();

    return (response as List).map((json) => Employee.fromJson(json)).toList();
  }

  // Get employee by ID
  Future<Employee?> getEmployeeById(int id) async {
    final response = await _client
        .from(SupabaseConfig.employeesTable)
        .select()
        .eq('id', id)
        .single();

    return Employee.fromJson(response);
  }

  // Create new employee
  Future<Employee> createEmployee(Employee employee) async {
    final response = await _client
        .from(SupabaseConfig.employeesTable)
        .insert(employee.toJson())
        .select()
        .single();

    return Employee.fromJson(response);
  }

  // Update employee
  Future<Employee> updateEmployee(Employee employee) async {
    final id = employee.id;
    if (id == null) {
      throw Exception('Employee ID cannot be null');
    }

    final response = await _client
        .from(SupabaseConfig.employeesTable)
        .update(employee.toJson())
        .eq('id', id)
        .select()
        .single();

    return Employee.fromJson(response);
  }

  // Delete employee
  Future<void> deleteEmployee(int id) async {
    await _client.from(SupabaseConfig.employeesTable).delete().eq('id', id);
  }

  // Upload profile picture
  Future<String> uploadProfilePicture(
      String filePath, String employeeNumber) async {
    final file = File(filePath);
    final fileExt = filePath.split('.').last;
    final fileName = 'profile_$employeeNumber.$fileExt';

    await _client.storage
        .from(SupabaseConfig.profilePicturesBucket)
        .upload(fileName, file);

    return _client.storage
        .from(SupabaseConfig.profilePicturesBucket)
        .getPublicUrl(fileName);
  }
}

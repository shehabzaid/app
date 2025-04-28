import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'dart:async';
import '../../../core/config/supabase_config.dart';
import '../models/hospital.dart';
import '../models/department.dart';
import '../models/doctor.dart';

class HospitalService {
  final SupabaseClient _supabase = Supabase.instance.client;

  // Cache for hospitals data
  final Map<String, Hospital> _hospitalCache = {};
  DateTime? _lastCacheUpdate;
  static const _cacheDuration = Duration(minutes: 5);

  // Retry configuration
  static const int _maxRetries = 3;
  static const Duration _retryDelay = Duration(seconds: 1);

  // التحقق من صلاحيات المستخدم
  Future<bool> _isAdmin() async {
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return false;

      final response = await _supabase
          .from('user_profiles')
          .select('role')
          .eq('id', userId)
          .single();

      return response['role'] == 'admin';
    } catch (e) {
      developer.log('Error checking admin status: $e');
      return false;
    }
  }

  // Retry mechanism for network operations
  Future<T> _retryOperation<T>(Future<T> Function() operation) async {
    int attempts = 0;
    while (attempts < _maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        if (attempts == _maxRetries) rethrow;

        developer
            .log('Operation failed, attempt $attempts of $_maxRetries: $e');
        await Future.delayed(_retryDelay * attempts);
      }
    }
    throw Exception('All retry attempts failed');
  }

  // Check and clear cache if needed
  void _checkCache() {
    if (_lastCacheUpdate != null &&
        DateTime.now().difference(_lastCacheUpdate!) > _cacheDuration) {
      _hospitalCache.clear();
      _lastCacheUpdate = null;
    }
  }

  // جلب قائمة المستشفيات
  Future<List<Hospital>> getAllHospitals({bool forceRefresh = false}) async {
    try {
      _checkCache();

      // Return cached data if available and not forcing refresh
      if (!forceRefresh && _hospitalCache.isNotEmpty) {
        developer.log('Returning cached hospitals data');
        return _hospitalCache.values.toList();
      }

      return await _retryOperation(() async {
        developer.log('Fetching hospitals from network...');

        final response = await _supabase
            .from(SupabaseConfig.healthcareFacilitiesTable)
            .select()
            .eq('is_active', true)
            .order('name_arabic');

        developer.log('Hospitals response received');

        if (response == null) {
          developer.log('Response is null');
          return [];
        }

        final hospitals = (response as List)
            .map((json) {
              try {
                final hospital = Hospital.fromJson(json);
                _hospitalCache[hospital.id] = hospital;
                return hospital;
              } catch (e, stackTrace) {
                developer.log('Error parsing hospital: $e');
                developer.log('Stack trace: $stackTrace');
                developer.log('Problematic JSON: $json');
                return null;
              }
            })
            .where((hospital) => hospital != null)
            .cast<Hospital>()
            .toList();

        _lastCacheUpdate = DateTime.now();
        developer.log('Parsed ${hospitals.length} hospitals successfully');
        return hospitals;
      });
    } catch (e, stackTrace) {
      developer.log('Error fetching hospitals: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في جلب قائمة المستشفيات: $e');
    }
  }

  // البحث عن المستشفيات
  Future<List<Hospital>> searchHospitals({
    String? query,
    String? city,
    String? region,
    bool useCache = true,
  }) async {
    try {
      if (useCache) {
        _checkCache();
        if (_hospitalCache.isNotEmpty) {
          return _filterCachedHospitals(query, city, region);
        }
      }

      return await _retryOperation(() async {
        var request = _supabase
            .from(SupabaseConfig.healthcareFacilitiesTable)
            .select()
            .eq('is_active', true);

        if (query != null && query.isNotEmpty) {
          request = request.or(
              'name_arabic.ilike.%$query%,name_english.ilike.%$query%,description.ilike.%$query%');
        }

        if (city != null && city.isNotEmpty) {
          request = request.eq('city', city);
        }

        if (region != null && region.isNotEmpty) {
          request = request.eq('region', region);
        }

        final response = await request.order('name_arabic');
        final hospitals = (response as List)
            .map((json) => Hospital.fromJson(json))
            .where((hospital) => hospital != null)
            .toList();

        // Update cache with new results
        for (var hospital in hospitals) {
          _hospitalCache[hospital.id] = hospital;
        }

        return hospitals;
      });
    } catch (e, stackTrace) {
      developer.log('Error searching hospitals: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في البحث عن المستشفيات: $e');
    }
  }

  // Filter cached hospitals
  List<Hospital> _filterCachedHospitals(
      String? query, String? city, String? region) {
    return _hospitalCache.values.where((hospital) {
      if (query != null && query.isNotEmpty) {
        final searchQuery = query.toLowerCase();
        if (!(hospital.nameArabic?.toLowerCase() ?? '').contains(searchQuery) &&
            !(hospital.nameEnglish?.toLowerCase() ?? '')
                .contains(searchQuery) &&
            !(hospital.description?.toLowerCase() ?? '')
                .contains(searchQuery)) {
          return false;
        }
      }

      if (city != null && city.isNotEmpty && hospital.city != city) {
        return false;
      }

      if (region != null && region.isNotEmpty && hospital.region != region) {
        return false;
      }

      return true;
    }).toList();
  }

  // جلب تفاصيل مستشفى محدد
  Future<Hospital> getHospitalDetails(String hospitalId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.healthcareFacilitiesTable)
          .select()
          .eq('id', hospitalId)
          .single();

      return Hospital.fromJson(response);
    } catch (e) {
      throw Exception('فشل في جلب تفاصيل المستشفى: $e');
    }
  }

  // جلب أقسام مستشفى محدد
  Future<List<Department>> getHospitalDepartments(String hospitalId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.departmentsTable)
          .select()
          .eq('facility_id', hospitalId)
          .eq('is_active', true)
          .order('name_arabic');

      return (response as List)
          .map((json) => Department.fromJson(json))
          .toList();
    } catch (e) {
      throw Exception('فشل في جلب أقسام المستشفى: $e');
    }
  }

  // جلب قائمة المدن
  Future<List<String>> getCities() async {
    try {
      developer.log('Fetching cities...');

      final response = await _supabase
          .from(SupabaseConfig.healthcareFacilitiesTable)
          .select('city')
          .eq('is_active', true);

      developer.log('Cities response: $response');

      final cities = (response as List)
          .map((item) => item['city'] as String)
          .where((city) => city != null && city.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      developer.log('Found ${cities.length} unique cities');
      return cities;
    } catch (e, stackTrace) {
      developer.log('Error fetching cities: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في جلب قائمة المدن: $e');
    }
  }

  // جلب قائمة المناطق
  Future<List<String>> getRegions() async {
    try {
      developer.log('Fetching regions...');

      final response = await _supabase
          .from(SupabaseConfig.healthcareFacilitiesTable)
          .select('region')
          .eq('is_active', true);

      developer.log('Regions response: $response');

      final regions = (response as List)
          .map((item) => item['region'] as String)
          .where((region) => region != null && region.isNotEmpty)
          .toSet()
          .toList()
        ..sort();

      developer.log('Found ${regions.length} unique regions');
      return regions;
    } catch (e, stackTrace) {
      developer.log('Error fetching regions: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في جلب قائمة المناطق: $e');
    }
  }

  // إضافة مستشفى جديد (للمشرفين فقط)
  Future<void> addHospital(Hospital hospital) async {
    try {
      await _supabase
          .from(SupabaseConfig.healthcareFacilitiesTable)
          .insert(hospital.toJson());
    } catch (e) {
      throw Exception('فشل في إضافة المستشفى: $e');
    }
  }

  // تحديث بيانات مستشفى (للمشرفين فقط)
  Future<void> updateHospital(Hospital hospital) async {
    try {
      await _supabase
          .from(SupabaseConfig.healthcareFacilitiesTable)
          .update(hospital.toJson())
          .eq('id', hospital.id);
    } catch (e) {
      throw Exception('فشل في تحديث بيانات المستشفى: $e');
    }
  }

  // تعطيل/حذف مستشفى (للمشرفين فقط)
  Future<void> deactivateHospital(String hospitalId) async {
    try {
      await _supabase
          .from(SupabaseConfig.healthcareFacilitiesTable)
          .update({'is_active': false}).eq('id', hospitalId);
    } catch (e) {
      throw Exception('فشل في تعطيل المستشفى: $e');
    }
  }

  // جلب تفاصيل قسم محدد
  Future<Department> getDepartmentDetails(String departmentId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.departmentsTable)
          .select()
          .eq('id', departmentId)
          .single();

      return Department.fromJson(response);
    } catch (e) {
      throw Exception('فشل في جلب تفاصيل القسم: $e');
    }
  }

  // جلب قائمة الأطباء في قسم محدد
  Future<List<Doctor>> getDepartmentDoctors(String departmentId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.doctorsTable)
          .select()
          .eq('department_id', departmentId)
          .eq('is_active', true)
          .order('name_arabic');

      return (response as List).map((json) => Doctor.fromJson(json)).toList();
    } catch (e) {
      throw Exception('فشل في جلب قائمة الأطباء: $e');
    }
  }

  // جلب قائمة جميع الأطباء
  Future<List<Doctor>> getAllDoctors() async {
    try {
      developer.log('Fetching all doctors');

      final response = await _supabase
          .from(SupabaseConfig.doctorsTable)
          .select()
          .eq('is_active', true)
          .order('name_arabic');

      developer.log('All doctors response received');

      return (response as List).map((json) => Doctor.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('Error fetching all doctors: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في جلب قائمة الأطباء: $e');
    }
  }

  // جلب قائمة الأطباء في مستشفى محدد
  Future<List<Doctor>> getDoctorsByHospital(String hospitalId) async {
    try {
      developer.log('Fetching doctors for hospital: $hospitalId');

      final response = await _supabase
          .from(SupabaseConfig.doctorsTable)
          .select()
          .eq('facility_id', hospitalId)
          .eq('is_active', true)
          .order('name_arabic');

      developer.log('Doctors response received');

      return (response as List).map((json) => Doctor.fromJson(json)).toList();
    } catch (e, stackTrace) {
      developer.log('Error fetching doctors: $e');
      developer.log('Stack trace: $stackTrace');
      throw Exception('فشل في جلب قائمة الأطباء: $e');
    }
  }

  // جلب تفاصيل طبيب محدد
  Future<Doctor> getDoctorDetails(String doctorId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.doctorsTable)
          .select()
          .eq('id', doctorId)
          .single();

      return Doctor.fromJson(response);
    } catch (e) {
      throw Exception('فشل في جلب تفاصيل الطبيب: $e');
    }
  }

  // جلب المواعيد المتاحة لطبيب محدد
  Future<List<Map<String, dynamic>>> getDoctorAvailableAppointments(
    String doctorId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final response = await _supabase
          .from('available_appointments')
          .select()
          .eq('doctor_id', doctorId)
          .eq('is_booked', false)
          .gte('date', startDate.toIso8601String())
          .lte('date', endDate.toIso8601String())
          .order('date')
          .order('start_time');

      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      throw Exception('فشل في جلب المواعيد المتاحة: $e');
    }
  }

  // حجز موعد
  Future<void> bookAppointment({
    required String patientId,
    required String appointmentId,
    String? notes,
  }) async {
    try {
      await _supabase.from(SupabaseConfig.appointmentsTable).insert({
        'id': appointmentId,
        'patient_id': patientId,
        'doctor_id': null, // Will be assigned later
        'facility_id': '', // TODO: Add facility ID
        'department_id': null, // TODO: Add department ID if available
        'appointment_date': DateTime.now().toIso8601String().split('T')[0],
        'appointment_time': '10:00:00', // Default time
        'is_virtual': false,
        'status': 'Pending',
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      throw Exception('فشل في حجز الموعد: $e');
    }
  }

  // إلغاء حجز موعد
  Future<void> cancelAppointment(String bookingId) async {
    try {
      final booking = await _supabase
          .from('bookings')
          .select('appointment_id')
          .eq('id', bookingId)
          .single();

      // تحديث حالة الموعد إلى متاح
      await _supabase
          .from('available_appointments')
          .update({'is_booked': false}).eq('id', booking['appointment_id']);

      // حذف الحجز
      await _supabase.from('bookings').delete().eq('id', bookingId);
    } catch (e) {
      throw Exception('فشل في إلغاء الموعد: $e');
    }
  }
}

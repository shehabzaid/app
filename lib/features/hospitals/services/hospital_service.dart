import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:developer' as developer;
import 'dart:async';
import 'package:uuid/uuid.dart';
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
          .from(SupabaseConfig.usersTable)
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
      developer.log('Fetching departments for hospital: $hospitalId');

      final response = await _supabase
          .from(SupabaseConfig.departmentsTable)
          .select()
          .eq('facility_id', hospitalId)
          .eq('is_active', true)
          .order('name_arabic');

      developer.log('Departments response: $response');

      if (response is List && response.isEmpty) {
        developer.log('No departments found for hospital: $hospitalId');
        return [];
      }

      final departments = (response as List)
          .map((json) {
            try {
              return Department.fromJson(json);
            } catch (e) {
              developer.log('Error parsing department: $e');
              developer.log('Department JSON: $json');
              return null;
            }
          })
          .where((dept) => dept != null)
          .cast<Department>()
          .toList();

      developer.log('Found ${departments.length} departments');
      return departments;
    } catch (e) {
      developer.log('Error fetching departments: $e');
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
      developer.log('Fetching department details for ID: $departmentId');

      final response = await _supabase
          .from(SupabaseConfig.departmentsTable)
          .select()
          .eq('id', departmentId)
          .single();

      developer.log('Department details response: $response');

      return Department.fromJson(response);
    } catch (e) {
      developer.log('Error fetching department details: $e');
      throw Exception('فشل في جلب تفاصيل القسم: $e');
    }
  }

  // جلب قائمة الأطباء في قسم محدد
  Future<List<Doctor>> getDepartmentDoctors(String departmentId) async {
    try {
      developer.log('Fetching doctors for department: $departmentId');

      final response = await _supabase
          .from(SupabaseConfig.doctorsTable)
          .select()
          .eq('department_id', departmentId)
          .eq('is_active', true)
          .order('name_arabic');

      developer.log('Department doctors response: $response');

      if (response is List && response.isEmpty) {
        developer.log('No doctors found for department: $departmentId');
        return [];
      }

      final doctors = (response as List)
          .map((json) {
            try {
              return Doctor.fromJson(json);
            } catch (e) {
              developer.log('Error parsing doctor: $e');
              developer.log('Doctor JSON: $json');
              return null;
            }
          })
          .where((doc) => doc != null)
          .cast<Doctor>()
          .toList();

      developer.log('Found ${doctors.length} doctors in department');
      return doctors;
    } catch (e) {
      developer.log('Error fetching department doctors: $e');
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

  // جلب الطبيب بواسطة معرف المستخدم
  Future<Doctor?> getDoctorByUserId(String userId) async {
    try {
      final response = await _supabase
          .from(SupabaseConfig.doctorsTable)
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (response == null) return null;

      return Doctor.fromJson(response);
    } catch (e) {
      developer.log('Error fetching doctor by user ID: $e');
      return null;
    }
  }

  // ربط الطبيب بحساب مستخدم
  Future<bool> linkDoctorToUser(String doctorId, String userId) async {
    try {
      // التحقق من أن المستخدم موجود
      final userExists = await _supabase
          .from(SupabaseConfig.usersTable)
          .select('id')
          .eq('id', userId)
          .maybeSingle();

      if (userExists == null) {
        throw Exception('المستخدم غير موجود');
      }

      // التحقق من أن الطبيب موجود
      final doctorExists = await _supabase
          .from(SupabaseConfig.doctorsTable)
          .select('id')
          .eq('id', doctorId)
          .maybeSingle();

      if (doctorExists == null) {
        throw Exception('الطبيب غير موجود');
      }

      // التحقق من أن الطبيب غير مرتبط بمستخدم آخر
      final doctorAlreadyLinked = await _supabase
          .from(SupabaseConfig.doctorsTable)
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (doctorAlreadyLinked != null) {
        throw Exception('هذا المستخدم مرتبط بطبيب آخر بالفعل');
      }

      // تحديث الطبيب بمعرف المستخدم
      await _supabase
          .from(SupabaseConfig.doctorsTable)
          .update({'user_id': userId}).eq('id', doctorId);

      developer.log('Doctor $doctorId linked to user $userId successfully');
      return true;
    } catch (e) {
      developer.log('Error linking doctor to user: $e');
      throw Exception('فشل في ربط الطبيب بالمستخدم: $e');
    }
  }

  // إلغاء ربط الطبيب بحساب المستخدم
  Future<bool> unlinkDoctorFromUser(String doctorId) async {
    try {
      await _supabase
          .from(SupabaseConfig.doctorsTable)
          .update({'user_id': null}).eq('id', doctorId);

      developer.log('Doctor $doctorId unlinked from user successfully');
      return true;
    } catch (e) {
      developer.log('Error unlinking doctor from user: $e');
      throw Exception('فشل في إلغاء ربط الطبيب بالمستخدم: $e');
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
    String? hospitalId,
    String? departmentId,
    String? doctorId,
    String? notes,
  }) async {
    try {
      developer.log(
          'Booking appointment: patientId=$patientId, appointmentId=$appointmentId, hospitalId=$hospitalId, departmentId=$departmentId, doctorId=$doctorId');

      // الحصول على معلومات الموعد المتاح
      final appointmentInfo = await _supabase
          .from('available_appointments')
          .select('doctor_id, date, start_time')
          .eq('id', appointmentId)
          .single();

      developer.log('Appointment info: $appointmentInfo');

      // إذا لم يتم تمرير معرف الطبيب، نستخدم المعرف من الموعد المتاح
      final finalDoctorId = doctorId ?? appointmentInfo['doctor_id'];

      // إذا لم يتم تمرير معرف المستشفى أو القسم، نحاول الحصول عليهما من معلومات الطبيب
      String finalHospitalId = hospitalId ?? '';
      String? finalDepartmentId = departmentId;

      if (finalDoctorId != null) {
        try {
          final doctorInfo = await _supabase
              .from(SupabaseConfig.doctorsTable)
              .select('facility_id, department_id')
              .eq('id', finalDoctorId)
              .single();

          finalHospitalId = hospitalId ?? doctorInfo['facility_id'] ?? '';
          finalDepartmentId = departmentId ?? doctorInfo['department_id'];

          developer.log('Doctor info: $doctorInfo');
        } catch (e) {
          developer.log('Error fetching doctor info: $e');
        }
      }

      // Generate a UUID for the appointment if the provided ID is not a valid UUID
      String finalAppointmentId = appointmentId;

      // Check if the appointmentId is a timestamp (numeric) and not a UUID
      if (int.tryParse(appointmentId) != null) {
        // Generate a proper UUID instead
        finalAppointmentId = const Uuid().v4();
        developer.log(
            'Generated UUID for appointment: $finalAppointmentId (replacing: $appointmentId)');
      }

      await _supabase.from(SupabaseConfig.appointmentsTable).insert({
        'id': finalAppointmentId,
        'patient_id': patientId,
        'doctor_id': finalDoctorId,
        'facility_id': finalHospitalId,
        'department_id': finalDepartmentId,
        'appointment_date': appointmentInfo['date'] ??
            DateTime.now().toIso8601String().split('T')[0],
        'appointment_time': appointmentInfo['start_time'] ?? '10:00:00',
        'is_virtual': false,
        'status': 'Pending',
        'notes': notes,
        'created_at': DateTime.now().toIso8601String(),
      });

      // تحديث حالة الموعد المتاح إلى محجوز
      await _supabase.from('available_appointments').update({
        'is_booked': true,
        'booked_appointment_id':
            finalAppointmentId // Store the UUID of the booked appointment
      }).eq('id', appointmentId);

      developer.log('Appointment booked successfully');
    } catch (e) {
      developer.log('Error booking appointment: $e');
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

  // إضافة قسم جديد
  Future<void> addDepartment(Department department) async {
    try {
      developer.log('Adding new department: ${department.nameArabic}');

      await _supabase
          .from(SupabaseConfig.departmentsTable)
          .insert(department.toJson());

      developer.log('Department added successfully');
    } catch (e) {
      developer.log('Error adding department: $e');
      throw Exception('فشل في إضافة القسم: $e');
    }
  }

  // تحديث بيانات قسم
  Future<void> updateDepartment(Department department) async {
    try {
      developer.log('Updating department: ${department.id}');

      await _supabase
          .from(SupabaseConfig.departmentsTable)
          .update(department.toJson())
          .eq('id', department.id);

      developer.log('Department updated successfully');
    } catch (e) {
      developer.log('Error updating department: $e');
      throw Exception('فشل في تحديث بيانات القسم: $e');
    }
  }

  // حذف قسم
  Future<void> deleteDepartment(String departmentId) async {
    try {
      developer.log('Deleting department: $departmentId');

      // التحقق من عدم وجود أطباء مرتبطين بالقسم
      final doctors = await getDepartmentDoctors(departmentId);
      if (doctors.isNotEmpty) {
        throw Exception(
            'لا يمكن حذف القسم لأنه يحتوي على أطباء. قم بنقل الأطباء أو حذفهم أولاً.');
      }

      await _supabase
          .from(SupabaseConfig.departmentsTable)
          .delete()
          .eq('id', departmentId);

      developer.log('Department deleted successfully');
    } catch (e) {
      developer.log('Error deleting department: $e');
      throw Exception('فشل في حذف القسم: $e');
    }
  }
}

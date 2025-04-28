import 'package:flutter/foundation.dart';
import 'dart:developer' as developer;

@immutable
class Hospital {
  final String id;
  final String nameArabic;
  final String? nameEnglish;
  final String addressArabic;
  final String? addressEnglish;
  final String city;
  final String region;
  final String facilityType; // Hospital | Clinic | Medical Center
  final String? phone;
  final String? email;
  final String? websiteUrl;
  final double? locationLat;
  final double? locationLong;
  final String? imageUrl;
  final String? description;
  final bool isActive;
  final DateTime createdAt;

  const Hospital({
    required this.id,
    required this.nameArabic,
    this.nameEnglish,
    required this.addressArabic,
    this.addressEnglish,
    required this.city,
    required this.region,
    required this.facilityType,
    this.phone,
    this.email,
    this.websiteUrl,
    this.locationLat,
    this.locationLong,
    this.imageUrl,
    this.description,
    required this.isActive,
    required this.createdAt,
  });

  factory Hospital.fromJson(Map<String, dynamic> json) {
    try {
      developer.log('Parsing hospital JSON: $json');

      // Handle location coordinates
      double? lat = json['location_lat'] != null
          ? double.tryParse(json['location_lat'].toString())
          : null;
      double? long = json['location_long'] != null
          ? double.tryParse(json['location_long'].toString())
          : null;

      return Hospital(
        id: json['id']?.toString() ?? '',
        nameArabic: json['name_arabic']?.toString() ?? '',
        nameEnglish: json['name_english']?.toString(),
        addressArabic: json['address_arabic']?.toString() ?? '',
        addressEnglish: json['address_english']?.toString(),
        city: json['city']?.toString() ?? '',
        region: json['region']?.toString() ?? '',
        facilityType: json['facility_type']?.toString() ?? 'Hospital',
        phone: json['phone']?.toString(),
        email: json['email']?.toString(),
        websiteUrl: json['website_url']?.toString(),
        locationLat: lat,
        locationLong: long,
        imageUrl: json['image_url']?.toString(),
        description: json['description']?.toString(),
        isActive: json['is_active'] as bool? ?? true,
        createdAt: json['created_at'] != null
            ? DateTime.parse(json['created_at'].toString())
            : DateTime.now(),
      );
    } catch (e, stackTrace) {
      developer.log('Error parsing hospital: $e');
      developer.log('Stack trace: $stackTrace');
      developer.log('Problematic JSON: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name_arabic': nameArabic,
      'name_english': nameEnglish,
      'address_arabic': addressArabic,
      'address_english': addressEnglish,
      'city': city,
      'region': region,
      'facility_type': facilityType,
      'phone': phone,
      'email': email,
      'website_url': websiteUrl,
      'location_lat': locationLat,
      'location_long': locationLong,
      'image_url': imageUrl,
      'description': description,
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Hospital copyWith({
    String? id,
    String? nameArabic,
    String? nameEnglish,
    String? addressArabic,
    String? addressEnglish,
    String? city,
    String? region,
    String? facilityType,
    String? phone,
    String? email,
    String? websiteUrl,
    double? locationLat,
    double? locationLong,
    String? imageUrl,
    String? description,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return Hospital(
      id: id ?? this.id,
      nameArabic: nameArabic ?? this.nameArabic,
      nameEnglish: nameEnglish ?? this.nameEnglish,
      addressArabic: addressArabic ?? this.addressArabic,
      addressEnglish: addressEnglish ?? this.addressEnglish,
      city: city ?? this.city,
      region: region ?? this.region,
      facilityType: facilityType ?? this.facilityType,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      locationLat: locationLat ?? this.locationLat,
      locationLong: locationLong ?? this.locationLong,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Hospital &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          nameArabic == other.nameArabic &&
          nameEnglish == other.nameEnglish &&
          addressArabic == other.addressArabic &&
          addressEnglish == other.addressEnglish &&
          city == other.city &&
          region == other.region &&
          facilityType == other.facilityType &&
          phone == other.phone &&
          email == other.email &&
          websiteUrl == other.websiteUrl &&
          locationLat == other.locationLat &&
          locationLong == other.locationLong &&
          imageUrl == other.imageUrl &&
          description == other.description &&
          isActive == other.isActive &&
          createdAt == other.createdAt;

  @override
  int get hashCode =>
      id.hashCode ^
      nameArabic.hashCode ^
      nameEnglish.hashCode ^
      addressArabic.hashCode ^
      addressEnglish.hashCode ^
      city.hashCode ^
      region.hashCode ^
      facilityType.hashCode ^
      phone.hashCode ^
      email.hashCode ^
      websiteUrl.hashCode ^
      locationLat.hashCode ^
      locationLong.hashCode ^
      imageUrl.hashCode ^
      description.hashCode ^
      isActive.hashCode ^
      createdAt.hashCode;
}

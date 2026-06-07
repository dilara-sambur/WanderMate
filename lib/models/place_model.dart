class PlaceModel {
  final String id;
  final String name;
  final String category;
  final double rating;
  final int reviewCount;
  final String address;
  final double lat;
  final double lng;
  final String imageUrl;
  final String semanticLabel;
  final double? distanceKm;
  final CrowdLevel crowdLevel;
  final bool isOpen;
  final String? phoneNumber;
  final String? website;

  const PlaceModel({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.address,
    required this.lat,
    required this.lng,
    required this.imageUrl,
    required this.semanticLabel,
    this.distanceKm,
    required this.crowdLevel,
    required this.isOpen,
    this.phoneNumber,
    this.website,
  });

  factory PlaceModel.fromMap(Map<String, dynamic> map) {
    return PlaceModel(
      id: map['id'] as String,
      name: map['name'] as String,
      category: map['category'] as String,
      rating: (map['rating'] as num).toDouble(),
      reviewCount: map['reviewCount'] as int,
      address: map['address'] as String,
      lat: (map['lat'] as num).toDouble(),
      lng: (map['lng'] as num).toDouble(),
      imageUrl: map['imageUrl'] as String,
      semanticLabel: map['semanticLabel'] as String,
      distanceKm: map['distanceKm'] != null
          ? (map['distanceKm'] as num).toDouble()
          : null,
      crowdLevel: _crowdFromString(map['crowdLevel'] as String),
      isOpen: map['isOpen'] as bool,
      phoneNumber: map['phoneNumber'] as String?,
      website: map['website'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'category': category,
    'rating': rating,
    'reviewCount': reviewCount,
    'address': address,
    'lat': lat,
    'lng': lng,
    'imageUrl': imageUrl,
    'semanticLabel': semanticLabel,
    'distanceKm': distanceKm,
    'crowdLevel': crowdLevel.name,
    'isOpen': isOpen,
    'phoneNumber': phoneNumber,
    'website': website,
  };

  static CrowdLevel _crowdFromString(String v) {
    switch (v) {
      case 'low':
        return CrowdLevel.low;
      case 'medium':
        return CrowdLevel.medium;
      case 'high':
        return CrowdLevel.high;
      default:
        return CrowdLevel.medium;
    }
  }
}

enum CrowdLevel { low, medium, high }

extension CrowdLevelExtension on CrowdLevel {
  String get label {
    switch (this) {
      case CrowdLevel.low:
        return 'Az Kalabalık';
      case CrowdLevel.medium:
        return 'Orta';
      case CrowdLevel.high:
        return 'Yoğun';
    }
  }

  String get emoji {
    switch (this) {
      case CrowdLevel.low:
        return '🟢';
      case CrowdLevel.medium:
        return '🟡';
      case CrowdLevel.high:
        return '🔴';
    }
  }
}

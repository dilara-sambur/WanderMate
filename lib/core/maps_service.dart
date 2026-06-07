import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/place_model.dart';
import 'api_keys.dart';

class MapsService {
  Future<List<PlaceModel>> searchPlaces({
    required double lat,
    required double lng,
    required String keyword,
    String type = 'restaurant',
    int radius = 5000,
  }) async {
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
      '?location=$lat,$lng'
      '&radius=$radius'
      '&type=$type'
      '&keyword=${Uri.encodeComponent(keyword)}'
      '&language=tr'
      '&key=${ApiKeys.googlePlacesApiKey}',
    );

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Places API bağlantı hatası');
    }

    final data = json.decode(response.body);

    if (data['status'] != 'OK' && data['status'] != 'ZERO_RESULTS') {
      throw Exception(
        'Places API hatası: ${data['status']} | ${data['error_message']}',
      );
    }

    final results = data['results'] as List? ?? [];

    return results.map((place) {
      final location = place['geometry']?['location'];
      final rating = (place['rating'] ?? 0).toDouble();

      return PlaceModel(
        id: place['place_id'] ?? '',
        name: place['name'] ?? 'Bilinmeyen Mekan',
        category: _categoryName(type),
        address: place['vicinity'] ?? '',
        lat: (location?['lat'] ?? 0).toDouble(),
        lng: (location?['lng'] ?? 0).toDouble(),
        rating: rating,
        reviewCount: place['user_ratings_total'] ?? 0,
        imageUrl: _photoUrl(place, type),
        semanticLabel: place['name'] ?? '',
        distanceKm: null,
        crowdLevel: _crowdLevelFromRating(rating),
        isOpen: place['opening_hours']?['open_now'] ?? false,
      );
    }).toList();
  }

  Future<String> getCityFromLatLng({
    required double lat,
    required double lng,
  }) async {
    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/geocode/json'
      '?latlng=$lat,$lng'
      '&language=tr'
      '&key=${ApiKeys.googlePlacesApiKey}',
    );

    try {
      final response = await http.get(uri);

      if (response.statusCode != 200) {
        return 'Bilecik';
      }

      final data = json.decode(response.body);

      if (data['status'] != 'OK') {
        return 'Bilecik';
      }

      final results = data['results'] as List? ?? [];

      for (final result in results) {
        final components = result['address_components'] as List? ?? [];

        for (final component in components) {
          final types = List<String>.from(component['types'] ?? []);

          if (types.contains('administrative_area_level_1')) {
            return component['long_name'] ?? 'Bilecik';
          }
        }
      }

      return 'Bilecik';
    } catch (_) {
      return 'Bilecik';
    }
  }

  String _photoUrl(dynamic place, String type) {
    final photos = place['photos'] as List?;

    if (photos != null && photos.isNotEmpty) {
      final photoReference = photos.first['photo_reference'];

      if (photoReference != null) {
        return 'https://maps.googleapis.com/maps/api/place/photo'
            '?maxwidth=700'
            '&photo_reference=${Uri.encodeComponent(photoReference)}'
            '&key=${ApiKeys.googlePlacesApiKey}';
      }
    }

    return _defaultImage(type);
  }

  CrowdLevel _crowdLevelFromRating(double rating) {
    if (rating >= 4.5) return CrowdLevel.high;
    if (rating >= 4.0) return CrowdLevel.medium;
    return CrowdLevel.low;
  }

  String _categoryName(String type) {
    switch (type) {
      case 'cafe':
        return 'Kafe';
      case 'tourist_attraction':
        return 'Tarihi Yer';
      case 'museum':
        return 'Müze';
      case 'park':
        return 'Park';
      case 'restaurant':
      default:
        return 'Restoran';
    }
  }

  String _defaultImage(String type) {
    switch (type) {
      case 'cafe':
        return 'https://images.unsplash.com/photo-1554118811-1e0d58224f24';
      case 'tourist_attraction':
        return 'https://images.unsplash.com/photo-1566127992631-137a642a90f4';
      case 'museum':
        return 'https://images.unsplash.com/photo-1566127992631-137a642a90f4';
      case 'park':
        return 'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee';
      case 'restaurant':
      default:
        return 'https://images.unsplash.com/photo-1517248135467-4c7edcad34c4';
    }
  }
}
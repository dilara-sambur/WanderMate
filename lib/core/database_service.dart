class DatabaseService {
  Future<void> init() async {}

  Future<void> savePlace(dynamic place) async {}

  Future<List<dynamic>> getSavedPlaces() async {
    return [];
  }

  Future<void> deletePlace(String id) async {}

  Future<bool> isPlaceSaved(String id) async {
    return false;
  }

  Future<void> clearSavedPlaces() async {}
}
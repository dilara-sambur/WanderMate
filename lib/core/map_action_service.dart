import 'package:flutter/foundation.dart';

class MapActionService {
  static final ValueNotifier<String?> pendingMapQuery =
      ValueNotifier<String?>(null);

  static void showOnMap(String query) {
    pendingMapQuery.value = query;
  }

  static void clear() {
    pendingMapQuery.value = null;
  }
}
import '../models/place_model.dart';

class CrowdAnalyzer {
  static CrowdLevel analyze({
    required double rating,
    required int reviewCount,
  }) {
    if (rating >= 4.5) return CrowdLevel.high;
    if (rating >= 4.0) return CrowdLevel.medium;
    return CrowdLevel.low;
  }

  static bool matchesQuery({required String query, required CrowdLevel crowd}) {
    final q = query.toLowerCase();
    final wantsQuiet =
        q.contains('sakin') ||
        q.contains('kalabalık olmasın') ||
        q.contains('kalabalık olmayan') ||
        q.contains('sıra beklemek') ||
        q.contains('sessiz');
    if (wantsQuiet) {
      return crowd == CrowdLevel.low || crowd == CrowdLevel.medium;
    }
    return true;
  }

  static List<T> filterByCrowd<T extends Object>({
    required List<T> places,
    required String query,
    required CrowdLevel Function(T) crowdGetter,
  }) {
    if (!matchesQuery(query: query, crowd: CrowdLevel.high)) {
      return places.where((p) => crowdGetter(p) != CrowdLevel.high).toList();
    }
    return places;
  }
}

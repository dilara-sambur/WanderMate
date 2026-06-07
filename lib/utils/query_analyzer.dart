enum QueryMode { gemini, maps, hybrid }

class QueryResult {
  final QueryMode mode;
  final String? mapsCategory;
  final bool avoidCrowd;
  final bool openNow;

  const QueryResult({
    required this.mode,
    this.mapsCategory,
    this.avoidCrowd = false,
    this.openNow = false,
  });
}

class QueryAnalyzer {
  static QueryResult analyze(String query) {
    final q = query.toLowerCase().trim();

    final bool avoidCrowd =
        q.contains('sakin') ||
        q.contains('sessiz') ||
        q.contains('kalabalık olmasın') ||
        q.contains('kalabalik olmasin') ||
        q.contains('kalabalık olmayan') ||
        q.contains('kalabalik olmayan') ||
        q.contains('az kalabalık') ||
        q.contains('az kalabalik') ||
        q.contains('sıra beklemek') ||
        q.contains('sira beklemek');

    final bool openNow =
        q.contains('gece') ||
        q.contains('açık') ||
        q.contains('acik') ||
        q.contains('şu an') ||
        q.contains('simdi') ||
        q.contains('şimdi');

    String? mapsCategory;

    // Kafeler
    if (q.contains('kafe') ||
        q.contains('cafe') ||
        q.contains('kahve') ||
        q.contains('coffee')) {
      mapsCategory = 'cafe';
    }

    // Restoranlar
    else if (q.contains('restoran') ||
        q.contains('restaurant') ||
        q.contains('lokanta') ||
        q.contains('yemek') ||
        q.contains('ne yenir') ||
        q.contains('tatlı') ||
        q.contains('tatli')) {
      mapsCategory = 'restaurant';
    }

    // Gezilecek yerler
    else if (q.contains('tarihi') ||
        q.contains('müze') ||
        q.contains('muze') ||
        q.contains('gezilecek') ||
        q.contains('gezilir') ||
        q.contains('turistik') ||
        q.contains('nereler gezilir')) {
      mapsCategory = 'tourist_attraction';
    }

    // Parklar
    else if (q.contains('park') ||
        q.contains('doğa') ||
        q.contains('doga') ||
        q.contains('orman')) {
      mapsCategory = 'park';
    }

    // Cami
    else if (q.contains('cami')) {
      mapsCategory = 'mosque';
    }

    // Eczane
    else if (q.contains('eczane')) {
      mapsCategory = 'pharmacy';
    }

    // Hastane
    else if (q.contains('hastane')) {
      mapsCategory = 'hospital';
    }

    // ATM
    else if (q.contains('atm')) {
      mapsCategory = 'atm';
    }

    // Banka
    else if (q.contains('banka')) {
      mapsCategory = 'bank';
    }

    // Otel
    else if (q.contains('otel')) {
      mapsCategory = 'lodging';
    }

    // Market
    else if (q.contains('market') ||
        q.contains('migros') ||
        q.contains('a101') ||
        q.contains('bim') ||
        q.contains('şok') ||
        q.contains('sok')) {
      mapsCategory = 'supermarket';
    }

    // Haritaya gitmesi gereken ifadeler
    final bool isMapSearch =
        q.contains('nerede') ||
        q.contains('en yakın') ||
        q.contains('yakınımdaki') ||
        q.contains('yakınımda') ||
        q.contains('haritada göster') ||
        mapsCategory != null;

    if (isMapSearch) {
      return QueryResult(
        mode: QueryMode.maps,
        mapsCategory: mapsCategory,
        avoidCrowd: avoidCrowd,
        openNow: openNow,
      );
    }

    return QueryResult(
      mode: QueryMode.gemini,
      mapsCategory: mapsCategory,
      avoidCrowd: avoidCrowd,
      openNow: openNow,
    );
  }
}
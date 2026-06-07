import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../core/api_keys.dart';
import '../../constants/app_constants.dart';
import '../../core/gemini_service.dart';
import '../../core/maps_service.dart';
import '../../core/search_history_service.dart';
import '../../core/user_preferences_service.dart';
import '../../core/weather_service.dart';
import '../../core/cache_service.dart';
import '../../core/map_action_service.dart';
import '../../models/place_model.dart';
import '../../models/user_preferences_model.dart';
import '../../theme/app_theme.dart';
import '../../utils/query_analyzer.dart';
import './widgets/ai_answer_bottom_sheet_widget.dart';
import './widgets/map_top_bar_widget.dart';
import './widgets/place_result_bottom_sheet_widget.dart';
import './widgets/quick_category_chips_widget.dart';
import './widgets/smart_search_panel_widget.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  final UserPreferencesService _prefsService = UserPreferencesService();
  final SearchHistoryService _searchHistoryService = SearchHistoryService();
  final MapsService _mapsService = MapsService();
  final CacheService _cacheService = CacheService();
  final GeminiService _geminiService = GeminiService(
  apiKey: ApiKeys.geminiApiKey,
);


  GoogleMapController? _mapController;

  UserPreferencesModel _prefs = UserPreferencesModel.defaults;
  WeatherData? _weather;

  double _currentLat = AppConstants.defaultLat;
  double _currentLng = AppConstants.defaultLng;
  String _currentCity = AppConstants.defaultCity;

  bool _isLoadingLocation = true;
  bool _isSearching = false;
  String _selectedCategory = '';

  List<PlaceModel> _places = [];
  List<PlaceModel> _filteredPlaces = [];

  late AnimationController _panelController;
  late Animation<double> _panelAnimation;

  @override
  void initState() {
    super.initState();

    _panelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );

    _panelAnimation = CurvedAnimation(
      parent: _panelController,
      curve: Curves.easeOutCubic,
    );

    _panelController.forward();

    _loadPrefs();
    _initLocation();
    MapActionService.pendingMapQuery.addListener(_listenMapAction);
  }

  @override
  void dispose() {
    _panelController.dispose();
    _mapController?.dispose();
    super.dispose();
    MapActionService.pendingMapQuery.removeListener(_listenMapAction);
  }

  Future<void> _loadPrefs() async {
    final p = await _prefsService.getPreferences();

    if (!mounted) return;

    setState(() {
      _prefs = p;
    });
  }

  Future<void> _initLocation() async {
    setState(() => _isLoadingLocation = true);
    

    try {
    
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        throw Exception('Konum servisi kapalı');
      }

      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();

        if (permission == LocationPermission.denied) {
          throw Exception('Konum izni reddedildi');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Konum izni kalıcı olarak reddedildi');
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      ).timeout(const Duration(seconds: 10));

      final city = await _mapsService.getCityFromLatLng(
        lat: position.latitude,
        lng: position.longitude,
      );

      if (!mounted) return;

      setState(() {
       _currentLat = position.latitude;
      _currentLng = position.longitude;
      _currentCity = city;
      _isLoadingLocation = false;
    });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentLat, _currentLng),
          14,
        ),
      );

      await _loadWeather();
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _currentLat = AppConstants.defaultLat;
        _currentLng = AppConstants.defaultLng;
        _currentCity = AppConstants.defaultCity;
        _isLoadingLocation = false;
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(_currentLat, _currentLng),
          14,
        ),
      );

      await _loadWeather();
    }
  }

  Future<void> _loadWeather() async {
    try {
      final weatherService = WeatherService(apiKey: 'ca5e5b715d7ffb9e8ada754af9c21926');

      final w = await weatherService.getWeather(
        lat: _currentLat,
        lng: _currentLng,
      );

      if (!mounted) return;

      setState(() {
        _weather = w;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _weather = null;
      });
    }
  }

void _listenMapAction() {
  final query = MapActionService.pendingMapQuery.value;

  if (query == null || query.isEmpty) return;

  MapActionService.clear();

  Future.delayed(const Duration(milliseconds: 500), () {
    if (!mounted) return;
    _performMapSearch(query);
  });
}

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = _selectedCategory == category ? '' : category;
    });

    if (_selectedCategory.isEmpty) {
      setState(() {
        _filteredPlaces = List.from(_places);
      });
      _focusPlacesOnMap();
      return;
    }

    _performMapSearch(_selectedCategory);
  }
String _typeFromQuery(String query) {
  final lower = query.toLowerCase().trim();

  if (lower == 'tourist_attraction') return 'tourist_attraction';
  if (lower == 'restaurant') return 'restaurant';
  if (lower == 'cafe') return 'cafe';
  if (lower == 'park') return 'park';
  if (lower == 'museum') return 'museum';

  if (lower.contains('cami')) return 'mosque';
  if (lower.contains('eczane')) return 'pharmacy';
  if (lower.contains('hastane')) return 'hospital';
  if (lower.contains('atm')) return 'atm';
  if (lower.contains('banka')) return 'bank';
  if (lower.contains('otel')) return 'lodging';

  if (lower.contains('market') ||
      lower.contains('migros') ||
      lower.contains('bim') ||
      lower.contains('a101') ||
      lower.contains('şok') ||
      lower.contains('sok')) {
    return 'supermarket';
  }

  if (lower.contains('kafe') ||
      lower.contains('cafe') ||
      lower.contains('kahve') ||
      lower.contains('coffee')) {
    return 'cafe';
  }

  if (lower.contains('gezilecek') ||
      lower.contains('gezilir') ||
      lower.contains('gezi') ||
      lower.contains('turistik') ||
      lower.contains('tarihi') ||
      lower.contains('tarih') ||
      lower.contains('müze') ||
      lower.contains('muze') ||
      lower.contains('museum') ||
      lower.contains('tourist') ||
      lower.contains('attraction')) {
    return 'tourist_attraction';
  }

  if (lower.contains('park') ||
      lower.contains('doğa') ||
      lower.contains('doga') ||
      lower.contains('orman')) {
    return 'park';
  }

  if (lower.contains('restoran') ||
      lower.contains('restaurant') ||
      lower.contains('lokanta') ||
      lower.contains('yemek') ||
      lower.contains('ne yenir') ||
      lower.contains('ne yerim') ||
      lower.contains('ne yesem') ||
      lower.contains('nerede yemek') ||
      lower.contains('yemek yerim') ||
      lower.contains('lezzet') ||
      lower.contains('food') ||
      lower.contains('eat')) {
    return 'restaurant';
  }

  return 'tourist_attraction';
}
  Future<void> _performMapSearch(String query) async {
    setState(() => _isSearching = true);

    try {
      final type = _typeFromQuery(query);

      final places = await _mapsService.searchPlaces(
        lat: _currentLat,
        lng: _currentLng,
        keyword: type == 'restaurant' ? 'restoran yemek' : query,
        type: type,
      );

      List<PlaceModel> filtered = List.from(places);

      final lower = query.toLowerCase();

      final avoidCrowd = lower.contains('sakin') ||
          lower.contains('sessiz') ||
          lower.contains('az kalabalık') ||
          lower.contains('az kalabalik') ||
          lower.contains('kalabalık olmasın') ||
          lower.contains('kalabalik olmasin') ||
          lower.contains('sıra beklemek istemiyorum') ||
          lower.contains('sira beklemek istemiyorum');

      if (avoidCrowd) {
        filtered = filtered.where((p) => p.crowdLevel != CrowdLevel.high).toList();
      }

      if (!mounted) return;

      setState(() {
        _places = places;
        _filteredPlaces = filtered;
        _isSearching = false;
      });

      _focusPlacesOnMap();
      _showPlaceResults(filtered, query);
    } catch (e) {
      if (!mounted) return;

      setState(() => _isSearching = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Mekanlar alınamadı: $e'),
        ),
      );
    }
  }

Future<void> _onSearch(String query) async {
  if (query.trim().isEmpty) return;

  final result = QueryAnalyzer.analyze(query);

  if (result.mapsCategory != null ||
      query.toLowerCase().contains('cami') ||
      query.toLowerCase().contains('eczane') ||
      query.toLowerCase().contains('atm') ||
      query.toLowerCase().contains('banka') ||
      query.toLowerCase().contains('hastane') ||
      query.toLowerCase().contains('otel') ||
      query.toLowerCase().contains('market')) {
    await _performMapSearch(query);
    return;
  }

  await _searchHistoryService.addQuery(query);

  final cachedAnswer = await _cacheService.getAnswer(query);

  if (cachedAnswer != null) {
    _showAiAnswer(query, cachedAnswer);
    return;
  }

  setState(() => _isSearching = true);

  try {
    final answer = await _geminiService.askGemini(
      prompt: '''
Kullanıcının bulunduğu şehir: $_currentCity
Gezi tarzı: ${_prefs.travelStyle}
Bütçe: ${_prefs.budget}
Dil tercihi: ${_prefs.language}

Kullanıcı sorusu:
$query

Kısa, doğal ve gezi asistanı gibi cevap ver.
Kullanıcı English seçtiyse İngilizce cevap ver.
Kullanıcı Türkçe seçtiyse Türkçe cevap ver.
''',
      cityContext: _currentCity,
      travelStyle: _prefs.travelStyle,
      budget: _prefs.budget,
    );

    if (!mounted) return;

    await _cacheService.saveAnswer(query, answer);

    setState(() => _isSearching = false);

    _showAiAnswer(query, answer);
  } catch (_) {
    if (!mounted) return;

    setState(() => _isSearching = false);

    _showAiAnswer(
      query,
      'AI şu anda cevap veremiyor. Haritada Göster butonuyla ilgili yerleri bulabilirsin.',
    );
  }
}
  void _showAiAnswer(String query, String answer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => AiAnswerBottomSheetWidget(
        query: query,
        answer: answer,
        onShowOnMap: () {
          Navigator.pop(context);
          _performMapSearch(query);
        },
      ),
    );
  }

  void _showPlaceResults(List<PlaceModel> places, String query) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => PlaceResultBottomSheetWidget(
        places: places,
        query: query,
        userLat: _currentLat,
        userLng: _currentLng,
      ),
    );
  }

  void _focusPlacesOnMap() {
    if (_filteredPlaces.isEmpty || _mapController == null) return;

    if (_filteredPlaces.length == 1) {
      final p = _filteredPlaces.first;

      _mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(p.lat, p.lng),
          15,
        ),
      );

      return;
    }

    double minLat = _filteredPlaces.first.lat;
    double maxLat = _filteredPlaces.first.lat;
    double minLng = _filteredPlaces.first.lng;
    double maxLng = _filteredPlaces.first.lng;

    for (final p in _filteredPlaces) {
      if (p.lat < minLat) minLat = p.lat;
      if (p.lat > maxLat) maxLat = p.lat;
      if (p.lng < minLng) minLng = p.lng;
      if (p.lng > maxLng) maxLng = p.lng;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat - 0.003, minLng - 0.003),
          northeast: LatLng(maxLat + 0.003, maxLng + 0.003),
        ),
        80,
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    return _filteredPlaces.map((place) {
      return Marker(
        markerId: MarkerId(place.id),
        position: LatLng(place.lat, place.lng),
        infoWindow: InfoWindow(
          title: place.name,
          snippet: '${place.category} · ⭐ ${place.rating}',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          _markerHue(place.category),
        ),
        onTap: () {
          _showPlaceResults([place], place.name);
        },
      );
    }).toSet();
  }

  double _markerHue(String category) {
    final lower = category.toLowerCase();

    if (lower.contains('kafe') || lower.contains('cafe')) {
      return BitmapDescriptor.hueOrange;
    }

    if (lower.contains('restoran') || lower.contains('restaurant')) {
      return BitmapDescriptor.hueRed;
    }

    if (lower.contains('tarihi') ||
        lower.contains('müze') ||
        lower.contains('muze')) {
      return BitmapDescriptor.hueViolet;
    }

    if (lower.contains('park')) {
      return BitmapDescriptor.hueGreen;
    }

    return BitmapDescriptor.hueAzure;
  }

  Widget _buildMapBackground() {
    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target: LatLng(_currentLat, _currentLng),
        zoom: 14,
      ),
      myLocationEnabled: true,
      myLocationButtonEnabled: false,
      zoomControlsEnabled: false,
      mapToolbarEnabled: false,
      compassEnabled: false,
      trafficEnabled: true,
      buildingsEnabled: true,
      markers: _buildMarkers(),
      onMapCreated: (controller) {
        _mapController = controller;

        controller.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(_currentLat, _currentLng),
            14,
          ),
        );
      },
    );
  }

  Widget _buildPlaceCardsList({bool isTablet = false}) {
    if (_filteredPlaces.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.travel_explore_rounded,
              size: 48,
              color: AppTheme.outlineLight,
            ),
            const SizedBox(height: 12),
            Text(
              'Henüz mekan aranmadı',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF4A5548),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Kafe, restoran veya gezilecek yer arayarak başlayabilirsin.',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: const Color(0xFF9E9E9E),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: isTablet ? null : 280,
      child: ListView.builder(
        shrinkWrap: isTablet,
        scrollDirection: isTablet ? Axis.vertical : Axis.horizontal,
        physics: isTablet
            ? const NeverScrollableScrollPhysics()
            : const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: isTablet ? 16 : 16),
        itemCount: _filteredPlaces.length,
        itemBuilder: (context, index) {
          return AnimatedOpacity(
            opacity: 1.0,
            duration: Duration(milliseconds: 200 + index * 50),
            child: _PlaceCardItem(
              place: _filteredPlaces[index],
              isTablet: isTablet,
              onTap: () => _showPlaceResults(
                [_filteredPlaces[index]],
                _filteredPlaces[index].name,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPhoneLayout() {
    return Stack(
      children: [
        _buildMapBackground(),
        SafeArea(
          child: Column(
            children: [
              MapTopBarWidget(
                cityName: _currentCity,
                weather: _weather,
                travelStyle: _prefs.travelStyle,
                isLoading: _isLoadingLocation,
              ),
            ],
          ),
        ),
        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 1),
              end: Offset.zero,
            ).animate(_panelAnimation),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surfaceLight,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withAlpha(31),
                    blurRadius: 24,
                    offset: const Offset(0, -8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 10),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.outlineLight,
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SmartSearchPanelWidget(
                    isLoading: _isSearching,
                    onSearch: _onSearch,
                  ),
                  const SizedBox(height: 12),
                  QuickCategoryChipsWidget(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: _onCategorySelected,
                  ),
                  const SizedBox(height: 12),
                  _buildPlaceCardsList(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTabletLayout() {
    return Row(
      children: [
        Expanded(
          flex: 55,
          child: Stack(
            children: [
              _buildMapBackground(),
              SafeArea(
                child: MapTopBarWidget(
                  cityName: _currentCity,
                  weather: _weather,
                  travelStyle: _prefs.travelStyle,
                  isLoading: _isLoadingLocation,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          flex: 45,
          child: Container(
            color: AppTheme.backgroundLight,
            child: SafeArea(
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  SmartSearchPanelWidget(
                    isLoading: _isSearching,
                    onSearch: _onSearch,
                  ),
                  const SizedBox(height: 12),
                  QuickCategoryChipsWidget(
                    selectedCategory: _selectedCategory,
                    onCategorySelected: _onCategorySelected,
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: _buildPlaceCardsList(isTablet: true),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: isTablet ? _buildTabletLayout() : _buildPhoneLayout(),
    );
  }
}

class _PlaceCardItem extends StatelessWidget {
  final PlaceModel place;
  final bool isTablet;
  final VoidCallback onTap;

  const _PlaceCardItem({
    required this.place,
    required this.isTablet,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (isTablet) {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: AppTheme.cardDecoration(),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(20),
                ),
                child: Image.network(
                  place.imageUrl,
                  width: 100,
                  height: 90,
                  fit: BoxFit.cover,
                  semanticLabel: place.semanticLabel,
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 90,
                    color: AppTheme.primaryContainer,
                    child: const Icon(
                      Icons.image_rounded,
                      color: AppTheme.primary,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    place.name,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 220,
        margin: const EdgeInsets.only(right: 12),
        decoration: AppTheme.cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(20),
              ),
              child: Image.network(
                place.imageUrl,
                width: 220,
                height: 130,
                fit: BoxFit.cover,
                semanticLabel: place.semanticLabel,
                errorBuilder: (_, __, ___) => Container(
                  width: 220,
                  height: 130,
                  color: AppTheme.primaryContainer,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                place.name,
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A2318),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
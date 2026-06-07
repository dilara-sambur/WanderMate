import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../core/api_keys.dart';
import '../../core/user_preferences_service.dart';
import '../../models/travel_category_model.dart';
import '../../models/user_preferences_model.dart';
import '../../theme/app_theme.dart';
import './widgets/explore_ai_sheet_widget.dart';
import './widgets/explore_feature_card_widget.dart';
import '../../routes/app_routes.dart';
import 'package:go_router/go_router.dart';
import '../../core/gemini_service.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen>
    with SingleTickerProviderStateMixin {
  // TODO: Replace with Riverpod provider for production
  final _prefsService = UserPreferencesService();
  UserPreferencesModel _prefs = UserPreferencesModel.defaults;

  late AnimationController _entranceController;
  bool _isLoadingAi = false;

  final List<Map<String, dynamic>> _categoryMaps = [
    {
      'id': 'weather',
      'title': 'Hava Durumuna Göre',
      'subtitle': 'Bugünkü havaya uygun öneriler',
      'emoji': '🌤️',
      'imageUrl':
          'https://images.unsplash.com/photo-1715103913840-bbf46c6af5e5',
      'semanticLabel':
          'Partly cloudy sky over a green park with people enjoying the weather',
      'geminiPrompt':
          'Bugünkü hava durumuna göre şehirde ne yapabilirim? Pratik öneriler ver.',
      'mapsQuery': 'park',
    },
    {
      'id': 'daily_route',
      'title': 'Bugünün Rotası',
      'subtitle': 'AI ile özel rota planı',
      'emoji': '🗺️',
      'imageUrl':
          'https://images.unsplash.com/photo-1502050685690-9dda340422d2',
      'semanticLabel':
          'Winding cobblestone path through a historic European town with colorful buildings',
      'geminiPrompt':
          'Bugün için sabahtan akşama kadar güzel bir şehir rotası öner. Zaman ve mekan detaylarını ver.',
      'mapsQuery': 'tourist_attraction',
    },
    {
      'id': 'popular',
      'title': 'Popüler Mekanlar',
      'subtitle': 'Şehrin en çok sevilen yerleri',
      'emoji': '🔥',
      'imageUrl':
          'https://images.unsplash.com/photo-1728358133210-5882e1c9134f',
      'semanticLabel':
          'Busy outdoor market with colorful stalls and crowds of tourists',
      'geminiPrompt':
          'Bu şehrin en popüler ve mutlaka görülmesi gereken yerleri hangileri?',
      'mapsQuery': 'tourist_attraction',
    },
    {
      'id': 'quiet',
      'title': 'Sakin Köşeler',
      'subtitle': 'Kalabalıktan uzak huzurlu yerler',
      'emoji': '🤫',
      'imageUrl':
          'https://images.unsplash.com/photo-1584601488587-1866d52298ce',
      'semanticLabel':
          'Peaceful hidden garden with stone bench, flowers, and dappled sunlight through trees',
      'geminiPrompt':
          'Şehirde kalabalıktan uzak, sakin ve huzurlu köşeler nelerdir?',
      'mapsQuery': 'park',
    },
    {
      'id': 'student',
      'title': 'Öğrenci Dostu',
      'subtitle': 'Bütçe dostu seçenekler',
      'emoji': '🎓',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_1f663edba-1773255025909.png',
      'semanticLabel':
          'Students sitting at outdoor cafe tables with laptops and coffee cups',
      'geminiPrompt':
          'Öğrenci bütçesiyle şehirde nasıl iyi vakit geçirebilirim? Uygun fiyatlı seçenekler öner.',
      'mapsQuery': 'cafe',
    },
    {
      'id': 'local_food',
      'title': 'Yerel Lezzetler',
      'subtitle': 'Yöresel mutfaktan seçmeler',
      'emoji': '🍽️',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_17e46b40f-1773109458602.png',
      'semanticLabel':
          'Traditional Turkish dishes spread on a wooden table with colorful ceramic plates',
      'geminiPrompt':
          'Bu şehrin yöresel yemekleri ve mutlaka denenmesi gereken lezzetler nelerdir?',
      'mapsQuery': 'restaurant',
    },
    {
      'id': 'historical',
      'title': 'Tarihi Duraklar',
      'subtitle': 'Geçmişe yolculuk',
      'emoji': '🏛️',
      'imageUrl':
          'https://images.unsplash.com/photo-1508952730003-37d915086633',
      'semanticLabel':
          'Ancient stone ruins and historic buildings on a hilltop with dramatic sky',
      'geminiPrompt':
          'Bu şehrin tarihi önemi olan yerleri ve tarihi hakkında bilgi ver.',
      'mapsQuery': 'tourist_attraction',
    },
    {
      'id': 'photo_spots',
      'title': 'Fotoğraf Noktaları',
      'subtitle': 'Kareler için en güzel yerler',
      'emoji': '📸',
      'imageUrl':
          'https://images.unsplash.com/photo-1672243381180-92fe275b261e',
      'semanticLabel':
          'Panoramic viewpoint over a city at golden hour with mountains in background',
      'geminiPrompt':
          'Şehirde en iyi fotoğraf çekilebilecek noktalar ve manzara yerleri nerelerdir?',
      'mapsQuery': 'tourist_attraction',
    },
    {
      'id': 'rainy_day',
      'title': 'Yağmurlu Hava Planı',
      'subtitle': 'İç mekân alternatifleri',
      'emoji': '🌧️',
      'imageUrl':
          'https://img.rocket.new/generatedImages/rocket_gen_img_145c31330-1779989132470.png',
      'semanticLabel':
          'Cozy indoor museum with warm lighting and visitors browsing exhibits on rainy day',
      'geminiPrompt':
          'Yağmurlu bir günde şehirde neler yapabilirim? İç mekan seçeneklerini öner.',
      'mapsQuery': 'museum',
    },
    {
      'id': 'one_hour',
      'title': '1 Saatim Var',
      'subtitle': 'Hızlı keşif rotası',
      'emoji': '⚡',
      'imageUrl':
          'https://images.unsplash.com/photo-1696688373319-e1621d135238',
      'semanticLabel':
          'Person walking quickly on a city street past historic buildings and cafes',
      'geminiPrompt':
          'Sadece 1 saatim var. Şehirde hızlıca neler görebilirim ve yapabilirim?',
      'mapsQuery': 'tourist_attraction',
    },
  ];

  late List<TravelCategoryModel> _categories;

  @override
  void initState() {
    super.initState();
    _categories = _categoryMaps.map(TravelCategoryModel.fromMap).toList();
    _entranceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
    _loadPrefs();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    super.dispose();
  }

  Future<void> _loadPrefs() async {
    final p = await _prefsService.getPreferences();
    if (mounted) setState(() => _prefs = p);
  }

  Future<void> _onCategoryTap(TravelCategoryModel category) async {
    setState(() => _isLoadingAi = true);

    // TODO: Replace with ApiKeys.geminiApiKey
    final geminiService = GeminiService(
    apiKey: ApiKeys.geminiApiKey,
);
    final answer = await geminiService.askGemini(
      prompt: category.geminiPrompt,
      travelStyle: _prefs.travelStyle,
      budget: _prefs.budget,
    );

    if (mounted) {
      setState(() => _isLoadingAi = false);
      _showAiSheet(category, answer);
    }
  }

  void _showAiSheet(TravelCategoryModel category, String answer) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExploreAiSheetWidget(
        category: category,
        answer: answer,
        onShowOnMap: () {
  Navigator.pop(context);
  context.go(AppRoutes.homeScreen);
},
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final isLargeTablet = MediaQuery.of(context).size.width >= 840;
    final crossAxisCount = isLargeTablet ? 3 : (isTablet ? 2 : 2);

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: SafeArea(
        child: Stack(
          children: [
            CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // Header
                SliverToBoxAdapter(child: _buildHeader()),
                // Weather suggestion card — full width
                SliverToBoxAdapter(child: _buildWeatherCard()),
                // Section label
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                    child: Row(
                      children: [
                        Text(
                          'Keşfet',
                          style: GoogleFonts.outfit(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1A2318),
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${_categories.length} kategori',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // 2-column card grid
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                  sliver: SliverGrid(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      mainAxisSpacing: 14,
                      crossAxisSpacing: 14,
                      childAspectRatio: 0.82,
                    ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final delay = index * 60;
                      return AnimatedBuilder(
                        animation: _entranceController,
                        builder: (context, child) {
                          final delayedProgress = Curves.easeOutCubic.transform(
                            (((_entranceController.value * 1000) - delay) / 400)
                                .clamp(0.0, 1.0),
                          );
                          return Opacity(
                            opacity: delayedProgress,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - delayedProgress)),
                              child: child,
                            ),
                          );
                        },
                        child: ExploreFeatureCardWidget(
                          category: _categories[index],
                          onTap: () => _onCategoryTap(_categories[index]),
                        ),
                      );
                    }, childCount: _categories.length),
                  ),
                ),
              ],
            ),
            // AI loading overlay
            if (_isLoadingAi)
              Container(
                color: Colors.black.withAlpha(89),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: AppTheme.surfaceLight,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primary.withAlpha(38),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 40,
                          height: 40,
                          child: CircularProgressIndicator(
                            strokeWidth: 3,
                            color: AppTheme.primary,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          'AI düşünüyor...',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A2318),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Senin için en iyi öneriyi hazırlıyorum',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: const Color(0xFF9E9E9E),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Günaydın'
        : hour < 18
        ? 'İyi günler'
        : 'İyi akşamlar';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$greeting! 👋',
                  style: GoogleFonts.outfit(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1A2318),
                  ),
                ),
                Text(
                  '${_prefs.travelStyle} gezgin • ${_prefs.budget} bütçe',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: const Color(0xFF9E9E9E),
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppTheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.auto_awesome_rounded,
                  size: 16,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 6),
                Text(
                  'AI Aktif',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: GestureDetector(
        onTap: () => _onCategoryTap(_categories[0]),
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.primaryLight],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withAlpha(77),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '☀️ Bugün Harika!',
                      style: GoogleFonts.outfit(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Hava durumuna göre\nözel öneriler hazır',
                      style: GoogleFonts.outfit(
                        fontSize: 13,
                        color: Colors.white.withAlpha(217),
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(51),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: Colors.white.withAlpha(102)),
                      ),
                      child: Text(
                        'Önerileri Gör →',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  'https://images.pexels.com/photos/1118873/pexels-photo-1118873.jpeg?auto=compress&cs=tinysrgb&w=400',
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  semanticLabel:
                      'Sunny day in a park with people enjoying outdoor activities',
                  errorBuilder: (_, __, ___) => Container(
                    width: 100,
                    height: 100,
                    color: Colors.white.withAlpha(51),
                    child: const Icon(
                      Icons.wb_sunny_rounded,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

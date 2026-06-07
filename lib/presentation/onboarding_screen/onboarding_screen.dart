import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../constants/app_constants.dart';
import '../../core/user_preferences_service.dart';
import '../../models/user_preferences_model.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import './widgets/onboarding_step_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final _prefsService = UserPreferencesService();

  int _currentStep = 0;

  late AnimationController _bgController;
  late AnimationController _contentController;
  late Animation<double> _bgAnimation;
  late Animation<double> _contentFade;
  late Animation<Offset> _contentSlide;

  String _selectedLanguage = 'Türkçe';
  String _selectedCurrency = 'TRY ₺';
  String _selectedStyle = 'Sakin';
  String _selectedBudget = 'Orta';

  bool _isLoading = false;

  final List<String> _bgImages = [
    'https://images.unsplash.com/photo-1506905925346-21bda4d32df4?w=800&auto=format&fit=crop',
    'https://images.pexels.com/photos/1007426/pexels-photo-1007426.jpeg?auto=compress&cs=tinysrgb&w=800',
    'https://images.unsplash.com/photo-1519681393784-d120267933ba?w=800&auto=format&fit=crop',
    'https://images.unsplash.com/photo-1469474968028-56623f02e42e?w=800&auto=format&fit=crop',
  ];

  final List<String> _bgSemanticLabels = [
    'Yeşil doğa manzarası',
    'Tarihi kale ve doğa',
    'Tarihi şehir sokağı',
    'Gün batımında dağ manzarası',
  ];

  @override
  void initState() {
    super.initState();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _contentController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _bgAnimation = CurvedAnimation(
      parent: _bgController,
      curve: Curves.easeOutCubic,
    );

    _contentFade = CurvedAnimation(
      parent: _contentController,
      curve: Curves.easeOutCubic,
    );

    _contentSlide = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _contentController,
        curve: Curves.easeOutCubic,
      ),
    );

    _bgController.forward();
    _contentController.forward();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _goNext() async {
    if (_currentStep < 3) {
      await _contentController.reverse();

      if (!mounted) return;

      setState(() {
        _currentStep++;
      });

      _contentController.forward();
      _bgController.forward(from: 0);
    } else {
      await _finish();
    }
  }

  Future<void> _goBack() async {
    if (_currentStep > 0) {
      await _contentController.reverse();

      if (!mounted) return;

      setState(() {
        _currentStep--;
      });

      _contentController.forward();
      _bgController.forward(from: 0);
    }
  }

  Future<void> _finish() async {
    setState(() {
      _isLoading = true;
    });

    final prefs = UserPreferencesModel(
      language: _selectedLanguage,
      currency: _selectedCurrency,
      travelStyle: _selectedStyle,
      budget: _selectedBudget,
    );

    await _prefsService.savePreferences(prefs);
    await _prefsService.setOnboardingDone();

    if (!mounted) return;

    context.go(AppRoutes.homeScreen);
  }

  @override
  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width >= 600;

    return Scaffold(
      body: Stack(
        children: [
          FadeTransition(
            opacity: _bgAnimation,
            child: SizedBox.expand(
              child: Image.network(
                _bgImages[_currentStep],
                fit: BoxFit.cover,
                semanticLabel: _bgSemanticLabels[_currentStep],
                errorBuilder: (_, __, ___) {
                  return Container(color: AppTheme.primary);
                },
              ),
            ),
          ),
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: [0.2, 0.55, 1.0],
                colors: [
                  Colors.transparent,
                  Color(0xCC0A2E1A),
                  Color(0xF51A3A28),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildStepIndicator(),
                const Spacer(),
                SlideTransition(
                  position: _contentSlide,
                  child: FadeTransition(
                    opacity: _contentFade,
                    child: isTablet
                        ? Center(
                            child: SizedBox(
                              width: 480,
                              child: _buildStepContent(),
                            ),
                          )
                        : _buildStepContent(),
                  ),
                ),
                const SizedBox(height: 32),
                _buildNavButtons(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 0),
      child: Row(
        children: [
          Text(
            'WanderMate',
            style: GoogleFonts.outfit(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const Spacer(),
          ...List.generate(4, (i) {
            final isActive = i == _currentStep;
            final isDone = i < _currentStep;

            return AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(left: 6),
              width: isActive ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: isActive
                    ? AppTheme.accent
                    : isDone
                        ? AppTheme.accent.withAlpha(128)
                        : Colors.white.withAlpha(89),
                borderRadius: BorderRadius.circular(999),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return OnboardingStepWidget(
          title: 'Merhaba! 👋',
          subtitle: 'Seni daha iyi tanıyalım.\nHangi dili tercih edersin?',
          options: AppConstants.languages,
          optionEmojis: const ['🇹🇷', '🇬🇧'],
          selectedValue: _selectedLanguage,
          onSelected: (v) {
            setState(() {
              _selectedLanguage = v;
            });
          },
        );
      case 1:
        return OnboardingStepWidget(
          title: 'Para Birimi 💳',
          subtitle: 'Fiyatları hangi para biriminde görmek istersin?',
          options: AppConstants.currencies,
          optionEmojis: const ['₺', '\$', '€'],
          selectedValue: _selectedCurrency,
          onSelected: (v) {
            setState(() {
              _selectedCurrency = v;
            });
          },
        );
      case 2:
        return OnboardingStepWidget(
          title: 'Gezi Tarzın 🗺️',
          subtitle: 'Nasıl bir gezgin olduğunu söyle!',
          options: AppConstants.travelStyles,
          optionEmojis: AppConstants.travelStyleEmojis,
          selectedValue: _selectedStyle,
          onSelected: (v) {
            setState(() {
              _selectedStyle = v;
            });
          },
        );
      case 3:
        return OnboardingStepWidget(
          title: 'Bütçen 💰',
          subtitle: 'Gezilerinde bütçe tercihini belirle.',
          options: AppConstants.budgetOptions,
          optionEmojis: AppConstants.budgetEmojis,
          selectedValue: _selectedBudget,
          onSelected: (v) {
            setState(() {
              _selectedBudget = v;
            });
          },
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildNavButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          if (_currentStep > 0)
            GestureDetector(
              onTap: _isLoading ? null : _goBack,
              child: Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: Colors.white.withAlpha(102)),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 12),
          Expanded(
            child: GestureDetector(
              onTap: _isLoading ? null : _goNext,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: AppTheme.accent,
                  borderRadius: BorderRadius.circular(999),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.accent.withAlpha(102),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _currentStep == 3
                                  ? 'Keşfetmeye Başla'
                                  : 'Devam Et',
                              style: GoogleFonts.outfit(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Icon(
                              _currentStep == 3
                                  ? Icons.explore_rounded
                                  : Icons.arrow_forward_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
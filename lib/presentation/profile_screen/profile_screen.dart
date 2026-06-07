import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';

import '../../models/user_preferences_model.dart';
import '../../core/user_preferences_service.dart';
import '../../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final UserPreferencesService _prefsService = UserPreferencesService();

  UserPreferencesModel _prefs = UserPreferencesModel.defaults;
  bool _isLoading = true;

  // Notification settings
  bool _notifTravelTips = true;
  bool _notifWeatherAlerts = true;
  bool _notifNewPlaces = false;
  bool _notifWeeklyDigest = true;

  // Account info
  final TextEditingController _nameController = TextEditingController(
    text: 'Gezgin Kullanıcı',
  );
  final TextEditingController _emailController = TextEditingController(
    text: 'kullanici@wandermate.app',
  );

  static const List<String> _languages = ['Türkçe', 'English'];
  static const List<String> _currencies = ['TRY ₺', 'USD \$', 'EUR €'];
  static const List<String> _travelStyles = [
    'Sakin',
    'Popüler',
    'Aile',
    'Romantik',
    'Öğrenci',
  ];
  static const List<String> _budgets = ['Ekonomik', 'Orta', 'Rahat'];

  static const Map<String, IconData> _travelStyleIcons = {
    'Sakin': Icons.spa_outlined,
    'Popüler': Icons.trending_up_rounded,
    'Aile': Icons.family_restroom_rounded,
    'Romantik': Icons.favorite_border_rounded,
    'Öğrenci': Icons.school_outlined,
  };

  static const Map<String, IconData> _budgetIcons = {
    'Ekonomik': Icons.savings_outlined,
    'Orta': Icons.account_balance_wallet_outlined,
    'Rahat': Icons.diamond_outlined,
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await _prefsService.getPreferences();
    final sp = await SharedPreferences.getInstance();
    setState(() {
      _prefs = prefs;
      _notifTravelTips = sp.getBool('notif_travel_tips') ?? true;
      _notifWeatherAlerts = sp.getBool('notif_weather_alerts') ?? true;
      _notifNewPlaces = sp.getBool('notif_new_places') ?? false;
      _notifWeeklyDigest = sp.getBool('notif_weekly_digest') ?? true;
      _nameController.text = sp.getString('account_name') ?? 'Gezgin Kullanıcı';
      _emailController.text =
          sp.getString('account_email') ?? 'kullanici@wandermate.app';
      _isLoading = false;
    });
  }

  Future<void> _savePreferences() async {
    await _prefsService.savePreferences(_prefs);
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('notif_travel_tips', _notifTravelTips);
    await sp.setBool('notif_weather_alerts', _notifWeatherAlerts);
    await sp.setBool('notif_new_places', _notifNewPlaces);
    await sp.setBool('notif_weekly_digest', _notifWeeklyDigest);
    await sp.setString('account_name', _nameController.text.trim());
    await sp.setString('account_email', _emailController.text.trim());
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg, style: GoogleFonts.outfit(fontSize: 13)),
        backgroundColor: AppTheme.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showEditAccountSheet() {
    final nameTmp = TextEditingController(text: _nameController.text);
    final emailTmp = TextEditingController(text: _emailController.text);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(5.w, 2.h, 5.w, 3.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 10.w,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppTheme.outlineLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Hesap Bilgileri',
                style: GoogleFonts.outfit(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1A2318),
                ),
              ),
              SizedBox(height: 2.h),
              TextField(
                controller: nameTmp,
                decoration: InputDecoration(
                  labelText: 'Ad Soyad',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                ),
                style: GoogleFonts.outfit(fontSize: 14.sp),
              ),
              SizedBox(height: 1.5.h),
              TextField(
                controller: emailTmp,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'E-posta',
                  prefixIcon: const Icon(Icons.email_outlined),
                ),
                style: GoogleFonts.outfit(fontSize: 14.sp),
              ),
              SizedBox(height: 2.5.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      _nameController.text = nameTmp.text.trim();
                      _emailController.text = emailTmp.text.trim();
                    });
                    await _savePreferences();
                    if (mounted) {
                      Navigator.pop(context);
                      _showSnack('Hesap bilgileri güncellendi ✓');
                    }
                  },
                  child: Text(
                    'Kaydet',
                    style: GoogleFonts.outfit(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
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

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: Center(child: CircularProgressIndicator(color: AppTheme.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundLight,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                _buildAccountCard(),
                SizedBox(height: 2.h),
                _buildSectionHeader('🌐 Dil & Para Birimi'),
                SizedBox(height: 1.h),
                _buildLanguageCard(),
                SizedBox(height: 1.5.h),
                _buildCurrencyCard(),
                SizedBox(height: 2.h),
                _buildSectionHeader('🧭 Gezi Tercihleri'),
                SizedBox(height: 1.h),
                _buildTravelStyleCard(),
                SizedBox(height: 1.5.h),
                _buildBudgetCard(),
                SizedBox(height: 2.h),
                _buildSectionHeader('🔔 Bildirim Ayarları'),
                SizedBox(height: 1.h),
                _buildNotificationsCard(),
                SizedBox(height: 2.h),
                _buildSectionHeader('⚙️ Uygulama'),
                SizedBox(height: 1.h),
                _buildAppSettingsCard(),
                SizedBox(height: 4.h),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 20.h,
      pinned: true,
      backgroundColor: AppTheme.surfaceLight,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.primaryLight],
            ),
          ),
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(height: 1.h),
                Container(
                  width: 16.w,
                  height: 16.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(40),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(100),
                      width: 2,
                    ),
                  ),
                  child: Icon(
                    Icons.person_rounded,
                    size: 9.w,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 1.h),
                Text(
                  _nameController.text,
                  style: GoogleFonts.outfit(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  _emailController.text,
                  style: GoogleFonts.outfit(
                    fontSize: 11.sp,
                    color: Colors.white.withAlpha(200),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      title: Text(
        'Profil',
        style: GoogleFonts.outfit(
          fontSize: 16.sp,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF1A2318),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(left: 1.w),
      child: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 13.sp,
          fontWeight: FontWeight.w700,
          color: AppTheme.primary,
        ),
      ),
    );
  }

  Widget _buildAccountCard() {
    return _SettingsCard(
      child: ListTile(
        contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 0.5.h),
        leading: Container(
          width: 10.w,
          height: 10.w,
          decoration: BoxDecoration(
            color: AppTheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.manage_accounts_rounded,
            color: AppTheme.primary,
          ),
        ),
        title: Text(
          _nameController.text,
          style: GoogleFonts.outfit(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF1A2318),
          ),
        ),
        subtitle: Text(
          _emailController.text,
          style: GoogleFonts.outfit(
            fontSize: 11.sp,
            color: const Color(0xFF4A5548),
          ),
        ),
        trailing: TextButton(
          onPressed: _showEditAccountSheet,
          child: Text(
            'Düzenle',
            style: GoogleFonts.outfit(
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLanguageCard() {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(3.w, 1.5.h, 3.w, 1.h),
            child: Row(
              children: [
                const Icon(
                  Icons.language_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Dil',
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A2318),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 1.5.h),
            child: Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: _languages.map((lang) {
                final selected = _prefs.language == lang;
                return GestureDetector(
                  onTap: () async {
                    setState(() => _prefs = _prefs.copyWith(language: lang));
                    await _savePreferences();
                    _showSnack('Dil güncellendi: $lang ✓');
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primary
                          : AppTheme.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primary
                            : AppTheme.outlineLight,
                      ),
                    ),
                    child: Text(
                      lang,
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF4A5548),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCurrencyCard() {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(3.w, 1.5.h, 3.w, 1.h),
            child: Row(
              children: [
                const Icon(
                  Icons.currency_exchange_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Para Birimi',
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A2318),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 1.5.h),
            child: Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: _currencies.map((cur) {
                final selected = _prefs.currency == cur;
                return GestureDetector(
                  onTap: () async {
                    setState(() => _prefs = _prefs.copyWith(currency: cur));
                    await _savePreferences();
                    _showSnack('Para birimi güncellendi: $cur ✓');
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 4.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primary
                          : AppTheme.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primary
                            : AppTheme.outlineLight,
                      ),
                    ),
                    child: Text(
                      cur,
                      style: GoogleFonts.outfit(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: selected
                            ? Colors.white
                            : const Color(0xFF4A5548),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTravelStyleCard() {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(3.w, 1.5.h, 3.w, 1.h),
            child: Row(
              children: [
                const Icon(
                  Icons.explore_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Gezi Tarzı',
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A2318),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 1.5.h),
            child: Wrap(
              spacing: 2.w,
              runSpacing: 1.h,
              children: _travelStyles.map((style) {
                final selected = _prefs.travelStyle == style;
                final icon =
                    _travelStyleIcons[style] ?? Icons.travel_explore_rounded;
                return GestureDetector(
                  onTap: () async {
                    setState(
                      () => _prefs = _prefs.copyWith(travelStyle: style),
                    );
                    await _savePreferences();
                    _showSnack('Gezi tarzı güncellendi: $style ✓');
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 3.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: selected
                          ? AppTheme.primary
                          : AppTheme.surfaceVariantLight,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: selected
                            ? AppTheme.primary
                            : AppTheme.outlineLight,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          icon,
                          size: 14,
                          color: selected ? Colors.white : AppTheme.primary,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          style,
                          style: GoogleFonts.outfit(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : const Color(0xFF4A5548),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBudgetCard() {
    return _SettingsCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(3.w, 1.5.h, 3.w, 1.h),
            child: Row(
              children: [
                const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: AppTheme.primary,
                  size: 20,
                ),
                SizedBox(width: 2.w),
                Text(
                  'Bütçe',
                  style: GoogleFonts.outfit(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A2318),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(3.w, 0, 3.w, 1.5.h),
            child: Row(
              children: _budgets.map((budget) {
                final selected = _prefs.budget == budget;
                final icon = _budgetIcons[budget] ?? Icons.attach_money_rounded;
                return Expanded(
                  child: GestureDetector(
                    onTap: () async {
                      setState(() => _prefs = _prefs.copyWith(budget: budget));
                      await _savePreferences();
                      _showSnack('Bütçe güncellendi: $budget ✓');
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: EdgeInsets.only(
                        right: budget != _budgets.last ? 2.w : 0,
                      ),
                      padding: EdgeInsets.symmetric(vertical: 1.5.h),
                      decoration: BoxDecoration(
                        color: selected
                            ? AppTheme.primary
                            : AppTheme.surfaceVariantLight,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selected
                              ? AppTheme.primary
                              : AppTheme.outlineLight,
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            icon,
                            size: 20,
                            color: selected ? Colors.white : AppTheme.primary,
                          ),
                          SizedBox(height: 0.5.h),
                          Text(
                            budget,
                            style: GoogleFonts.outfit(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w600,
                              color: selected
                                  ? Colors.white
                                  : const Color(0xFF4A5548),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsCard() {
    return _SettingsCard(
      child: Column(
        children: [
          _NotifTile(
            icon: Icons.lightbulb_outline_rounded,
            title: 'Gezi İpuçları',
            subtitle: 'Kişiselleştirilmiş seyahat önerileri',
            value: _notifTravelTips,
            onChanged: (v) async {
              setState(() => _notifTravelTips = v);
              await _savePreferences();
            },
          ),
          _divider(),
          _NotifTile(
            icon: Icons.wb_cloudy_outlined,
            title: 'Hava Durumu Uyarıları',
            subtitle: 'Anlık hava değişikliği bildirimleri',
            value: _notifWeatherAlerts,
            onChanged: (v) async {
              setState(() => _notifWeatherAlerts = v);
              await _savePreferences();
            },
          ),
          _divider(),
          _NotifTile(
            icon: Icons.place_outlined,
            title: 'Yeni Mekanlar',
            subtitle: 'Yakınındaki yeni açılan yerler',
            value: _notifNewPlaces,
            onChanged: (v) async {
              setState(() => _notifNewPlaces = v);
              await _savePreferences();
            },
          ),
          _divider(),
          _NotifTile(
            icon: Icons.calendar_today_outlined,
            title: 'Haftalık Özet',
            subtitle: 'Haftalık gezi önerileri bülteni',
            value: _notifWeeklyDigest,
            onChanged: (v) async {
              setState(() => _notifWeeklyDigest = v);
              await _savePreferences();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettingsCard() {
    return _SettingsCard(
      child: Column(
        children: [
          _AppSettingsTile(
            icon: Icons.delete_outline_rounded,
            iconColor: AppTheme.error,
            title: 'Arama Geçmişini Temizle',
            onTap: () async {
              final sp = await SharedPreferences.getInstance();
              await sp.remove('search_history');
              _showSnack('Arama geçmişi temizlendi ✓');
            },
          ),
          _divider(),
          _AppSettingsTile(
            icon: Icons.restart_alt_rounded,
            iconColor: AppTheme.warning,
            title: 'Tercihleri Sıfırla',
            onTap: () => _showResetDialog(),
          ),
          _divider(),
          _AppSettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: AppTheme.info,
            title: 'Uygulama Hakkında',
            subtitle: 'WanderMate v1.0.0',
            onTap: () => _showAboutDialog(),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Divider(
    height: 1,
    thickness: 1,
    color: AppTheme.outlineVariantLight,
    indent: 16,
    endIndent: 16,
  );

  void _showResetDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Tercihleri Sıfırla',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        content: Text(
          'Tüm tercihleriniz varsayılan değerlere döndürülecek. Devam etmek istiyor musunuz?',
          style: GoogleFonts.outfit(fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'İptal',
              style: GoogleFonts.outfit(color: AppTheme.primary),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              setState(() => _prefs = UserPreferencesModel.defaults);
              await _savePreferences();
              if (mounted) {
                Navigator.pop(ctx);
                _showSnack('Tercihler sıfırlandı ✓');
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error),
            child: Text('Sıfırla', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
  }

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.travel_explore_rounded,
                color: AppTheme.primary,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'WanderMate',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Versiyon: 1.0.0', style: GoogleFonts.outfit(fontSize: 13)),
            const SizedBox(height: 4),
            Text(
              'AI destekli, Google Maps entegreli gezi ve şehir keşif uygulaması.',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: const Color(0xFF4A5548),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Tamam', style: GoogleFonts.outfit()),
          ),
        ],
      ),
    );
  }
}

// ─── Reusable sub-widgets ────────────────────────────────────────────────────

class _SettingsCard extends StatelessWidget {
  final Widget child;
  const _SettingsCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF2D6A4F).withAlpha(15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _NotifTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _NotifTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppTheme.primaryContainer.withAlpha(150),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: AppTheme.primary, size: 18),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A2318),
        ),
      ),
      subtitle: Text(
        subtitle,
        style: GoogleFonts.outfit(fontSize: 11, color: const Color(0xFF4A5548)),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppTheme.primary,
        activeTrackColor: AppTheme.primary.withValues(alpha: 0.4),
      ),
    );
  }
}

class _AppSettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _AppSettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(30),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: GoogleFonts.outfit(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF1A2318),
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: GoogleFonts.outfit(
                fontSize: 11,
                color: const Color(0xFF4A5548),
              ),
            )
          : null,
      trailing: const Icon(
        Icons.chevron_right_rounded,
        color: Color(0xFF9E9E9E),
      ),
      onTap: onTap,
    );
  }
}

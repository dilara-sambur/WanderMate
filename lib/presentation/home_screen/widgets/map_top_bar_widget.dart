import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/weather_service.dart';
import '../../../theme/app_theme.dart';

class MapTopBarWidget extends StatelessWidget {
  final String cityName;
  final WeatherData? weather;
  final String travelStyle;
  final bool isLoading;

  const MapTopBarWidget({
    super.key,
    required this.cityName,
    required this.weather,
    required this.travelStyle,
    required this.isLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: AppTheme.glassmorphismDecoration(radius: 20),
        child: Row(
          children: [
            // Location
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.location_on_rounded,
                        size: 14,
                        color: AppTheme.primary,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isLoading ? 'Konum alınıyor...' : cityName,
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 16,
                        color: AppTheme.primary,
                      ),
                    ],
                  ),
                  // Weather row
                  if (weather != null)
                    Row(
                      children: [
                        Text(
                          weather!.weatherEmoji,
                          style: const TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${weather!.temperature.round()}°C',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF1A2318),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.accent.withAlpha(51),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            travelStyle,
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.accentDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // Actions
            Row(
              children: [
                // Chat icon
                _TopBarIconButton(
                  icon: Icons.chat_bubble_outline_rounded,
                  badge: null,
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                // Notifications
                _TopBarIconButton(
                  icon: Icons.notifications_outlined,
                  badge: '2',
                  onTap: () {},
                ),
                const SizedBox(width: 8),
                // Avatar
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primaryContainer,
                    border: Border.all(
                      color: AppTheme.primary.withAlpha(77),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    size: 20,
                    color: AppTheme.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TopBarIconButton extends StatelessWidget {
  final IconData icon;
  final String? badge;
  final VoidCallback onTap;

  const _TopBarIconButton({
    required this.icon,
    required this.badge,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primary.withAlpha(20),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, size: 18, color: const Color(0xFF1A2318)),
          ),
          if (badge != null)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 16,
                height: 16,
                decoration: const BoxDecoration(
                  color: AppTheme.error,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    badge!,
                    style: GoogleFonts.outfit(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
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

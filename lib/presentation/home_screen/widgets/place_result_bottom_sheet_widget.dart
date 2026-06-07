import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../models/place_model.dart';
import '../../../theme/app_theme.dart';

class PlaceResultBottomSheetWidget extends StatelessWidget {
  final List<PlaceModel> places;
  final String query;
  final double userLat;
  final double userLng;

  const PlaceResultBottomSheetWidget({
    super.key,
    required this.places,
    required this.query,
    required this.userLat,
    required this.userLng,
  });

  Future<void> _openDirections(PlaceModel place) async {
    final url =
        'https://www.google.com/maps/dir/?api=1&origin=$userLat,$userLng&destination=${place.lat},${place.lng}&travelmode=walking';

    final uri = Uri.parse(url);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.62,
      minChildSize: 0.35,
      maxChildSize: 0.94,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surfaceLight,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
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
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${places.length} Sonuç Bulundu',
                            style: GoogleFonts.outfit(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1A2318),
                            ),
                          ),
                          Text(
                            '"$query"',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              color: const Color(0xFF9E9E9E),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppTheme.surfaceVariantLight,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 18,
                          color: Color(0xFF4A5548),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              Expanded(
                child: places.isEmpty
                    ? _buildEmpty()
                    : ListView.builder(
                        controller: scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: places.length,
                        itemBuilder: (context, i) {
                          return _PlaceDetailCard(
                            place: places[i],
                            onDirections: () => _openDirections(places[i]),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 56,
            color: AppTheme.outlineLight,
          ),
          const SizedBox(height: 12),
          Text(
            'Sonuç bulunamadı',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF4A5548),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlaceDetailCard extends StatelessWidget {
  final PlaceModel place;
  final VoidCallback onDirections;

  const _PlaceDetailCard({
    required this.place,
    required this.onDirections,
  });

  Color get _crowdColor {
    switch (place.crowdLevel) {
      case CrowdLevel.low:
        return AppTheme.crowdLow;
      case CrowdLevel.medium:
        return AppTheme.crowdMedium;
      case CrowdLevel.high:
        return AppTheme.crowdHigh;
    }
  }

  String get _crowdLabel {
    switch (place.crowdLevel) {
      case CrowdLevel.low:
        return 'Sakin';
      case CrowdLevel.medium:
        return 'Orta';
      case CrowdLevel.high:
        return 'Kalabalık';
    }
  }

void _reportCrowd(BuildContext context, String label, String emoji) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$label olarak bildirildi'),
      duration: const Duration(seconds: 2),
    ),
  );
}

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: AppTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                child: Image.network(
                  place.imageUrl,
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  semanticLabel: place.semanticLabel,
                  errorBuilder: (_, __, ___) {
                    return Container(
                      height: 180,
                      color: AppTheme.primaryContainer,
                      child: const Icon(
                        Icons.image_rounded,
                        size: 48,
                        color: AppTheme.primary,
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(166),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    place.distanceKm != null
                        ? '${place.distanceKm!.toStringAsFixed(1)} km'
                        : '—',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: place.isOpen
                        ? AppTheme.crowdLow.withAlpha(230)
                        : AppTheme.crowdHigh.withAlpha(230),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    place.isOpen ? 'Açık' : 'Kapalı',
                    style: GoogleFonts.outfit(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        place.name,
                        style: GoogleFonts.outfit(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1A2318),
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _crowdColor.withAlpha(31),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: _crowdColor.withAlpha(77)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _crowdColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _crowdLabel,
                            style: GoogleFonts.outfit(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: _crowdColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    ...List.generate(5, (i) {
                      final filled = i < place.rating.round();

                      return Icon(
                        filled
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        size: 16,
                        color: const Color(0xFFF39C12),
                      );
                    }),
                    const SizedBox(width: 6),
                    Text(
                      '${place.rating.toStringAsFixed(1)} (${place.reviewCount} yorum)',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: const Color(0xFF4A5548),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: AppTheme.primary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        place.address,
                        style: GoogleFonts.outfit(
                          fontSize: 12,
                          color: const Color(0xFF9E9E9E),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),

                Text(
                  'Yoğunluk Bildir',
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF1A2318),
                  ),
                ),

                const SizedBox(height: 8),

                Row(
  children: [
    Expanded(
      child: OutlinedButton(
        onPressed: () => _reportCrowd(context, 'Sakin', ''),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size(0, 44),
          side: const BorderSide(color: AppTheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'Sakin',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
          ),
        ),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: OutlinedButton(
        onPressed: () => _reportCrowd(context, 'Orta yoğunluk', ''),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size(0, 44),
          side: const BorderSide(color: AppTheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'Orta',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
          ),
        ),
      ),
    ),
    const SizedBox(width: 8),
    Expanded(
      child: OutlinedButton(
        onPressed: () => _reportCrowd(context, 'Yoğun', ''),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          minimumSize: const Size(0, 44),
          side: const BorderSide(color: AppTheme.primary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: Text(
          'Yoğun',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.primary,
          ),
        ),
      ),
    ),
  ],
),
                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onDirections,
                        icon: const Icon(Icons.map_outlined, size: 16),
                        label: Text(
                          'Haritada Aç',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: const BorderSide(color: AppTheme.primary),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: onDirections,
                        icon: const Icon(Icons.directions_rounded, size: 16),
                        label: Text(
                          'Yol Tarifi',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
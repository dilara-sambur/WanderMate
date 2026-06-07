import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../constants/app_constants.dart';
import '../../../theme/app_theme.dart';

class SmartSearchPanelWidget extends StatefulWidget {
  final bool isLoading;
  final ValueChanged<String> onSearch;

  const SmartSearchPanelWidget({
    super.key,
    required this.isLoading,
    required this.onSearch,
  });

  @override
  State<SmartSearchPanelWidget> createState() => _SmartSearchPanelWidgetState();
}

class _SmartSearchPanelWidgetState extends State<SmartSearchPanelWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  int _placeholderIndex = 0;
  Timer? _placeholderTimer;

  @override
  void initState() {
    super.initState();
    _placeholderTimer = Timer.periodic(const Duration(seconds: 3), (_) {
      if (mounted && !_focusNode.hasFocus) {
        setState(() {
          _placeholderIndex =
              (_placeholderIndex + 1) % AppConstants.searchPlaceholders.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _placeholderTimer?.cancel();
    super.dispose();
  }

  void _submit() {
    final q = _controller.text.trim();
    if (q.isNotEmpty) {
      widget.onSearch(q);
      _controller.clear();
      _focusNode.unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Bugün ne keşfetmek istersin?',
            style: GoogleFonts.outfit(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1A2318),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariantLight,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.outlineLight),
            ),
            child: Row(
              children: [
                const SizedBox(width: 14),
                Icon(
                  widget.isLoading
                      ? Icons.hourglass_top_rounded
                      : Icons.search_rounded,
                  size: 20,
                  color: AppTheme.primary,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: TextField(
                      key: ValueKey(_placeholderIndex),
                      controller: _controller,
                      focusNode: _focusNode,
                      onSubmitted: (_) => _submit(),
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        color: const Color(0xFF1A2318),
                      ),
                      decoration: InputDecoration(
                        hintText:
                            AppConstants.searchPlaceholders[_placeholderIndex],
                        hintStyle: GoogleFonts.outfit(
                          fontSize: 13,
                          color: const Color(0xFF9E9E9E),
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 14,
                        ),
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                // Filter badge button
                GestureDetector(
                  onTap: () {},
                  child: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        const Icon(
                          Icons.tune_rounded,
                          size: 16,
                          color: Colors.white,
                        ),
                        Positioned(
                          top: -6,
                          right: -6,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: AppTheme.accent,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white,
                                width: 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                '2',
                                style: GoogleFonts.outfit(
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

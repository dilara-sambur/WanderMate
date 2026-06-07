import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

class _TabSpec {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final int branchIndex;

  const _TabSpec({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.branchIndex,
  });
}

class AppNavigation extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const AppNavigation({
    required this.navigationShell,
    super.key,
  });

  @override
  State<AppNavigation> createState() => _AppNavigationState();
}

class _AppNavigationState extends State<AppNavigation>
    with SingleTickerProviderStateMixin {
  late AnimationController _capsuleController;
  late Animation<double> _capsuleAnimation;

  int _selectedVisualIndex = 0;
  double _capsuleTargetX = 0;
  double _capsulePrevX = 0;

  final List<_TabSpec> _tabs = const [
    _TabSpec(
      label: 'Harita',
      icon: Icons.map_outlined,
      selectedIcon: Icons.map_rounded,
      branchIndex: 0,
    ),
    _TabSpec(
      label: 'Keşfet',
      icon: Icons.explore_outlined,
      selectedIcon: Icons.explore_rounded,
      branchIndex: 1,
    ),
    _TabSpec(
      label: 'Profil',
      icon: Icons.person_outline_rounded,
      selectedIcon: Icons.person_rounded,
      branchIndex: 2,
    ),
  ];

  @override
  void initState() {
    super.initState();

    _capsuleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _capsuleAnimation = CurvedAnimation(
      parent: _capsuleController,
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _capsuleController.dispose();
    super.dispose();
  }

  void _onTabTap(int visualIndex, double tabWidth) {
    final tab = _tabs[visualIndex];

    setState(() {
      _capsulePrevX = _selectedVisualIndex * tabWidth;
      _capsuleTargetX = visualIndex * tabWidth;
      _selectedVisualIndex = visualIndex;
    });

    _capsuleController.forward(from: 0);

    widget.navigationShell.goBranch(
      tab.branchIndex,
      initialLocation: tab.branchIndex == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    _selectedVisualIndex = widget.navigationShell.currentIndex;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceLight,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: LayoutBuilder(
            builder: (context, constraints) {
              final tabWidth = constraints.maxWidth / _tabs.length;

              return Stack(
                children: [
                  AnimatedBuilder(
                    animation: _capsuleAnimation,
                    builder: (context, _) {
                      final currentX = _capsulePrevX +
                          (_capsuleTargetX - _capsulePrevX) *
                              _capsuleAnimation.value;

                      return Positioned(
                        left: currentX + 8,
                        top: 8,
                        width: tabWidth - 16,
                        height: 48,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppTheme.primaryContainer.withAlpha(153),
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                      );
                    },
                  ),
                  Row(
                    children: List.generate(_tabs.length, (index) {
                      final tab = _tabs[index];
                      final isActive = index == _selectedVisualIndex;

                      return GestureDetector(
                        onTap: () => _onTabTap(index, tabWidth),
                        behavior: HitTestBehavior.opaque,
                        child: SizedBox(
                          width: tabWidth,
                          height: 64,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                isActive ? tab.selectedIcon : tab.icon,
                                size: 22,
                                color: isActive
                                    ? AppTheme.primary
                                    : const Color(0xFF9E9E9E),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                tab.label,
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: isActive
                                      ? FontWeight.w600
                                      : FontWeight.w400,
                                  color: isActive
                                      ? AppTheme.primary
                                      : const Color(0xFF9E9E9E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
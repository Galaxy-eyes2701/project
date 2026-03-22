import 'package:flutter/material.dart';
import 'package:project/views/shopping/shopping_list_view.dart';
import '../feast/feast_list_view.dart';
import '../recipe/recipe_list_view.dart';

class _AppColors {
  static const red       = Color(0xFFC0392B);
  static const redDark   = Color(0xFF96231B);
  static const gold      = Color(0xFFD4A017);
  static const goldLight = Color(0xFFF0C040);
  static const cream     = Color(0xFFFDF6EC);
  static const dark      = Color(0xFF1A0A00);
  static const muted     = Color(0xFF7D5A3C);
  static const cardBg    = Color(0xFFFFFBF5);
}

class MainView extends StatefulWidget {
  const MainView({super.key});

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animController;

  final List<Widget> _pages = [
    const FeastListView(),
    const RecipeListView(),
    const ShoppingListView(),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
    _animController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 220),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeIn,
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _pages[_currentIndex],
        ),
      ),
      bottomNavigationBar: _TetBottomNav(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}

// ─── Bottom Nav tuỳ chỉnh ────────────────────────────────────────────────────
class _TetBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const _TetBottomNav({required this.currentIndex, required this.onTap});

  static const _items = [
    _NavItem(icon: Icons.table_bar_rounded,       activeIcon: Icons.table_bar,        label: 'Mâm Cỗ'),
    _NavItem(icon: Icons.menu_book_outlined,       activeIcon: Icons.menu_book,         label: 'Công Thức'),
    _NavItem(icon: Icons.shopping_basket_outlined, activeIcon: Icons.shopping_basket,   label: 'Đi Chợ'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _AppColors.cardBg,
        boxShadow: [
          BoxShadow(
            color: _AppColors.dark.withOpacity(.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
        border: Border(
          top: BorderSide(color: _AppColors.red.withOpacity(.08), width: 1),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 68,
          child: Row(
            children: List.generate(_items.length, (index) {
              final item   = _items[index];
              final active = index == currentIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(index),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    curve: Curves.easeOutCubic,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon với indicator pill
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 18, vertical: 6),
                          decoration: BoxDecoration(
                            color: active
                                ? _AppColors.red.withOpacity(.1)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            active ? item.activeIcon : item.icon,
                            color: active ? _AppColors.red : _AppColors.muted,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 2),
                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: active ? FontWeight.w700 : FontWeight.w400,
                            color: active ? _AppColors.red : _AppColors.muted,
                          ),
                          child: Text(item.label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String label;
  const _NavItem({required this.icon, required this.activeIcon, required this.label});
}
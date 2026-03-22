import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/feast.dart';
import '../../domain/entities/recipe.dart';
import '../../viewmodels/feast_viewmodel.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import '../recipe/recipe_detail_view.dart';
import '../recipe/recipe_form_view.dart';

// ─── Bảng màu Tết ───────────────────────────────────────────────────────────
class _AppColors {
  static const red       = Color(0xFFC0392B);
  static const redDark   = Color(0xFF96231B);
  static const redLight  = Color(0xFFE74C3C);
  static const gold      = Color(0xFFD4A017);
  static const goldLight = Color(0xFFF0C040);
  static const cream     = Color(0xFFFDF6EC);
  static const dark      = Color(0xFF1A0A00);
  static const muted     = Color(0xFF7D5A3C);
  static const cardBg    = Color(0xFFFFFBF5);
}

// ─── Enum sắp xếp ────────────────────────────────────────────────────────────
enum _SortMode { nameAsc, nameDesc, secretFirst, normalFirst }

// ─── FeastDetailView — StatefulWidget để quản lý search + sort ───────────────
class FeastDetailView extends StatefulWidget {
  final Feast feast;
  const FeastDetailView({super.key, required this.feast});

  @override
  State<FeastDetailView> createState() => _FeastDetailViewState();
}

class _FeastDetailViewState extends State<FeastDetailView> {
  bool _isSearchOpen = false;
  bool _filterSecretOnly = false;
  _SortMode _sortMode = _SortMode.nameAsc;

  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Lọc + sắp xếp ──────────────────────────────────────────────────────────
  List<Recipe> _processedRecipes(List<Recipe> recipes) {
    var list = recipes.where((r) {
      final matchSearch = _searchQuery.isEmpty ||
          r.name.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchSecret = !_filterSecretOnly || r.isFamilySecret;
      return matchSearch && matchSecret;
    }).toList();

    switch (_sortMode) {
      case _SortMode.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case _SortMode.nameDesc:
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case _SortMode.secretFirst:
        list.sort((a, b) {
          if (a.isFamilySecret == b.isFamilySecret) return 0;
          return a.isFamilySecret ? -1 : 1;
        });
        break;
      case _SortMode.normalFirst:
        list.sort((a, b) {
          if (a.isFamilySecret == b.isFamilySecret) return 0;
          return a.isFamilySecret ? 1 : -1;
        });
        break;
    }
    return list;
  }

  String get _sortLabel {
    switch (_sortMode) {
      case _SortMode.nameAsc:     return 'Tên A→Z';
      case _SortMode.nameDesc:    return 'Tên Z→A';
      case _SortMode.secretFirst: return 'Bí kíp trước';
      case _SortMode.normalFirst: return 'Thường trước';
    }
  }

  // ── Menu 3 chấm ─────────────────────────────────────────────────────────────
  void _showOptionsMenu(BuildContext context) {
    final RenderBox button  = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
    Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(
            button.size.bottomRight(Offset.zero), ancestor: overlay),
      ),
      Offset.zero & overlay.size,
    );

    showMenu<String>(
      context: context,
      position: position,
      color: _AppColors.cardBg,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 8,
      items: [
        _menuHeader('SẮP XẾP'),
        _sortItem('name_asc',     Icons.sort_by_alpha_rounded, 'Tên A → Z',     _sortMode == _SortMode.nameAsc),
        _sortItem('name_desc',    Icons.sort_by_alpha_rounded, 'Tên Z → A',     _sortMode == _SortMode.nameDesc),
        _sortItem('secret_first', Icons.lock_rounded,          'Bí kíp trước',  _sortMode == _SortMode.secretFirst),
        _sortItem('normal_first', Icons.restaurant_rounded,    'Thường trước',  _sortMode == _SortMode.normalFirst),
        _menuDivider(),
        _menuHeader('HIỂN THỊ'),
        _toggleItem('filter_secret', Icons.lock_rounded,
            'Chỉ bí kíp gia truyền', _filterSecretOnly, _AppColors.gold),
      ],
    ).then((value) {
      if (value == null) return;
      setState(() {
        switch (value) {
          case 'name_asc':      _sortMode = _SortMode.nameAsc; break;
          case 'name_desc':     _sortMode = _SortMode.nameDesc; break;
          case 'secret_first':  _sortMode = _SortMode.secretFirst; break;
          case 'normal_first':  _sortMode = _SortMode.normalFirst; break;
          case 'filter_secret': _filterSecretOnly = !_filterSecretOnly; break;
        }
      });
    });
  }

  PopupMenuItem<String> _menuHeader(String text) => PopupMenuItem<String>(
    enabled: false,
    height: 32,
    child: Text(text,
        style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: _AppColors.muted.withOpacity(.6),
            letterSpacing: .8)),
  );

  PopupMenuItem<String> _menuDivider() => PopupMenuItem<String>(
    enabled: false,
    height: 1,
    child: Divider(color: Colors.grey.shade200, height: 1),
  );

  PopupMenuItem<String> _sortItem(
      String value, IconData icon, String label, bool isActive) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: isActive ? _AppColors.red : _AppColors.muted),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? _AppColors.red : _AppColors.dark)),
          if (isActive) ...[
            const Spacer(),
            const Icon(Icons.check_rounded, size: 16, color: _AppColors.red),
          ],
        ],
      ),
    );
  }

  PopupMenuItem<String> _toggleItem(
      String value, IconData icon, String label, bool isOn, Color color) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon, size: 18, color: isOn ? color : _AppColors.muted),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: isOn ? FontWeight.w700 : FontWeight.w500,
                  color: isOn ? color : _AppColors.dark)),
          const Spacer(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 36, height: 20,
            decoration: BoxDecoration(
              color: isOn ? color : Colors.grey.shade300,
              borderRadius: BorderRadius.circular(10),
            ),
            child: AnimatedAlign(
              duration: const Duration(milliseconds: 200),
              alignment: isOn ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 16, height: 16,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: const BoxDecoration(
                    color: Colors.white, shape: BoxShape.circle),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final feastViewModel = context.watch<FeastViewModel>();

    return Scaffold(
      backgroundColor: _AppColors.cream,
      body: FutureBuilder<List<Recipe>>(
        future: feastViewModel.loadRecipesForFeast(widget.feast.id!),
        builder: (context, snapshot) {
          final isLoading  = snapshot.connectionState == ConnectionState.waiting;
          final allRecipes = snapshot.data ?? [];
          final recipes    = _processedRecipes(allRecipes);

          return CustomScrollView(
            slivers: [
              // ── AppBar ─────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                stretch: true,
                backgroundColor: _AppColors.red,
                leading: Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                actions: [
                  // Nút kính lúp — toggle search
                  IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        _isSearchOpen
                            ? Icons.close_rounded
                            : Icons.search_rounded,
                        key: ValueKey(_isSearchOpen),
                        color: Colors.white,
                      ),
                    ),
                    onPressed: () => setState(() {
                      _isSearchOpen = !_isSearchOpen;
                      if (!_isSearchOpen) {
                        _searchController.clear();
                        _searchQuery = '';
                      }
                    }),
                  ),
                  // Nút 3 chấm — dùng Builder để lấy đúng RenderBox
                  Builder(
                    builder: (btnCtx) => IconButton(
                      icon: const Icon(Icons.more_vert_rounded,
                          color: Colors.white),
                      onPressed: () => _showOptionsMenu(btnCtx),
                    ),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Gradient nền
                      Container(
                        decoration: const BoxDecoration(
                          gradient: LinearGradient(
                            colors: [_AppColors.redDark, _AppColors.red],
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                          ),
                        ),
                      ),
                      // Vòng trang trí
                      Positioned(
                        top: -50, right: -30,
                        child: Container(
                          width: 180, height: 180,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: _AppColors.gold.withOpacity(.25),
                                width: 2),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 10, right: 40,
                        child: Container(
                          width: 90, height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                                color: _AppColors.gold.withOpacity(.15),
                                width: 1.5),
                          ),
                        ),
                      ),
                      // Nội dung header
                      Positioned(
                        left: 20, right: 20, bottom: 28,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: _AppColors.gold.withOpacity(.18),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                    color: _AppColors.gold.withOpacity(.45)),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('🎊 ', style: TextStyle(fontSize: 11)),
                                  Text('MÂM CỖ TẾT',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _AppColors.goldLight,
                                        letterSpacing: .8,
                                      )),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              widget.feast.name,
                              style: const TextStyle(
                                fontFamily: 'Playfair Display',
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 10),
                            // Meta pills: số món + thời gian nấu
                            FutureBuilder<String?>(
                              future: feastViewModel
                                  .getTotalCookingTime(widget.feast.id!),
                              builder: (context, snap) {
                                return Row(
                                  children: [
                                    _MetaPill(
                                      icon: Icons.restaurant_rounded,
                                      label: isLoading
                                          ? 'Đang tải...'
                                          : '${allRecipes.length} món',
                                    ),
                                    if (snap.data != null) ...[
                                      const SizedBox(width: 10),
                                      _MetaPill(
                                        icon: Icons.schedule_rounded,
                                        label: snap.data!,
                                      ),
                                    ],
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),

                      // ── SearchBar trượt xuống ───────────────────────────
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        left: 16, right: 16,
                        bottom: _isSearchOpen ? 16 : -52,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 250),
                          opacity: _isSearchOpen ? 1.0 : 0.0,
                          child: Container(
                            height: 44,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: _AppColors.redDark.withOpacity(.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              controller: _searchController,
                              autofocus: _isSearchOpen,
                              onChanged: (v) =>
                                  setState(() => _searchQuery = v),
                              style: const TextStyle(
                                  fontSize: 14, color: _AppColors.dark),
                              decoration: InputDecoration(
                                hintText: 'Tìm tên món ăn...',
                                hintStyle: TextStyle(
                                    color: _AppColors.muted.withOpacity(.5),
                                    fontSize: 14),
                                prefixIcon: const Icon(Icons.search_rounded,
                                    color: _AppColors.red, size: 20),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                  icon: const Icon(Icons.close_rounded,
                                      size: 18,
                                      color: _AppColors.muted),
                                  onPressed: () => setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  }),
                                )
                                    : null,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 12),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Wave divider ──────────────────────────────────────────────
              SliverToBoxAdapter(
                child: SizedBox(
                  height: 28,
                  child: Stack(
                    children: [
                      Container(color: _AppColors.red, height: 14),
                      Container(
                        height: 28,
                        decoration: const BoxDecoration(
                          color: _AppColors.cream,
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Section header + active chips ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                  child: Row(
                    children: [
                      const Text(
                        'Danh sách món',
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _AppColors.dark,
                        ),
                      ),
                      const Spacer(),
                      // Chip sort (ẩn khi mặc định)
                      if (_sortMode != _SortMode.nameAsc)
                        _ActiveChip(
                            label: _sortLabel, color: _AppColors.red),
                      // Chip filter bí kíp
                      if (_filterSecretOnly)
                        _ActiveChip(
                            label: '🔑 Bí kíp', color: _AppColors.gold),
                      const SizedBox(width: 4),
                      if (!isLoading && allRecipes.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _AppColors.red,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text('${recipes.length} món',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700)),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Nội dung chính ────────────────────────────────────────────
              if (isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(color: _AppColors.red),
                  ),
                )
              else if (recipes.isEmpty)
                SliverFillRemaining(
                  child: _searchQuery.isNotEmpty
                      ? _SearchEmptyState(query: _searchQuery)
                      : _EmptyState(),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                          (context, index) {
                        final recipe = recipes[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _RecipeCard(
                            recipe: recipe,
                            index: index,
                            onTap: () {
                              if (recipe.isFamilySecret) {
                                _showPinDialog(context, recipe);
                              } else {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RecipeDetailView(recipe: recipe),
                                  ),
                                );
                              }
                            },
                            onRemove: () =>
                                feastViewModel.removeRecipeFromFeast(
                                    widget.feast.id!, recipe.id!),
                          ),
                        );
                      },
                      childCount: recipes.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _AddRecipeFab(
        onTap: () => _showAddRecipeBottomSheet(context),
      ),
    );
  }

  // ── PIN Dialog ──────────────────────────────────────────────────────────────
  void _showPinDialog(BuildContext context, Recipe recipe) {
    final pinController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => Dialog(
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: _AppColors.cardBg,
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64, height: 64,
                decoration: BoxDecoration(
                  color: _AppColors.gold.withOpacity(.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.lock_rounded,
                    color: _AppColors.gold, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Bí Kíp Gia Truyền',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _AppColors.dark,
                  )),
              const SizedBox(height: 8),
              Text(
                'Nhập mã PIN để mở khoá công thức bí mật của gia đình.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: _AppColors.muted, height: 1.5),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 4,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 12,
                  color: _AppColors.dark,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: TextStyle(
                      color: _AppColors.muted.withOpacity(.4),
                      letterSpacing: 12),
                  filled: true,
                  fillColor: _AppColors.cream,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: _AppColors.gold.withOpacity(.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: _AppColors.gold.withOpacity(.3)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                    const BorderSide(color: _AppColors.gold, width: 2),
                  ),
                ),
                autofocus: true,
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(dialogContext),
                      style: TextButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: Text('Hủy',
                          style: TextStyle(
                              color: _AppColors.muted,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (pinController.text == '6868') {
                          Navigator.pop(dialogContext);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      RecipeDetailView(recipe: recipe)));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: const Row(
                                children: [
                                  Icon(Icons.error_outline,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text('Mã PIN không chính xác!'),
                                ],
                              ),
                              backgroundColor: _AppColors.red,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                          pinController.clear();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _AppColors.gold,
                        foregroundColor: _AppColors.dark,
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Mở Khoá',
                          style: TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 14)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom Sheet thêm món ──────────────────────────────────────────────────
  void _showAddRecipeBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (bottomSheetContext) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: const BoxDecoration(
            color: _AppColors.cardBg,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 12),
                width: 40, height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Row(
                  children: [
                    const Text(
                      'Chọn món để thêm',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _AppColors.dark,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.pop(bottomSheetContext),
                      icon: const Icon(Icons.close_rounded,
                          color: _AppColors.muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 4),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(bottomSheetContext);
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RecipeFormView()));
                  },
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [_AppColors.red, _AppColors.redLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add_circle_rounded,
                            color: Colors.white, size: 28),
                        SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Tạo công thức mới',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 15)),
                            SizedBox(height: 2),
                            Text('Thêm món hoàn toàn mới vào sổ tay',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                        Spacer(),
                        Icon(Icons.arrow_forward_ios_rounded,
                            color: Colors.white70, size: 16),
                      ],
                    ),
                  ),
                ),
              ),
              Divider(
                  color: Colors.grey.shade200, thickness: 1, height: 16),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text('Từ sổ tay của bạn',
                      style: TextStyle(
                          fontSize: 12,
                          color: _AppColors.muted,
                          fontWeight: FontWeight.w600,
                          letterSpacing: .4)),
                ),
              ),
              Expanded(
                child: Consumer<RecipeViewModel>(
                  builder: (context, recipeViewModel, _) {
                    final allRecipes = recipeViewModel.recipes;
                    if (allRecipes.isEmpty) {
                      return Center(
                        child: Text('Chưa có công thức nào.',
                            style:
                            TextStyle(color: _AppColors.muted)),
                      );
                    }
                    return ListView.separated(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      itemCount: allRecipes.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: Colors.grey.shade100, height: 1),
                      itemBuilder: (context, index) {
                        final recipe = allRecipes[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 4, vertical: 4),
                          leading: Container(
                            width: 42, height: 42,
                            decoration: BoxDecoration(
                              color: recipe.isFamilySecret
                                  ? _AppColors.gold.withOpacity(.12)
                                  : _AppColors.cream,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: recipe.isFamilySecret
                                    ? _AppColors.gold.withOpacity(.3)
                                    : Colors.grey.shade200,
                              ),
                            ),
                            child: Icon(
                              recipe.isFamilySecret
                                  ? Icons.lock_rounded
                                  : Icons.restaurant_menu_rounded,
                              color: recipe.isFamilySecret
                                  ? _AppColors.gold
                                  : _AppColors.muted,
                              size: 20,
                            ),
                          ),
                          title: Text(recipe.name,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: _AppColors.dark)),
                          subtitle: recipe.isFamilySecret
                              ? Text('Bí kíp gia truyền',
                              style: TextStyle(
                                  fontSize: 11,
                                  color: _AppColors.gold,
                                  fontWeight: FontWeight.w600))
                              : null,
                          trailing: Container(
                            width: 32, height: 32,
                            decoration: BoxDecoration(
                              color: const Color(0xFFE8F5E9),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.add_rounded,
                                color: Color(0xFF2E7D32), size: 20),
                          ),
                          onTap: () {
                            context
                                .read<FeastViewModel>()
                                .addRecipeToFeast(
                                widget.feast.id!, recipe.id!);
                            Navigator.pop(bottomSheetContext);
                          },
                        );
                      },
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
}

// ─── Active Chip ──────────────────────────────────────────────────────────────
class _ActiveChip extends StatelessWidget {
  final String label;
  final Color color;
  const _ActiveChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(.25)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, color: color, fontWeight: FontWeight.w600)),
    );
  }
}

// ─── Meta Pill ────────────────────────────────────────────────────────────────
class _MetaPill extends StatelessWidget {
  final IconData icon;
  final String label;
  const _MetaPill({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white.withOpacity(.85)),
          const SizedBox(width: 5),
          Text(label,
              style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ─── Recipe Card ──────────────────────────────────────────────────────────────
class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onRemove;
  const _RecipeCard(
      {required this.recipe,
        required this.index,
        required this.onTap,
        required this.onRemove});

  static const _emojis = ['🍲', '🥩', '🥗', '🍜', '🥘', '🍱', '🥮', '🍢'];

  @override
  Widget build(BuildContext context) {
    final isSecret = recipe.isFamilySecret;
    final emoji    = _emojis[index % _emojis.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color:
            isSecret ? const Color(0xFFFFFBF0) : _AppColors.cardBg,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSecret
                  ? _AppColors.gold.withOpacity(.25)
                  : _AppColors.red.withOpacity(.07),
            ),
            boxShadow: [
              BoxShadow(
                color: isSecret
                    ? _AppColors.gold.withOpacity(.08)
                    : _AppColors.red.withOpacity(.07),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(
                  color: isSecret
                      ? _AppColors.gold.withOpacity(.12)
                      : _AppColors.red.withOpacity(.09),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: isSecret
                      ? const Icon(Icons.lock_rounded,
                      color: _AppColors.gold, size: 24)
                      : Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: _AppColors.dark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (isSecret) ...[
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: _AppColors.gold.withOpacity(.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          '🔑 Bí kíp gia truyền',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: _AppColors.gold,
                            letterSpacing: .3,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: onRemove,
                child: Container(
                  width: 32, height: 32,
                  decoration: BoxDecoration(
                    color: _AppColors.red.withOpacity(.08),
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: const Icon(Icons.remove_circle_outline_rounded,
                      color: _AppColors.red, size: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Empty States ─────────────────────────────────────────────────────────────
class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🥢', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('Mâm cỗ chưa có món',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _AppColors.dark,
                )),
            const SizedBox(height: 8),
            Text(
              'Nhấn nút bên dưới để thêm những món ăn\nngày Tết vào mâm cỗ của bạn.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 13, color: _AppColors.muted, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}

class _SearchEmptyState extends StatelessWidget {
  final String query;
  const _SearchEmptyState({required this.query});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🔍', style: TextStyle(fontSize: 56)),
            const SizedBox(height: 16),
            const Text('Không tìm thấy kết quả',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: _AppColors.dark,
                )),
            const SizedBox(height: 8),
            Text('Không có món nào tên\n"$query"',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: _AppColors.muted, height: 1.6)),
          ],
        ),
      ),
    );
  }
}

// ─── FAB ──────────────────────────────────────────────────────────────────────
class _AddRecipeFab extends StatelessWidget {
  final VoidCallback onTap;
  const _AddRecipeFab({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 56,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [_AppColors.redDark, _AppColors.red],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: _AppColors.red.withOpacity(.4),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: 8, right: 16,
                child: Container(
                  width: 8, height: 8,
                  decoration: const BoxDecoration(
                    color: _AppColors.goldLight,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              const Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.add_circle_rounded,
                        color: Colors.white, size: 22),
                    SizedBox(width: 10),
                    Text('Thêm món vào mâm',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
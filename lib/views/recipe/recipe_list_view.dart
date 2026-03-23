import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/recipe.dart';
import '../../viewmodels/recipe_viewmodel.dart';
import 'recipe_detail_view.dart';
import 'recipe_form_view.dart';

// ─── Bảng màu Tết ─────────────────────────────────────────────────────────────
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

// ─── Enum sắp xếp ─────────────────────────────────────────────────────────────
enum _SortMode { nameAsc, nameDesc, secretFirst, normalFirst }

// ─── RecipeListView — StatefulWidget để quản lý UI state ─────────────────────
class RecipeListView extends StatefulWidget {
  const RecipeListView({super.key});

  @override
  State<RecipeListView> createState() => _RecipeListViewState();
}

class _RecipeListViewState extends State<RecipeListView> {
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

  // ── Lọc + sắp xếp ────────────────────────────────────────────────────────────
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
      case _SortMode.nameAsc:      return 'Tên A→Z';
      case _SortMode.nameDesc:     return 'Tên Z→A';
      case _SortMode.secretFirst:  return 'Bí kíp trước';
      case _SortMode.normalFirst:  return 'Thường trước';
    }
  }

  // ── Menu 3 chấm ───────────────────────────────────────────────────────────────
  void _showOptionsMenu(BuildContext context) {
    final RenderBox button  = context.findRenderObject() as RenderBox;
    final RenderBox overlay =
    Navigator.of(context).overlay!.context.findRenderObject() as RenderBox;
    final RelativeRect position = RelativeRect.fromRect(
      Rect.fromPoints(
        button.localToGlobal(Offset.zero, ancestor: overlay),
        button.localToGlobal(button.size.bottomRight(Offset.zero),
            ancestor: overlay),
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
        _sortItem('name_asc',      Icons.sort_by_alpha_rounded, 'Tên A → Z',       _sortMode == _SortMode.nameAsc),
        _sortItem('name_desc',     Icons.sort_by_alpha_rounded, 'Tên Z → A',       _sortMode == _SortMode.nameDesc),
        _sortItem('secret_first',  Icons.lock_rounded,          'Bí kíp trước',    _sortMode == _SortMode.secretFirst),
        _sortItem('normal_first',  Icons.menu_book_rounded,     'Thường trước',    _sortMode == _SortMode.normalFirst),
        _menuDivider(),
        _menuHeader('HIỂN THỊ'),
        _toggleItem('filter_secret', Icons.lock_rounded,
            'Chỉ bí kíp gia truyền', _filterSecretOnly, _AppColors.gold),
      ],
    ).then((value) {
      if (value == null) return;
      setState(() {
        switch (value) {
          case 'name_asc':       _sortMode = _SortMode.nameAsc; break;
          case 'name_desc':      _sortMode = _SortMode.nameDesc; break;
          case 'secret_first':   _sortMode = _SortMode.secretFirst; break;
          case 'normal_first':   _sortMode = _SortMode.normalFirst; break;
          case 'filter_secret':  _filterSecretOnly = !_filterSecretOnly; break;
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
    final viewModel = context.watch<RecipeViewModel>();
    final recipes   = _processedRecipes(viewModel.recipes);

    return Scaffold(
      backgroundColor: _AppColors.cream,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: _AppColors.red,
            automaticallyImplyLeading: false,
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
                  icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                  onPressed: () => _showOptionsMenu(btnCtx),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_AppColors.redDark, _AppColors.red],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                  ),
                  // Vòng trang trí
                  Positioned(
                    top: -50, right: -30,
                    child: Container(
                      width: 200, height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _AppColors.gold.withOpacity(.25), width: 2),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 20, right: 50,
                    child: Container(
                      width: 90, height: 90,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: _AppColors.gold.withOpacity(.15), width: 1.5),
                      ),
                    ),
                  ),
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
                              Text('📖 ', style: TextStyle(fontSize: 11)),
                              Text('SỔ TAY BÍ KÍP',
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
                        const Text(
                          'Công Thức\nNấu Ăn',
                          style: TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        _MetaPill(
                          icon: Icons.menu_book_rounded,
                          label: viewModel.isLoading
                              ? 'Đang tải...'
                              : '${recipes.length} công thức',
                        ),
                      ],
                    ),
                  ),

                  // ── SearchBar trượt xuống ──────────────────────────────
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
                            hintText: 'Tìm tên công thức...',
                            hintStyle: TextStyle(
                                color: _AppColors.muted.withOpacity(.5),
                                fontSize: 14),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: _AppColors.red, size: 20),
                            suffixIcon: _searchQuery.isNotEmpty
                                ? IconButton(
                              icon: const Icon(Icons.close_rounded,
                                  size: 18, color: _AppColors.muted),
                              onPressed: () => setState(() {
                                _searchController.clear();
                                _searchQuery = '';
                              }),
                            )
                                : null,
                            border: InputBorder.none,
                            contentPadding:
                            const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Wave divider ──────────────────────────────────────────────────
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
                      borderRadius:
                      BorderRadius.vertical(top: Radius.circular(28)),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Category Dropdown ──────────────────────────────────────────
          if (!viewModel.isLoading && viewModel.categories.length > 1)
            SliverToBoxAdapter(
              child: _CategoryDropdown(viewModel: viewModel),
            ),

          // ── Section header + active filter chips ──────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
              child: Row(
                children: [
                  const Text(
                    'Danh sách',
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
                    _ActiveChip(label: _sortLabel, color: _AppColors.red),
                  // Chip filter bí kíp
                  if (_filterSecretOnly)
                    _ActiveChip(label: '🔑 Bí kíp', color: _AppColors.gold),
                  const SizedBox(width: 4),
                  if (!viewModel.isLoading && recipes.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _AppColors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${recipes.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),
          ),

          // ── Nội dung chính ────────────────────────────────────────────────
          if (viewModel.isLoading)
            const SliverFillRemaining(
              child: Center(
                  child: CircularProgressIndicator(color: _AppColors.red)),
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
                        onDelete: () =>
                            _confirmDelete(context, viewModel, recipe),
                      ),
                    );
                  },
                  childCount: recipes.length,
                ),
              ),
            ),
        ],
      ),

      // ── FAB ────────────────────────────────────────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GestureDetector(
          onTap: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const RecipeFormView()),
            );
            if (context.mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Row(
                    children: [
                      Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 18),
                      SizedBox(width: 8),
                      Text('Công thức mới đã được lưu thành công!'),
                    ],
                  ),
                  backgroundColor: const Color(0xFF2E7D32),
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  duration: const Duration(seconds: 3),
                ),
              );
            }
          },
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
                      Text('Thêm công thức mới',
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
      ),
    );
  }

  // ── Confirm Delete ────────────────────────────────────────────────────────
  void _confirmDelete(
      BuildContext context, RecipeViewModel viewModel, Recipe recipe) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
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
                  color: _AppColors.red.withOpacity(.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.delete_outline_rounded,
                    color: _AppColors.red, size: 32),
              ),
              const SizedBox(height: 16),
              const Text('Xoá công thức?',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _AppColors.dark,
                  )),
              const SizedBox(height: 8),
              Text(
                'Công thức này sẽ bị xoá vĩnh viễn\nvà không thể khôi phục lại.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: _AppColors.muted, height: 1.5),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: const Text('Huỷ',
                          style: TextStyle(
                              color: _AppColors.muted,
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final recipeName = recipe.name;
                        viewModel.deleteRecipe(recipe.id!);
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.delete_rounded,
                                    color: Colors.white, size: 18),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Đã xoá công thức "$recipeName".',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: _AppColors.red,
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _AppColors.red,
                        foregroundColor: Colors.white,
                        padding:
                        const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 0,
                      ),
                      child: const Text('Xoá',
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

  // ── PIN Dialog ────────────────────────────────────────────────────────────
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
                'Nhập mã PIN để mở khoá công thức\nbí mật của gia đình.',
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
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 14,
                  color: _AppColors.dark,
                ),
                decoration: InputDecoration(
                  counterText: '',
                  hintText: '••••',
                  hintStyle: TextStyle(
                      color: _AppColors.muted.withOpacity(.35),
                      letterSpacing: 12,
                      fontSize: 24),
                  filled: true,
                  fillColor: _AppColors.cream,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                    BorderSide(color: _AppColors.gold.withOpacity(.3)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide:
                    BorderSide(color: _AppColors.gold.withOpacity(.3)),
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
                      child: const Text('Huỷ',
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
                                  RecipeDetailView(recipe: recipe),
                            ),
                          );
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

// ─── Category Dropdown ────────────────────────────────────────────────────────
class _CategoryDropdown extends StatelessWidget {
  final RecipeViewModel viewModel;
  const _CategoryDropdown({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        decoration: BoxDecoration(
          color: _AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: _AppColors.muted.withOpacity(.2)),
          boxShadow: [
            BoxShadow(
              color: _AppColors.dark.withOpacity(.04),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 32, height: 32,
              decoration: BoxDecoration(
                color: _AppColors.red.withOpacity(.09),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.filter_list_rounded,
                  color: _AppColors.red, size: 17),
            ),
            const SizedBox(width: 10),
            const Text('Phân loại:',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _AppColors.muted)),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: viewModel.selectedCategory,
                  icon: const Icon(Icons.keyboard_arrow_down_rounded,
                      color: _AppColors.red, size: 22),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: _AppColors.dark,
                    fontFamily: 'Be Vietnam Pro',
                  ),
                  dropdownColor: _AppColors.cardBg,
                  borderRadius: BorderRadius.circular(14),
                  items: viewModel.categories.map((String cat) {
                    final isActive = cat == viewModel.selectedCategory;
                    return DropdownMenuItem<String>(
                      value: cat,
                      child: Row(
                        children: [
                          if (isActive) ...[
                            Container(
                              width: 6, height: 6,
                              decoration: const BoxDecoration(
                                color: _AppColors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ] else
                            const SizedBox(width: 14),
                          Text(cat,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: isActive
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: isActive
                                    ? _AppColors.red
                                    : _AppColors.dark,
                              )),
                        ],
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      viewModel.setCategoryFilter(newValue);
                    }
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Recipe Card ──────────────────────────────────────────────────────────────
class _RecipeCard extends StatelessWidget {
  final Recipe recipe;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _RecipeCard({
    required this.recipe,
    required this.index,
    required this.onTap,
    required this.onDelete,
  });

  static const _emojis = ['🍲', '🥩', '🥗', '🍜', '🥘', '🍱', '🥮', '🍢'];

  @override
  Widget build(BuildContext context) {
    final isSecret = recipe.isFamilySecret;
    final emoji    = _emojis[index % _emojis.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: isSecret ? const Color(0xFFFFFBF0) : _AppColors.cardBg,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: isSecret
                  ? _AppColors.gold.withOpacity(.25)
                  : _AppColors.red.withOpacity(.07),
            ),
            boxShadow: [
              BoxShadow(
                color: isSecret
                    ? _AppColors.gold.withOpacity(.08)
                    : _AppColors.red.withOpacity(.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Icon / Emoji
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: isSecret
                      ? _AppColors.gold.withOpacity(.12)
                      : _AppColors.red.withOpacity(.08),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: isSecret
                      ? const Icon(Icons.lock_rounded,
                      color: _AppColors.gold, size: 26)
                      : Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),

              // Thông tin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(recipe.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: _AppColors.dark,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSecret
                                ? _AppColors.gold.withOpacity(.12)
                                : _AppColors.red.withOpacity(.07),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isSecret
                                ? '🔑 Bí kíp gia truyền'
                                : (recipe.category ?? 'Chưa phân loại'),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSecret
                                  ? _AppColors.gold
                                  : _AppColors.muted,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Actions
              Column(
                children: [
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 32, height: 32,
                      decoration: BoxDecoration(
                        color: _AppColors.red.withOpacity(.07),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: _AppColors.red, size: 17),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 13,
                      color: _AppColors.muted.withOpacity(.4)),
                ],
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
            const Text('📖', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('Chưa có công thức nào',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _AppColors.dark,
                )),
            const SizedBox(height: 8),
            Text(
              'Nhấn nút bên dưới để thêm công thức\nđầu tiên vào sổ tay của bạn.',
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
            Text('Không có công thức nào tên\n"$query"',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13, color: _AppColors.muted, height: 1.6)),
          ],
        ),
      ),
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
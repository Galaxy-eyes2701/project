import 'package:flutter/material.dart';
import 'package:project/views/shopping/shopping_detail_view.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/shopping_list.dart';
import '../../viewmodels/shopping_list_viewmodel.dart';

// ─── Bảng màu ─────────────────────────────────────────────────────────────────
class _AppColors {
  static const red       = Color(0xFFC0392B);
  static const gold      = Color(0xFFD4A017);
  static const green     = Color(0xFF27AE60);
  static const greenDark = Color(0xFF1E8449);
  static const greenBg   = Color(0xFFEAF7EE);
  static const cream     = Color(0xFFFDF6EC);
  static const dark      = Color(0xFF1A0A00);
  static const muted     = Color(0xFF7D5A3C);
  static const cardBg    = Color(0xFFFFFBF5);
}

// ─── Enum sắp xếp ─────────────────────────────────────────────────────────────
enum _SortMode { nameAsc, nameDesc, dateNew, dateOld }

// ─── ShoppingListView — StatefulWidget để quản lý UI state ───────────────────
class ShoppingListView extends StatefulWidget {
  const ShoppingListView({super.key});

  @override
  State<ShoppingListView> createState() => _ShoppingListViewState();
}

class _ShoppingListViewState extends State<ShoppingListView> {
  bool _isSearchOpen = false;
  _SortMode _sortMode = _SortMode.dateNew;

  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Lọc + sắp xếp ────────────────────────────────────────────────────────────
  List<ShoppingList> _processedLists(List<ShoppingList> lists) {
    var list = lists.where((s) {
      return _searchQuery.isEmpty ||
          s.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    switch (_sortMode) {
      case _SortMode.nameAsc:
        list.sort((a, b) => a.name.compareTo(b.name));
        break;
      case _SortMode.nameDesc:
        list.sort((a, b) => b.name.compareTo(a.name));
        break;
      case _SortMode.dateNew:
        list.sort((a, b) => (b.createdAt ?? DateTime(0))
            .compareTo(a.createdAt ?? DateTime(0)));
        break;
      case _SortMode.dateOld:
        list.sort((a, b) => (a.createdAt ?? DateTime(0))
            .compareTo(b.createdAt ?? DateTime(0)));
        break;
    }
    return list;
  }

  String get _sortLabel {
    switch (_sortMode) {
      case _SortMode.nameAsc:  return 'Tên A→Z';
      case _SortMode.nameDesc: return 'Tên Z→A';
      case _SortMode.dateNew:  return 'Mới nhất';
      case _SortMode.dateOld:  return 'Cũ nhất';
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
        _sortItem('name_asc',  Icons.sort_by_alpha_rounded, 'Tên A → Z', _sortMode == _SortMode.nameAsc),
        _sortItem('name_desc', Icons.sort_by_alpha_rounded, 'Tên Z → A', _sortMode == _SortMode.nameDesc),
        _sortItem('date_new',  Icons.schedule_rounded,      'Mới nhất',  _sortMode == _SortMode.dateNew),
        _sortItem('date_old',  Icons.history_rounded,        'Cũ nhất',   _sortMode == _SortMode.dateOld),
      ],
    ).then((value) {
      if (value == null) return;
      setState(() {
        switch (value) {
          case 'name_asc':  _sortMode = _SortMode.nameAsc; break;
          case 'name_desc': _sortMode = _SortMode.nameDesc; break;
          case 'date_new':  _sortMode = _SortMode.dateNew; break;
          case 'date_old':  _sortMode = _SortMode.dateOld; break;
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

  PopupMenuItem<String> _sortItem(
      String value, IconData icon, String label, bool isActive) {
    return PopupMenuItem<String>(
      value: value,
      height: 44,
      child: Row(
        children: [
          Icon(icon,
              size: 18,
              color: isActive ? _AppColors.green : _AppColors.muted),
          const SizedBox(width: 12),
          Text(label,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? _AppColors.green : _AppColors.dark)),
          if (isActive) ...[
            const Spacer(),
            const Icon(Icons.check_rounded, size: 16, color: _AppColors.green),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ShoppingListViewModel>();
    final lists     = _processedLists(viewModel.shoppingLists);

    return Scaffold(
      backgroundColor: _AppColors.cream,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: _AppColors.green,
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
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [_AppColors.greenDark, _AppColors.green],
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
                            color: Colors.white.withOpacity(.15), width: 2),
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
                            color: Colors.white.withOpacity(.1), width: 1.5),
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
                            color: Colors.white.withOpacity(.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.white.withOpacity(.35)),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text('🛒 ', style: TextStyle(fontSize: 11)),
                              Text('SỔ TAY ĐI CHỢ',
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: .8,
                                  )),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Danh Sách\nĐi Chợ',
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
                          icon: Icons.shopping_basket_rounded,
                          label: '${lists.length} danh sách',
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
                              color: _AppColors.greenDark.withOpacity(.2),
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
                            hintText: 'Tìm tên danh sách...',
                            hintStyle: TextStyle(
                                color: _AppColors.muted.withOpacity(.5),
                                fontSize: 14),
                            prefixIcon: const Icon(Icons.search_rounded,
                                color: _AppColors.green, size: 20),
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

          // ── Wave ──────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 28,
              child: Stack(
                children: [
                  Container(color: _AppColors.green, height: 14),
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

          // ── Section header + active chip ───────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  const Text(
                    'Danh sách của tôi',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _AppColors.dark,
                    ),
                  ),
                  const Spacer(),
                  // Chip sort (ẩn khi mặc định)
                  if (_sortMode != _SortMode.dateNew)
                    _ActiveChip(
                        label: _sortLabel, color: _AppColors.green),
                  const SizedBox(width: 4),
                  if (lists.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _AppColors.green,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${lists.length}',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700)),
                    ),
                ],
              ),
            ),
          ),

          // ── Body ───────────────────────────────────────────────────────
          if (lists.isEmpty)
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
                    final list = lists[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _ShoppingListCard(
                        shoppingList: list,
                        index: index,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                ShoppingDetailView(shoppingList: list),
                          ),
                        ),
                        onEdit: () =>
                            _showEditListBottomSheet(context, viewModel, list),
                        onDelete: () =>
                            _confirmDelete(context, viewModel, list),
                      ),
                    );
                  },
                  childCount: lists.length,
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
          onTap: () => _showAddListBottomSheet(context),
          child: Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [_AppColors.greenDark, _AppColors.green],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: _AppColors.green.withOpacity(.4),
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
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(.6),
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
                      Text('Tạo danh sách mới',
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

  // ── Confirm Delete ──────────────────────────────────────────────────────────
  void _confirmDelete(BuildContext context, ShoppingListViewModel viewModel,
      ShoppingList list) {
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
              const Text('Xoá danh sách?',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _AppColors.dark,
                  )),
              const SizedBox(height: 8),
              Text(
                'Danh sách này và tất cả các món\ntrong đó sẽ bị xoá vĩnh viễn.',
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
                      // MỚI
                      onPressed: () {
                        final listName = list.name;
                        viewModel.deleteShoppingList(list.id!);
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
                                    'Đã xóa danh sách "$listName".',
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

  // ── Add List Bottom Sheet ───────────────────────────────────────────────────
  void _showAddListBottomSheet(BuildContext context) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding:
        EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: _AppColors.cardBg,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _AppColors.green.withOpacity(.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.shopping_basket_rounded,
                        color: _AppColors.green, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text('Tạo danh sách mới',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _AppColors.dark,
                      )),
                ],
              ),
              const SizedBox(height: 24),
              const Row(
                children: [
                  Text('Tên danh sách',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _AppColors.dark)),
                  SizedBox(width: 3),
                  Text('*',
                      style: TextStyle(
                          color: _AppColors.red,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(
                    fontSize: 14, color: _AppColors.dark),
                decoration: InputDecoration(
                  hintText: 'VD: Đồ khô mùng 1, Rau củ Tết...',
                  hintStyle: TextStyle(
                      color: _AppColors.muted.withOpacity(.45),
                      fontSize: 14),
                  prefixIcon: const Icon(Icons.shopping_cart_outlined,
                      color: _AppColors.muted, size: 20),
                  filled: true,
                  fillColor: _AppColors.cream,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: _AppColors.muted.withOpacity(.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: _AppColors.muted.withOpacity(.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: _AppColors.green, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: const Text('Huỷ',
                          style: TextStyle(
                              color: _AppColors.muted,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: () {
                        if (controller.text.isNotEmpty) {
                          final name = controller.text.trim();
                          context.read<ShoppingListViewModel>().createShoppingList(
                            ShoppingList(name: name, createdAt: DateTime.now()),
                          );
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Row(
                                children: [
                                  const Icon(Icons.check_circle_rounded,
                                      color: Colors.white, size: 18),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'Đã tạo danh sách "$name"!',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              backgroundColor: _AppColors.green,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              duration: const Duration(seconds: 3),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _AppColors.green,
                        foregroundColor: Colors.white,
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 18),
                          SizedBox(width: 8),
                          Text('Tạo danh sách',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                        ],
                      ),
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

  // ── Edit List Bottom Sheet ─────────────────────────────────────────────────
  void _showEditListBottomSheet(BuildContext context,
      ShoppingListViewModel viewModel, ShoppingList list) {
    final controller = TextEditingController(text: list.name);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding:
        EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: _AppColors.cardBg,
            borderRadius:
            BorderRadius.vertical(top: Radius.circular(28)),
          ),
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Header
              Row(
                children: [
                  Container(
                    width: 44, height: 44,
                    decoration: BoxDecoration(
                      color: _AppColors.gold.withOpacity(.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: _AppColors.gold, size: 22),
                  ),
                  const SizedBox(width: 12),
                  const Text('Đổi tên danh sách',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _AppColors.dark,
                      )),
                ],
              ),
              const SizedBox(height: 20),

              // Tên hiện tại
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _AppColors.green.withOpacity(.07),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _AppColors.green.withOpacity(.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 14,
                        color: _AppColors.green.withOpacity(.8)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Đang sửa: ${list.name}',
                        style: TextStyle(
                            fontSize: 12,
                            color: _AppColors.green.withOpacity(.9),
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Label
              const Row(
                children: [
                  Text('Tên mới',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: _AppColors.dark)),
                  SizedBox(width: 3),
                  Text('*',
                      style: TextStyle(
                          color: _AppColors.red,
                          fontWeight: FontWeight.w700)),
                ],
              ),
              const SizedBox(height: 6),

              // Input (điền sẵn tên cũ)
              TextField(
                controller: controller,
                autofocus: true,
                style: const TextStyle(
                    fontSize: 14, color: _AppColors.dark),
                decoration: InputDecoration(
                  hintText: 'Nhập tên danh sách...',
                  hintStyle: TextStyle(
                      color: _AppColors.muted.withOpacity(.45),
                      fontSize: 14),
                  prefixIcon: const Icon(Icons.shopping_cart_outlined,
                      color: _AppColors.muted, size: 20),
                  filled: true,
                  fillColor: _AppColors.cream,
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: _AppColors.muted.withOpacity(.2)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: _AppColors.muted.withOpacity(.2)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(
                        color: _AppColors.green, width: 2),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: TextButton.styleFrom(
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                          side: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      child: const Text('Huỷ',
                          style: TextStyle(
                              color: _AppColors.muted,
                              fontWeight: FontWeight.w600,
                              fontSize: 15)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      // MỚI
                      onPressed: () async {
                        final newName = controller.text.trim();
                        if (newName.isNotEmpty && newName != list.name) {
                          await viewModel.updateShoppingList(
                            ShoppingList(
                              id:        list.id,
                              name:      newName,
                              createdAt: list.createdAt,
                            ),
                          );
                          if (ctx.mounted) Navigator.pop(ctx);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Row(
                                  children: [
                                    const Icon(Icons.check_circle_rounded,
                                        color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Đã đổi tên thành "$newName"!',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                                backgroundColor: _AppColors.green,
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        } else {
                          if (ctx.mounted) Navigator.pop(ctx);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _AppColors.green,
                        foregroundColor: Colors.white,
                        padding:
                        const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        elevation: 0,
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.check_circle_outline_rounded,
                              size: 18),
                          SizedBox(width: 8),
                          Text('Lưu thay đổi',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15)),
                        ],
                      ),
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

// ─── Shopping List Card ───────────────────────────────────────────────────────
class _ShoppingListCard extends StatelessWidget {
  final ShoppingList shoppingList;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ShoppingListCard({
    required this.shoppingList,
    required this.index,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  static const _emojis = ['🛒', '🥬', '🍖', '🥚', '🧅', '🌿', '🐟', '🍋'];

  @override
  Widget build(BuildContext context) {
    final emoji = _emojis[index % _emojis.length];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _AppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _AppColors.green.withOpacity(.08)),
            boxShadow: [
              BoxShadow(
                color: _AppColors.green.withOpacity(.07),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 52, height: 52,
                decoration: BoxDecoration(
                  color: _AppColors.green.withOpacity(.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(emoji,
                      style: const TextStyle(fontSize: 26)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shoppingList.name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: _AppColors.dark,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 11,
                            color: _AppColors.muted.withOpacity(.6)),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(shoppingList.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: _AppColors.muted.withOpacity(.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: onEdit,
                        child: Container(
                          width: 32, height: 32,
                          decoration: BoxDecoration(
                            color: _AppColors.gold.withOpacity(.1),
                            borderRadius: BorderRadius.circular(50),
                          ),
                          child: const Icon(Icons.edit_rounded,
                              color: _AppColors.gold, size: 16),
                        ),
                      ),
                      const SizedBox(width: 8),
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
                    ],
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

  String _formatDate(DateTime? date) {
    if (date == null) return '';
    return '${date.day}/${date.month}/${date.year}';
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
            const Text('🛒', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('Chưa có danh sách nào',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _AppColors.dark,
                )),
            const SizedBox(height: 8),
            Text(
              'Tạo danh sách đầu tiên để bắt đầu\nlên kế hoạch đi chợ ngày Tết.',
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
            Text('Không có danh sách nào tên\n"$query"',
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
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: Colors.white.withOpacity(.9)),
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
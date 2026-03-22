import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/shopping_list.dart';
import '../../domain/entities/shopping_item.dart';
import '../../viewmodels/shopping_list_viewmodel.dart';

// ─── Bảng màu Tết ─────────────────────────────────────────────────────────────
class _AppColors {
  static const red       = Color(0xFFC0392B);
  static const redDark   = Color(0xFF96231B);
  static const gold      = Color(0xFFD4A017);
  static const goldLight = Color(0xFFF0C040);
  static const green     = Color(0xFF27AE60);
  static const greenDark = Color(0xFF1E8449);
  static const greenBg   = Color(0xFFEAF7EE);
  static const cream     = Color(0xFFFDF6EC);
  static const dark      = Color(0xFF1A0A00);
  static const muted     = Color(0xFF7D5A3C);
  static const cardBg    = Color(0xFFFFFBF5);
}

// ─── Enum sắp xếp ─────────────────────────────────────────────────────────────
enum _SortMode { nameAsc, nameDesc, uncheckedFirst, checkedFirst }

// ─── ShoppingDetailView ───────────────────────────────────────────────────────
class ShoppingDetailView extends StatefulWidget {
  final ShoppingList shoppingList;
  const ShoppingDetailView({super.key, required this.shoppingList});

  @override
  State<ShoppingDetailView> createState() => _ShoppingDetailViewState();
}

class _ShoppingDetailViewState extends State<ShoppingDetailView> {
  late Future<List<ShoppingItem>> _itemsFuture;

  // ── Search + Sort state ───────────────────────────────────────────────────
  bool _isSearchOpen = false;
  _SortMode _sortMode = _SortMode.uncheckedFirst;
  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadItems() {
    _itemsFuture = context
        .read<ShoppingListViewModel>()
        .loadItems(widget.shoppingList.id!);
  }

  void _refresh() => setState(() => _loadItems());

  // ── Lọc + sắp xếp trên list đã load ─────────────────
  List<ShoppingItem> _processedItems(List<ShoppingItem> items) {
    var list = items.where((i) {
      return _searchQuery.isEmpty ||
          i.ingredientName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();

    switch (_sortMode) {
      case _SortMode.nameAsc:
        list.sort((a, b) => a.ingredientName.compareTo(b.ingredientName));
        break;
      case _SortMode.nameDesc:
        list.sort((a, b) => b.ingredientName.compareTo(a.ingredientName));
        break;
      case _SortMode.uncheckedFirst:
        list.sort((a, b) {
          if (a.isChecked == b.isChecked) return 0;
          return a.isChecked ? 1 : -1;
        });
        break;
      case _SortMode.checkedFirst:
        list.sort((a, b) {
          if (a.isChecked == b.isChecked) return 0;
          return a.isChecked ? -1 : 1;
        });
        break;
    }
    return list;
  }

  String get _sortLabel {
    switch (_sortMode) {
      case _SortMode.nameAsc:       return 'Tên A→Z';
      case _SortMode.nameDesc:      return 'Tên Z→A';
      case _SortMode.uncheckedFirst: return 'Chưa mua trước';
      case _SortMode.checkedFirst:  return 'Đã mua trước';
    }
  }

  // ── Menu 3 chấm ───────────────────────────────────────────────────────────
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
        _sortItem('name_asc',        Icons.sort_by_alpha_rounded, 'Tên A → Z',        _sortMode == _SortMode.nameAsc),
        _sortItem('name_desc',       Icons.sort_by_alpha_rounded, 'Tên Z → A',        _sortMode == _SortMode.nameDesc),
        _sortItem('unchecked_first', Icons.radio_button_unchecked, 'Chưa mua trước', _sortMode == _SortMode.uncheckedFirst),
        _sortItem('checked_first',   Icons.check_circle_rounded,  'Đã mua trước',    _sortMode == _SortMode.checkedFirst),
      ],
    ).then((value) {
      if (value == null) return;
      setState(() {
        switch (value) {
          case 'name_asc':        _sortMode = _SortMode.nameAsc; break;
          case 'name_desc':       _sortMode = _SortMode.nameDesc; break;
          case 'unchecked_first': _sortMode = _SortMode.uncheckedFirst; break;
          case 'checked_first':   _sortMode = _SortMode.checkedFirst; break;
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
            const Icon(Icons.check_rounded,
                size: 16, color: _AppColors.green),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<ShoppingListViewModel>();

    return Scaffold(
      backgroundColor: _AppColors.cream,
      body: FutureBuilder<List<ShoppingItem>>(
        future: _itemsFuture,
        builder: (context, snapshot) {
          final isLoading  = snapshot.connectionState == ConnectionState.waiting;
          final allItems   = snapshot.data ?? [];
          final items      = _processedItems(allItems);
          final checked    = allItems.where((i) => i.isChecked).length;
          final total      = allItems.length;

          return CustomScrollView(
            slivers: [
              // ── AppBar ──────────────────────────────────────────────────
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                stretch: true,
                backgroundColor: _AppColors.green,
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
                                color: Colors.white.withOpacity(.15),
                                width: 2),
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
                                color: Colors.white.withOpacity(.1),
                                width: 1.5),
                          ),
                        ),
                      ),
                      // Nội dung chữ
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
                                  Text('🛒 ',
                                      style: TextStyle(fontSize: 11)),
                                  Text('DANH SÁCH ĐI CHỢ',
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
                            Text(
                              widget.shoppingList.name,
                              style: const TextStyle(
                                fontFamily: 'Playfair Display',
                                fontSize: 26,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.15,
                              ),
                            ),
                            const SizedBox(height: 10),
                            if (!isLoading && total > 0)
                              _ProgressPill(
                                  checked: checked, total: total),
                          ],
                        ),
                      ),

                      // ── SearchBar trượt xuống ─────────────────────────
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
                                  color:
                                  _AppColors.greenDark.withOpacity(.2),
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
                                hintText: 'Tìm tên đồ cần mua...',
                                hintStyle: TextStyle(
                                    color:
                                    _AppColors.muted.withOpacity(.5),
                                    fontSize: 14),
                                prefixIcon: const Icon(
                                    Icons.search_rounded,
                                    color: _AppColors.green,
                                    size: 20),
                                suffixIcon: _searchQuery.isNotEmpty
                                    ? IconButton(
                                  icon: const Icon(
                                      Icons.close_rounded,
                                      size: 18,
                                      color: _AppColors.muted),
                                  onPressed: () => setState(() {
                                    _searchController.clear();
                                    _searchQuery = '';
                                  }),
                                )
                                    : null,
                                border: InputBorder.none,
                                contentPadding:
                                const EdgeInsets.symmetric(
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

              // ── Wave ────────────────────────────────────────────────────
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
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(28)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── Progress bar ─────────────────────────────────────────────
              if (!isLoading && total > 0)
                SliverToBoxAdapter(
                  child: _ProgressBar(checked: checked, total: total),
                ),

              // ── Section header + active chip ─────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: Row(
                    children: [
                      const Text(
                        'Cần mua',
                        style: TextStyle(
                          fontFamily: 'Playfair Display',
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: _AppColors.dark,
                        ),
                      ),
                      const Spacer(),
                      // Chip sort (ẩn khi mặc định)
                      if (_sortMode != _SortMode.uncheckedFirst)
                        _ActiveChip(
                            label: _sortLabel, color: _AppColors.green),
                      const SizedBox(width: 4),
                      if (!isLoading && total > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: _AppColors.green,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '$checked/$total',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              // ── Nội dung ─────────────────────────────────────────────────
              if (isLoading)
                const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                        color: _AppColors.green),
                  ),
                )
              else if (items.isEmpty)
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
                        final item = items[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: _ShoppingItemCard(
                            item: item,
                            onToggle: (value) async {
                              await viewModel.toggleItemCheck(
                                  item.id!, value);
                              _refresh();
                            },
                            onEdit: () => _showEditItemDialog(
                                context, viewModel, item),
                            onDelete: () async {
                              await viewModel.deleteItem(item.id!);
                              _refresh();
                            },
                          ),
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),

      // ── FAB ─────────────────────────────────────────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: GestureDetector(
          onTap: () => _showAddItemDialog(
              context, context.read<ShoppingListViewModel>()),
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
                      Text('Thêm đồ cần mua',
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

  // ── Add Item Bottom Sheet ──────────────────────────────────────────────────
  void _showAddItemDialog(
      BuildContext context, ShoppingListViewModel viewModel) {
    final nameController = TextEditingController();
    final qtyController  = TextEditingController();
    final unitController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
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
                  const Text('Thêm đồ cần mua',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: _AppColors.dark,
                      )),
                ],
              ),
              const SizedBox(height: 24),
              _InputLabel(label: 'Tên món đồ', required: true),
              const SizedBox(height: 6),
              _StyledTextField(
                controller: nameController,
                hint: 'VD: Thịt lợn, Hành lá...',
                icon: Icons.shopping_cart_outlined,
                accentColor: _AppColors.green,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InputLabel(label: 'Số lượng', required: false),
                        const SizedBox(height: 6),
                        _StyledTextField(
                          controller: qtyController,
                          hint: 'VD: 2',
                          icon: Icons.numbers_rounded,
                          keyboardType: TextInputType.number,
                          accentColor: _AppColors.green,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InputLabel(label: 'Đơn vị', required: false),
                        const SizedBox(height: 6),
                        _StyledTextField(
                          controller: unitController,
                          hint: 'VD: kg, bó...',
                          icon: Icons.straighten_rounded,
                          accentColor: _AppColors.green,
                        ),
                      ],
                    ),
                  ),
                ],
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
                      onPressed: () async {
                        if (nameController.text.isNotEmpty) {
                          final newItem = ShoppingItem(
                            shoppingListId: widget.shoppingList.id,
                            ingredientName: nameController.text.trim(),
                            quantity:
                            double.tryParse(qtyController.text),
                            unit: unitController.text.trim(),
                          );
                          await viewModel.addItem(newItem);
                          _refresh();
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
                          Icon(Icons.add_rounded, size: 18),
                          SizedBox(width: 6),
                          Text('Thêm vào giỏ',
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

  // ── Edit Item Bottom Sheet ─────────────────────────────────────────────────
  void _showEditItemDialog(
      BuildContext context, ShoppingListViewModel viewModel, ShoppingItem item) {
    final nameController = TextEditingController(text: item.ingredientName);
    final qtyController  = TextEditingController(
        text: item.quantity != null
            ? item.quantity!.toStringAsFixed(
            item.quantity! % 1 == 0 ? 0 : 1)
            : '');
    final unitController = TextEditingController(text: item.unit ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom),
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
              // Handle bar
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
                  const Text('Sửa món đồ',
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
                    Text(
                      'Đang sửa: ${item.ingredientName}',
                      style: TextStyle(
                          fontSize: 12,
                          color: _AppColors.green.withOpacity(.9),
                          fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tên món
              _InputLabel(label: 'Tên món đồ', required: true),
              const SizedBox(height: 6),
              _StyledTextField(
                controller: nameController,
                hint: 'VD: Thịt lợn, Hành lá...',
                icon: Icons.shopping_cart_outlined,
                accentColor: _AppColors.green,
              ),
              const SizedBox(height: 16),

              // Số lượng + Đơn vị
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InputLabel(label: 'Số lượng', required: false),
                        const SizedBox(height: 6),
                        _StyledTextField(
                          controller: qtyController,
                          hint: 'VD: 2',
                          icon: Icons.numbers_rounded,
                          keyboardType: TextInputType.number,
                          accentColor: _AppColors.green,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InputLabel(label: 'Đơn vị', required: false),
                        const SizedBox(height: 6),
                        _StyledTextField(
                          controller: unitController,
                          hint: 'VD: kg, bó...',
                          icon: Icons.straighten_rounded,
                          accentColor: _AppColors.green,
                        ),
                      ],
                    ),
                  ),
                ],
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
                      onPressed: () async {
                        if (nameController.text.isNotEmpty) {
                          final updated = ShoppingItem(
                            id:             item.id,
                            shoppingListId: item.shoppingListId,
                            ingredientName: nameController.text.trim(),
                            quantity: double.tryParse(qtyController.text),
                            unit:     unitController.text.trim(),
                            isChecked: item.isChecked,
                          );
                          await viewModel.updateItem(updated);
                          _refresh();
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

// ─── Progress Pill (trong AppBar) ─────────────────────────────────────────────
class _ProgressPill extends StatelessWidget {
  final int checked;
  final int total;
  const _ProgressPill({required this.checked, required this.total});

  @override
  Widget build(BuildContext context) {
    final isDone = checked == total;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDone
                ? Icons.check_circle_rounded
                : Icons.shopping_basket_rounded,
            size: 13,
            color: Colors.white.withOpacity(.9),
          ),
          const SizedBox(width: 5),
          Text(
            isDone ? 'Đã mua hết rồi! 🎉' : 'Đã mua $checked/$total món',
            style: const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

// ─── Progress Bar ─────────────────────────────────────────────────────────────
class _ProgressBar extends StatelessWidget {
  final int checked;
  final int total;
  const _ProgressBar({required this.checked, required this.total});

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0.0 : checked / total;
    final isDone  = checked == total;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _AppColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _AppColors.green.withOpacity(.12)),
          boxShadow: [
            BoxShadow(
              color: _AppColors.green.withOpacity(.07),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  isDone ? '✅ Đã mua đủ hết rồi!' : 'Tiến độ mua sắm',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isDone ? _AppColors.green : _AppColors.dark,
                  ),
                ),
                const Spacer(),
                Text(
                  '${(percent * 100).toInt()}%',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDone ? _AppColors.green : _AppColors.muted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: percent,
                minHeight: 8,
                backgroundColor: _AppColors.green.withOpacity(.1),
                color: _AppColors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Shopping Item Card ───────────────────────────────────────────────────────
class _ShoppingItemCard extends StatelessWidget {
  final ShoppingItem item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _ShoppingItemCard({
    required this.item,
    required this.onToggle,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isChecked = item.isChecked;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      decoration: BoxDecoration(
        color: isChecked ? _AppColors.greenBg : _AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isChecked
              ? _AppColors.green.withOpacity(.2)
              : _AppColors.muted.withOpacity(.1),
        ),
        boxShadow: isChecked
            ? []
            : [
          BoxShadow(
            color: _AppColors.dark.withOpacity(.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onToggle(!isChecked),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 14, vertical: 12),
            child: Row(
              children: [
                // Checkbox tuỳ chỉnh
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24, height: 24,
                  decoration: BoxDecoration(
                    color: isChecked
                        ? _AppColors.green
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(7),
                    border: Border.all(
                      color: isChecked
                          ? _AppColors.green
                          : _AppColors.muted.withOpacity(.4),
                      width: 2,
                    ),
                  ),
                  child: isChecked
                      ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 15)
                      : null,
                ),
                const SizedBox(width: 14),

                // Thông tin
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 200),
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isChecked
                              ? _AppColors.muted.withOpacity(.6)
                              : _AppColors.dark,
                          decoration: isChecked
                              ? TextDecoration.lineThrough
                              : TextDecoration.none,
                          decorationColor: _AppColors.muted,
                        ),
                        child: Text(item.ingredientName),
                      ),
                      if (item.quantity != null ||
                          (item.unit != null &&
                              item.unit!.isNotEmpty)) ...[
                        const SizedBox(height: 3),
                        Text(
                          [
                            if (item.quantity != null)
                              item.quantity!.toStringAsFixed(
                                  item.quantity! % 1 == 0 ? 0 : 1),
                            if (item.unit != null &&
                                item.unit!.isNotEmpty)
                              item.unit!,
                          ].join(' '),
                          style: TextStyle(
                            fontSize: 12,
                            color: isChecked
                                ? _AppColors.muted.withOpacity(.5)
                                : _AppColors.muted,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Nút sửa + xoá
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
                          color: Colors.red.withOpacity(.07),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: Icon(Icons.delete_outline_rounded,
                            color: Colors.red.shade300, size: 17),
                      ),
                    ),
                  ],
                ),
              ],
            ),
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
            const Text('🛒', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('Danh sách trống',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _AppColors.dark,
                )),
            const SizedBox(height: 8),
            Text(
              'Nhấn nút bên dưới để thêm\nnhững món đồ cần mua.',
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

// ─── Shared Widgets ───────────────────────────────────────────────────────────
class _InputLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _InputLabel({required this.label, required this.required});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: _AppColors.dark)),
        if (required) ...[
          const SizedBox(width: 3),
          const Text('*',
              style: TextStyle(
                  color: _AppColors.red, fontWeight: FontWeight.w700)),
        ],
      ],
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final Color accentColor;
  final TextInputType keyboardType;
  final int maxLines;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    required this.accentColor,
    this.keyboardType = TextInputType.text,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: _AppColors.dark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: _AppColors.muted.withOpacity(.45), fontSize: 14),
        prefixIcon: Icon(icon, color: _AppColors.muted, size: 20),
        filled: true,
        fillColor: _AppColors.cream,
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          BorderSide(color: _AppColors.muted.withOpacity(.2)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
          BorderSide(color: _AppColors.muted.withOpacity(.2)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: accentColor, width: 2),
        ),
      ),
    );
  }
}
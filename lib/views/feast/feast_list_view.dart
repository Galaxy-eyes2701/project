import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/feast.dart';
import '../../viewmodels/feast_viewmodel.dart';
import 'feast_detail_view.dart';

// ─── Bảng màu Tết ─────────────────────────────────────────────────────────────
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

// ─── Enum sắp xếp ─────────────────────────────────────────────────────────────
enum _SortMode { nameAsc, nameDesc, dateNew, dateOld }

class FeastListView extends StatefulWidget {
  const FeastListView({super.key});

  @override
  State<FeastListView> createState() => _FeastListViewState();
}

class _FeastListViewState extends State<FeastListView> {
  bool _isSearchOpen  = false;
  bool _filterSecret  = false;
  bool _isGridMode    = false;
  _SortMode _sortMode = _SortMode.dateNew;

  final _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ── Lọc + sắp xếp ────────────────────────────────────────────────────────────
  List<Feast> _processedFeasts(List<Feast> feasts) {
    var list = feasts.where((f) {
      return _searchQuery.isEmpty ||
          f.name.toLowerCase().contains(_searchQuery.toLowerCase());
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
        _sortItem('name_asc',  Icons.sort_by_alpha_rounded, 'Tên A → Z',  _sortMode == _SortMode.nameAsc),
        _sortItem('name_desc', Icons.sort_by_alpha_rounded, 'Tên Z → A',  _sortMode == _SortMode.nameDesc),
        _sortItem('date_new',  Icons.schedule_rounded,      'Mới nhất',   _sortMode == _SortMode.dateNew),
        _sortItem('date_old',  Icons.history_rounded,       'Cũ nhất',    _sortMode == _SortMode.dateOld),
        _menuDivider(),
        _menuHeader('HIỂN THỊ'),
        _toggleItem('filter_secret', Icons.lock_rounded,
            'Chỉ bí kíp gia truyền', _filterSecret, _AppColors.gold),
        _toggleItem('grid_mode',
            _isGridMode ? Icons.view_list_rounded : Icons.grid_view_rounded,
            _isGridMode ? 'Dạng danh sách' : 'Dạng lưới',
            _isGridMode, _AppColors.red),
      ],
    ).then((value) {
      if (value == null) return;
      setState(() {
        switch (value) {
          case 'name_asc':      _sortMode = _SortMode.nameAsc; break;
          case 'name_desc':     _sortMode = _SortMode.nameDesc; break;
          case 'date_new':      _sortMode = _SortMode.dateNew; break;
          case 'date_old':      _sortMode = _SortMode.dateOld; break;
          case 'filter_secret': _filterSecret = !_filterSecret; break;
          case 'grid_mode':     _isGridMode = !_isGridMode; break;
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
    final viewModel = context.watch<FeastViewModel>();
    final feasts    = _processedFeasts(viewModel.feasts);

    return Scaffold(
      backgroundColor: _AppColors.cream,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ────────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: _AppColors.red,
            automaticallyImplyLeading: false,
            actions: [
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
                              Text('🎊 ', style: TextStyle(fontSize: 11)),
                              Text('SỔ TAY NẤU ĂN',
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
                          'Mâm Cỗ\nNgày Tết',
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
                          icon: Icons.table_bar_rounded,
                          label: viewModel.isLoading
                              ? 'Đang tải...'
                              : '${feasts.length} mâm cỗ',
                        ),
                      ],
                    ),
                  ),

                  // ── SearchBar trượt xuống ────────────────────────────────
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
                          onChanged: (v) => setState(() => _searchQuery = v),
                          style: const TextStyle(
                              fontSize: 14, color: _AppColors.dark),
                          decoration: InputDecoration(
                            hintText: 'Tìm tên mâm cỗ...',
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

          // ── Section header + active chips ─────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
              child: Row(
                children: [
                  const Text(
                    'Danh sách mâm cỗ',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _AppColors.dark,
                    ),
                  ),
                  const Spacer(),
                  if (_sortMode != _SortMode.dateNew)
                    _ActiveChip(label: _sortLabel, color: _AppColors.red),
                  if (_filterSecret)
                    _ActiveChip(label: '🔑 Bí kíp', color: _AppColors.gold),
                  if (_isGridMode)
                    _ActiveChip(label: '⊞ Lưới', color: _AppColors.muted),
                  const SizedBox(width: 4),
                  if (!viewModel.isLoading && feasts.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: _AppColors.red,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text('${feasts.length}',
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
          else if (feasts.isEmpty)
            SliverFillRemaining(
              child: _searchQuery.isNotEmpty
                  ? _SearchEmptyState(query: _searchQuery)
                  : _EmptyState(),
            )
          else if (_isGridMode)
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverGrid(
                  gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.82,
                  ),
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => _FeastGridCard(
                      feast: feasts[index],
                      index: index,
                      onTap: () => Navigator.push(context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  FeastDetailView(feast: feasts[index]))),
                      onEdit: () => _showEditFeastDialog(
                          context, viewModel, feasts[index]),
                      onDelete: () =>
                          _confirmDelete(context, viewModel, feasts[index]),
                    ),
                    childCount: feasts.length,
                  ),
                ),
              )
            else
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 120),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                        (context, index) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _FeastCard(
                        feast: feasts[index],
                        index: index,
                        onTap: () => Navigator.push(context,
                            MaterialPageRoute(
                                builder: (_) =>
                                    FeastDetailView(feast: feasts[index]))),
                        onEdit: () => _showEditFeastDialog(
                            context, viewModel, feasts[index]),
                        onDelete: () =>
                            _confirmDelete(context, viewModel, feasts[index]),
                      ),
                    ),
                    childCount: feasts.length,
                  ),
                ),
              ),
        ],
      ),

      // ── FAB ───────────────────────────────────────────────────────────────
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: _AddFeastFab(
        onTap: () => _showAddFeastDialog(context),
      ),
    );
  }

  // ── Confirm delete ────────────────────────────────────────────────────────
  void _confirmDelete(
      BuildContext context, FeastViewModel viewModel, Feast feast) {
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
              const Text('Xoá mâm cỗ?',
                  style: TextStyle(
                    fontFamily: 'Playfair Display',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: _AppColors.dark,
                  )),
              const SizedBox(height: 8),
              Text(
                'Bạn có chắc muốn xoá mâm cỗ này không?\nHành động này không thể hoàn tác.',
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
                        viewModel.deleteFeast(feast.id!);
                        Navigator.pop(ctx);
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

  // ── Add Feast Bottom Sheet ────────────────────────────────────────────────
  void _showAddFeastDialog(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();

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
                      color: _AppColors.red.withOpacity(.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.table_bar_rounded,
                        color: _AppColors.red, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text('Tạo mâm cỗ mới',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _AppColors.dark,
                      )),
                ],
              ),
              const SizedBox(height: 24),
              _InputLabel(label: 'Tên mâm cỗ', required: true),
              const SizedBox(height: 8),
              _StyledTextField(
                controller: nameController,
                hint: 'VD: Cỗ Tất Niên 2025',
                icon: Icons.table_bar_rounded,
              ),
              const SizedBox(height: 16),
              _InputLabel(label: 'Mô tả', required: false),
              const SizedBox(height: 8),
              _StyledTextField(
                controller: descController,
                hint: 'Thêm ghi chú cho mâm cỗ...',
                icon: Icons.notes_rounded,
                maxLines: 3,
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
                        if (nameController.text.isNotEmpty) {
                          context.read<FeastViewModel>().createFeast(Feast(
                            name: nameController.text.trim(),
                            description: descController.text.trim(),
                            createdAt: DateTime.now(),
                          ));
                          Navigator.pop(ctx);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _AppColors.red,
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
                          Icon(Icons.check_circle_outline_rounded, size: 18),
                          SizedBox(width: 8),
                          Text('Tạo mâm cỗ',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 15)),
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

  // ── Edit Feast Bottom Sheet ───────────────────────────────────────────────
  void _showEditFeastDialog(
      BuildContext context, FeastViewModel viewModel, Feast feast) {
    final nameController = TextEditingController(text: feast.name);
    final descController =
    TextEditingController(text: feast.description ?? '');

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
                  const Text('Sửa mâm cỗ',
                      style: TextStyle(
                        fontFamily: 'Playfair Display',
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: _AppColors.dark,
                      )),
                ],
              ),
              const SizedBox(height: 20),

              // Chip "Đang sửa"
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: _AppColors.red.withOpacity(.06),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: _AppColors.red.withOpacity(.15)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline_rounded,
                        size: 14,
                        color: _AppColors.red.withOpacity(.7)),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Đang sửa: ${feast.name}',
                        style: TextStyle(
                            fontSize: 12,
                            color: _AppColors.red.withOpacity(.8),
                            fontWeight: FontWeight.w600),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Tên mâm cỗ
              _InputLabel(label: 'Tên mâm cỗ', required: true),
              const SizedBox(height: 8),
              _StyledTextField(
                controller: nameController,
                hint: 'VD: Cỗ Tất Niên 2025',
                icon: Icons.table_bar_rounded,
              ),
              const SizedBox(height: 16),

              // Mô tả
              _InputLabel(label: 'Mô tả', required: false),
              const SizedBox(height: 8),
              _StyledTextField(
                controller: descController,
                hint: 'Thêm ghi chú cho mâm cỗ...',
                icon: Icons.notes_rounded,
                maxLines: 3,
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
                          await viewModel.updateFeast(
                            Feast(
                              id:          feast.id,
                              name:        nameController.text.trim(),
                              description: descController.text.trim(),
                              createdAt:   feast.createdAt,
                            ),
                          );
                        }
                        if (ctx.mounted) Navigator.pop(ctx);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _AppColors.red,
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

// ─── Feast Card (List) ────────────────────────────────────────────────────────
class _FeastCard extends StatelessWidget {
  final Feast feast;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FeastCard({
    required this.feast,
    required this.index,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  static const _icons = ['🍲', '🥢', '🍱', '🎋', '🏮', '🥮'];

  @override
  Widget build(BuildContext context) {
    final emoji = _icons[index % _icons.length];
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
            border: Border.all(color: _AppColors.red.withOpacity(.07)),
            boxShadow: [
              BoxShadow(
                color: _AppColors.red.withOpacity(.07),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Emoji icon
              Container(
                width: 56, height: 56,
                decoration: BoxDecoration(
                  color: _AppColors.red.withOpacity(.08),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                    child:
                    Text(emoji, style: const TextStyle(fontSize: 28))),
              ),
              const SizedBox(width: 14),

              // Thông tin
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(feast.name,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _AppColors.dark),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(
                      feast.description?.isNotEmpty == true
                          ? feast.description!
                          : 'Chưa có mô tả',
                      style: TextStyle(
                          fontSize: 12,
                          color: _AppColors.muted.withOpacity(.8),
                          height: 1.4),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 11,
                            color: _AppColors.muted.withOpacity(.6)),
                        const SizedBox(width: 4),
                        Text(_formatDate(feast.createdAt),
                            style: TextStyle(
                                fontSize: 11,
                                color: _AppColors.muted.withOpacity(.6),
                                fontWeight: FontWeight.w500)),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),

              // Nút sửa + xoá + mũi tên
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
                            color: _AppColors.red.withOpacity(.08),
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
                      size: 13, color: _AppColors.muted.withOpacity(.5)),
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

// ─── Feast Grid Card ──────────────────────────────────────────────────────────
class _FeastGridCard extends StatelessWidget {
  final Feast feast;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _FeastGridCard({
    required this.feast,
    required this.index,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  static const _icons = ['🍲', '🥢', '🍱', '🎋', '🏮', '🥮'];

  @override
  Widget build(BuildContext context) {
    final emoji = _icons[index % _icons.length];
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: _AppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: _AppColors.red.withOpacity(.07)),
            boxShadow: [
              BoxShadow(
                color: _AppColors.red.withOpacity(.07),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 46, height: 46,
                    decoration: BoxDecoration(
                      color: _AppColors.red.withOpacity(.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                        child: Text(emoji,
                            style: const TextStyle(fontSize: 24))),
                  ),
                  const Spacer(),
                  // Nút sửa + xoá nằm ngang nhau
                  GestureDetector(
                    onTap: onEdit,
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: _AppColors.gold.withOpacity(.1),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.edit_rounded,
                          color: _AppColors.gold, size: 14),
                    ),
                  ),
                  const SizedBox(width: 6),
                  GestureDetector(
                    onTap: onDelete,
                    child: Container(
                      width: 28, height: 28,
                      decoration: BoxDecoration(
                        color: _AppColors.red.withOpacity(.07),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.delete_outline_rounded,
                          color: _AppColors.red, size: 15),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(feast.name,
                  style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _AppColors.dark),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
              const SizedBox(height: 4),
              Text(
                feast.description?.isNotEmpty == true
                    ? feast.description!
                    : 'Chưa có mô tả',
                style: TextStyle(
                    fontSize: 11,
                    color: _AppColors.muted.withOpacity(.7),
                    height: 1.4),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const Spacer(),
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded,
                      size: 10, color: _AppColors.muted.withOpacity(.5)),
                  const SizedBox(width: 3),
                  Text(_formatDate(feast.createdAt),
                      style: TextStyle(
                          fontSize: 10,
                          color: _AppColors.muted.withOpacity(.6),
                          fontWeight: FontWeight.w500)),
                  const Spacer(),
                  Icon(Icons.arrow_forward_ios_rounded,
                      size: 10, color: _AppColors.muted.withOpacity(.4)),
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
            const Text('🏮', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('Chưa có mâm cỗ nào',
                style: TextStyle(
                  fontFamily: 'Playfair Display',
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: _AppColors.dark,
                )),
            const SizedBox(height: 8),
            Text(
              'Tạo mâm cỗ đầu tiên để bắt đầu\nlưu lại những công thức ngày Tết.',
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
            Text('Không có mâm cỗ nào tên\n"$query"',
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
class _AddFeastFab extends StatelessWidget {
  final VoidCallback onTap;
  const _AddFeastFab({required this.onTap});

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
                    Text('Tạo mâm cỗ mới',
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

// ─── Shared Widgets ───────────────────────────────────────────────────────────
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
          const SizedBox(width: 4),
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
  final int maxLines;

  const _StyledTextField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 14, color: _AppColors.dark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: _AppColors.muted.withOpacity(.5), fontSize: 14),
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
          borderSide:
          const BorderSide(color: _AppColors.red, width: 2),
        ),
      ),
    );
  }
}
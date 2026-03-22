import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_step.dart';
import '../../viewmodels/recipe_viewmodel.dart';

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

// ─── Step input data ──────────────────────────────────────────────────────────
class StepInputData {
  final TextEditingController instructionCtrl = TextEditingController();
  final TextEditingController timeCtrl        = TextEditingController();

  void dispose() {
    instructionCtrl.dispose();
    timeCtrl.dispose();
  }
}

class RecipeFormView extends StatefulWidget {
  final Recipe? existingRecipe;
  const RecipeFormView({super.key, this.existingRecipe});

  @override
  State<RecipeFormView> createState() => _RecipeFormViewState();
}

class _RecipeFormViewState extends State<RecipeFormView> {
  final _formKey          = GlobalKey<FormState>();
  final _nameController   = TextEditingController();
  final _descController   = TextEditingController();
  final _categoryController = TextEditingController();
  bool _isSecret          = false;
  final List<StepInputData> _stepsData = [];

  @override
  void initState() {
    super.initState();
    if (widget.existingRecipe != null) {
      _nameController.text     = widget.existingRecipe!.name;
      _descController.text     = widget.existingRecipe!.description ?? '';
      _categoryController.text = widget.existingRecipe!.category ?? '';
      _isSecret                = widget.existingRecipe!.isFamilySecret;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final steps = await context
            .read<RecipeViewModel>()
            .loadStepsForRecipe(widget.existingRecipe!.id!);
        setState(() {
          for (var step in steps) {
            final data = StepInputData();
            data.instructionCtrl.text = step.instruction;
            if (step.durationSeconds != null && step.durationSeconds! > 0) {
              data.timeCtrl.text = (step.durationSeconds! ~/ 60).toString();
            }
            _stepsData.add(data);
          }
          if (_stepsData.isEmpty) _addStep();
        });
      });
    } else {
      _addStep();
    }
  }

  void _addStep() => setState(() => _stepsData.add(StepInputData()));

  void _removeStep(int index) {
    setState(() {
      _stepsData[index].dispose();
      _stepsData.removeAt(index);
    });
  }

  void _saveRecipe() {
    if (_formKey.currentState!.validate()) {
      final steps = <RecipeStep>[];
      for (int i = 0; i < _stepsData.length; i++) {
        final instruction = _stepsData[i].instructionCtrl.text;
        final timeText    = _stepsData[i].timeCtrl.text;
        if (instruction.isNotEmpty) {
          steps.add(RecipeStep(
            stepNumber:      i + 1,
            instruction:     instruction,
            durationSeconds: (int.tryParse(timeText) ?? 0) * 60,
          ));
        }
      }

      if (widget.existingRecipe == null) {
        context.read<RecipeViewModel>().addRecipeWithSteps(
          Recipe(
            name:           _nameController.text.trim(),
            description:    _descController.text.trim(),
            category:       _categoryController.text.trim().isEmpty
                ? 'Chưa phân loại'
                : _categoryController.text.trim(),
            isFamilySecret: _isSecret,
            createdAt:      DateTime.now(),
          ),
          steps,
        );
      } else {
        context.read<RecipeViewModel>().updateRecipeWithSteps(
          Recipe(
            id:             widget.existingRecipe!.id,
            name:           _nameController.text.trim(),
            description:    _descController.text.trim(),
            category:       _categoryController.text.trim().isEmpty
                ? 'Chưa phân loại'
                : _categoryController.text.trim(),
            isFamilySecret: _isSecret,
            createdAt:      widget.existingRecipe!.createdAt,
          ),
          steps,
        );
      }
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    _categoryController.dispose();
    for (var s in _stepsData) s.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingRecipe != null;

    return Scaffold(
      backgroundColor: _AppColors.cream,
      body: Form(
        key: _formKey,
        child: CustomScrollView(
          slivers: [
            // ── AppBar ──────────────────────────────────────────────────
            SliverAppBar(
              expandedHeight: 160,
              pinned: true,
              stretch: true,
              backgroundColor: _isSecret ? const Color(0xFF7D5A00) : _AppColors.red,
              leading: Padding(
                padding: const EdgeInsets.only(left: 8),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              flexibleSpace: FlexibleSpaceBar(
                background: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: _isSecret
                          ? [const Color(0xFF5C4000), const Color(0xFF9A7000)]
                          : [_AppColors.redDark, _AppColors.red],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
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
                      // Text
                      Positioned(
                        left: 20, right: 20, bottom: 24,
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
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    isEditing ? '✏️ ' : '➕ ',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                  Text(
                                    isEditing ? 'CHỈNH SỬA' : 'CÔNG THỨC MỚI',
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: _AppColors.goldLight,
                                      letterSpacing: .8,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isEditing
                                  ? widget.existingRecipe!.name
                                  : 'Thêm Bí Kíp Mới',
                              style: const TextStyle(
                                fontFamily: 'Playfair Display',
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                height: 1.2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // ── Wave ────────────────────────────────────────────────────
            SliverToBoxAdapter(
              child: SizedBox(
                height: 28,
                child: Stack(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 400),
                      color: _isSecret ? const Color(0xFF9A7000) : _AppColors.red,
                      height: 14,
                    ),
                    Container(
                      height: 28,
                      decoration: const BoxDecoration(
                        color: _AppColors.cream,
                        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
              sliver: SliverList(
                delegate: SliverChildListDelegate([

                  // ── Section: Thông tin chung ────────────────────────
                  _SectionHeader(
                    icon: Icons.info_outline_rounded,
                    title: 'Thông tin chung',
                  ),
                  const SizedBox(height: 12),

                  // Tên món
                  _InputLabel(label: 'Tên món ăn', required: true),
                  const SizedBox(height: 6),
                  _StyledFormField(
                    controller: _nameController,
                    hint: 'VD: Thịt Đông Bà Nội',
                    icon: Icons.restaurant_rounded,
                    validator: (v) =>
                    v == null || v.isEmpty ? 'Vui lòng nhập tên món' : null,
                  ),
                  const SizedBox(height: 14),

                  // Phân loại
                  _InputLabel(label: 'Phân loại', required: false),
                  const SizedBox(height: 6),
                  _StyledFormField(
                    controller: _categoryController,
                    hint: 'VD: Món canh, Bánh, Đồ muối...',
                    icon: Icons.category_rounded,
                  ),
                  const SizedBox(height: 14),

                  // Mô tả
                  _InputLabel(label: 'Mô tả ngắn', required: false),
                  const SizedBox(height: 6),
                  _StyledFormField(
                    controller: _descController,
                    hint: 'Vài dòng giới thiệu về món ăn...',
                    icon: Icons.notes_rounded,
                    maxLines: 3,
                  ),
                  const SizedBox(height: 14),

                  // Toggle bí kíp
                  _SecretToggle(
                    value: _isSecret,
                    onChanged: (v) => setState(() => _isSecret = v),
                  ),

                  const SizedBox(height: 24),

                  // ── Section: Các bước ───────────────────────────────
                  _SectionHeader(
                    icon: Icons.format_list_numbered_rounded,
                    title: 'Các bước thực hiện',
                  ),
                  const SizedBox(height: 12),

                  // Danh sách bước
                  ...List.generate(_stepsData.length, (index) => _StepInputCard(
                    index: index,
                    data: _stepsData[index],
                    canRemove: _stepsData.length > 1,
                    onRemove: () => _removeStep(index),
                  )),

                  // Nút thêm bước
                  const SizedBox(height: 4),
                  _AddStepButton(onTap: _addStep),
                  const SizedBox(height: 28),

                  // ── Nút lưu ─────────────────────────────────────────
                  _SaveButton(
                    isEditing: isEditing,
                    isSecret: _isSecret,
                    onTap: _saveRecipe,
                  ),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section Header ───────────────────────────────────────────────────────────
class _SectionHeader extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionHeader({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 32, height: 32,
          decoration: BoxDecoration(
            color: _AppColors.red.withOpacity(.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: _AppColors.red, size: 17),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Playfair Display',
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: _AppColors.dark,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(child: Divider(color: _AppColors.red.withOpacity(.15), thickness: 1)),
      ],
    );
  }
}

// ─── Input Label ──────────────────────────────────────────────────────────────
class _InputLabel extends StatelessWidget {
  final String label;
  final bool required;
  const _InputLabel({required this.label, required this.required});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: _AppColors.dark,
          ),
        ),
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

// ─── Styled TextFormField ─────────────────────────────────────────────────────
class _StyledFormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final int maxLines;
  final String? Function(String?)? validator;

  const _StyledFormField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.maxLines = 1,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14, color: _AppColors.dark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(
            color: _AppColors.muted.withOpacity(.45), fontSize: 14),
        prefixIcon: Icon(icon, color: _AppColors.muted, size: 20),
        filled: true,
        fillColor: _AppColors.cardBg,
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
          borderSide: const BorderSide(color: _AppColors.red, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}

// ─── Secret Toggle ────────────────────────────────────────────────────────────
class _SecretToggle extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;
  const _SecretToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: value
            ? const Color(0xFFFFFBE6)
            : _AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: value
              ? _AppColors.gold.withOpacity(.5)
              : _AppColors.muted.withOpacity(.2),
          width: value ? 1.5 : 1,
        ),
        boxShadow: value
            ? [BoxShadow(
          color: _AppColors.gold.withOpacity(.12),
          blurRadius: 12,
          offset: const Offset(0, 3),
        )]
            : [],
      ),
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 44, height: 44,
            decoration: BoxDecoration(
              color: value
                  ? _AppColors.gold.withOpacity(.15)
                  : _AppColors.muted.withOpacity(.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              value ? Icons.lock_rounded : Icons.lock_open_rounded,
              color: value ? _AppColors.gold : _AppColors.muted,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bí kíp gia truyền',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: value ? const Color(0xFF7D5A00) : _AppColors.dark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Yêu cầu mã PIN khi mở xem',
                  style: TextStyle(
                    fontSize: 12,
                    color: value
                        ? _AppColors.gold.withOpacity(.8)
                        : _AppColors.muted.withOpacity(.7),
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: _AppColors.gold,
            activeTrackColor: _AppColors.gold.withOpacity(.3),
            inactiveThumbColor: _AppColors.muted.withOpacity(.5),
            inactiveTrackColor: _AppColors.muted.withOpacity(.15),
          ),
        ],
      ),
    );
  }
}

// ─── Step Input Card ──────────────────────────────────────────────────────────
class _StepInputCard extends StatelessWidget {
  final int index;
  final StepInputData data;
  final bool canRemove;
  final VoidCallback onRemove;

  const _StepInputCard({
    required this.index,
    required this.data,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Timeline
            Column(
              children: [
                Container(
                  width: 36, height: 36,
                  decoration: const BoxDecoration(
                    color: _AppColors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: _AppColors.red.withOpacity(.12),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),

            // Card
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: _AppColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: _AppColors.red.withOpacity(.08)),
                  boxShadow: [
                    BoxShadow(
                      color: _AppColors.red.withOpacity(.05),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Instruction input
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 12, 8, 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: TextField(
                              controller: data.instructionCtrl,
                              maxLines: null,
                              style: const TextStyle(
                                fontSize: 14,
                                color: _AppColors.dark,
                                height: 1.5,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Nhập hướng dẫn bước ${index + 1}...',
                                hintStyle: TextStyle(
                                  color: _AppColors.muted.withOpacity(.45),
                                  fontSize: 14,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (canRemove)
                            GestureDetector(
                              onTap: onRemove,
                              child: Container(
                                width: 28, height: 28,
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(.07),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.close_rounded,
                                  color: Colors.red.shade300,
                                  size: 16,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Divider
                    Divider(
                      color: _AppColors.red.withOpacity(.08),
                      height: 1,
                      thickness: 1,
                      indent: 14,
                      endIndent: 14,
                    ),

                    // Timer input
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 10),
                      child: Row(
                        children: [
                          Container(
                            width: 28, height: 28,
                            decoration: BoxDecoration(
                              color: _AppColors.red.withOpacity(.08),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.timer_rounded,
                                color: _AppColors.red, size: 15),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: data.timeCtrl,
                              keyboardType: TextInputType.number,
                              style: const TextStyle(
                                fontSize: 13,
                                color: _AppColors.dark,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Thời gian (tuỳ chọn)',
                                hintStyle: TextStyle(
                                  color: _AppColors.muted.withOpacity(.45),
                                  fontSize: 13,
                                ),
                                suffixText: 'phút',
                                suffixStyle: TextStyle(
                                  color: _AppColors.muted.withOpacity(.7),
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Add Step Button ──────────────────────────────────────────────────────────
class _AddStepButton extends StatelessWidget {
  final VoidCallback onTap;
  const _AddStepButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _AppColors.cardBg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _AppColors.red.withOpacity(.25),
            style: BorderStyle.solid,
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.add_circle_outline_rounded,
                color: _AppColors.red, size: 20),
            SizedBox(width: 8),
            Text(
              'Thêm bước mới',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _AppColors.red,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Save Button ──────────────────────────────────────────────────────────────
class _SaveButton extends StatelessWidget {
  final bool isEditing;
  final bool isSecret;
  final VoidCallback onTap;

  const _SaveButton({
    required this.isEditing,
    required this.isSecret,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        height: 56,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSecret
                ? [const Color(0xFF5C4000), const Color(0xFF9A7000)]
                : [_AppColors.redDark, _AppColors.red],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (isSecret ? _AppColors.gold : _AppColors.red)
                  .withOpacity(.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Stack(
          children: [
            // Chấm trang trí
            Positioned(
              top: 8, right: 16,
              child: Container(
                width: 8, height: 8,
                decoration: BoxDecoration(
                  color: isSecret
                      ? _AppColors.goldLight.withOpacity(.6)
                      : _AppColors.goldLight,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isEditing
                        ? Icons.check_circle_rounded
                        : Icons.save_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    isEditing ? 'Cập nhật công thức' : 'Lưu công thức',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
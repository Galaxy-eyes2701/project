import 'package:flutter/material.dart';
import 'package:project/views/recipe/recipe_form_view.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../../domain/entities/recipe.dart';
import '../../domain/entities/recipe_step.dart';
import '../../viewmodels/recipe_viewmodel.dart';

// ─── Bảng màu Tết ────────────────────────────────────────────────────────────
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

class RecipeDetailView extends StatelessWidget {
  final Recipe recipe;
  const RecipeDetailView({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final viewModel = context.read<RecipeViewModel>();
    final isSecret  = recipe.isFamilySecret;

    return Scaffold(
      backgroundColor: _AppColors.cream,
      body: CustomScrollView(
        slivers: [
          // ── AppBar ──────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            stretch: true,
            backgroundColor: isSecret ? const Color(0xFF7D5A00) : _AppColors.red,
            leading: Padding(
              padding: const EdgeInsets.only(left: 8),
              child: IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, color: Colors.white),
                tooltip: 'Sửa công thức',
                onPressed: () async {
                  final saved = await Navigator.push<bool>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RecipeFormView(existingRecipe: recipe),
                    ),
                  );
                  if (context.mounted && saved == true) {
                    Navigator.pop(context); // quay về list
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Công thức đã được cập nhật!'),
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
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Gradient nền
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isSecret
                            ? [const Color(0xFF5C4000), const Color(0xFF9A7000)]
                            : [_AppColors.redDark, _AppColors.red],
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
                  // Nội dung chữ
                  Positioned(
                    left: 20, right: 20, bottom: 28,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Badge
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: _AppColors.gold.withOpacity(.18),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: _AppColors.gold.withOpacity(.45)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(isSecret ? '🔒 ' : '🍽️ ',
                                  style: const TextStyle(fontSize: 11)),
                              Text(
                                isSecret ? 'BÍ KÍP GIA TRUYỀN' : 'CÔNG THỨC',
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
                          recipe.name,
                          style: const TextStyle(
                            fontFamily: 'Playfair Display',
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.15,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (recipe.category != null)
                          _MetaPill(icon: Icons.category_rounded, label: recipe.category!),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Wave chuyển tiếp ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SizedBox(
              height: 28,
              child: Stack(
                children: [
                  Container(
                    color: isSecret ? const Color(0xFF9A7000) : _AppColors.red,
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

          // ── Mô tả ────────────────────────────────────────────────────────
          if (recipe.description != null && recipe.description!.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _AppColors.cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _AppColors.red.withOpacity(.07)),
                    boxShadow: [
                      BoxShadow(
                        color: _AppColors.red.withOpacity(.06),
                        blurRadius: 12,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: _AppColors.red.withOpacity(.09),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.notes_rounded,
                            color: _AppColors.red, size: 18),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Mô tả',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: _AppColors.muted,
                                    letterSpacing: .3)),
                            const SizedBox(height: 4),
                            Text(
                              recipe.description!,
                              style: const TextStyle(
                                  fontSize: 14,
                                  color: _AppColors.dark,
                                  height: 1.5),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Section header các bước ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: [
                  const Text(
                    'Các bước thực hiện',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: _AppColors.dark,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    width: 32, height: 32,
                    decoration: BoxDecoration(
                      color: _AppColors.red.withOpacity(.09),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.format_list_numbered_rounded,
                        color: _AppColors.red, size: 18),
                  ),
                ],
              ),
            ),
          ),

          // ── Danh sách các bước ────────────────────────────────────────────
          SliverToBoxAdapter(
            child: FutureBuilder<List<RecipeStep>>(
              future: viewModel.loadStepsForRecipe(recipe.id!),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Center(
                      child: CircularProgressIndicator(color: _AppColors.red),
                    ),
                  );
                }

                final steps = snapshot.data ?? [];

                if (steps.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(40),
                    child: Column(
                      children: [
                        Text('📋', style: TextStyle(fontSize: 48)),
                        SizedBox(height: 12),
                        Text(
                          'Chưa có hướng dẫn cho món này.',
                          style: TextStyle(color: _AppColors.muted, fontSize: 14),
                        ),
                      ],
                    ),
                  );
                }

                return Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                  child: Column(
                    children: List.generate(steps.length, (index) {
                      final step   = steps[index];
                      final isLast = index == steps.length - 1;
                      return _StepCard(
                        step: step,
                        isLast: isLast,
                        onTimer: () => _showTimerDialog(
                            context, step.durationSeconds ?? 300),
                      );
                    }),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── Timer Dialog ────────────────────────────────────────────────────────────
  void _showTimerDialog(BuildContext context, int totalSeconds) {
    int remainingSeconds = totalSeconds;
    Timer? timer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          void startTimer() {
            timer = Timer.periodic(const Duration(seconds: 1), (t) {
              if (remainingSeconds > 0) {
                setState(() => remainingSeconds--);
              } else {
                t.cancel();
              }
            });
          }

          String formatTime(int s) =>
              '${(s ~/ 60).toString().padLeft(2, '0')}:${(s % 60).toString().padLeft(2, '0')}';

          final isDone    = remainingSeconds == 0;
          final isRunning = timer != null && timer!.isActive;
          final progress  = totalSeconds == 0 ? 1.0 : 1 - remainingSeconds / totalSeconds;

          return Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
            backgroundColor: _AppColors.cardBg,
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 56, height: 56,
                    decoration: BoxDecoration(
                      color: isDone
                          ? Colors.green.withOpacity(.12)
                          : _AppColors.red.withOpacity(.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDone ? Icons.check_circle_rounded : Icons.timer_rounded,
                      color: isDone ? Colors.green : _AppColors.red,
                      size: 28,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Đồng Hồ Nấu Ăn',
                    style: TextStyle(
                      fontFamily: 'Playfair Display',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: _AppColors.dark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 130, height: 130,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 8,
                          backgroundColor: _AppColors.red.withOpacity(.1),
                          color: isDone ? Colors.green : _AppColors.red,
                        ),
                      ),
                      Column(
                        children: [
                          Text(
                            formatTime(remainingSeconds),
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w800,
                              color: _AppColors.dark,
                            ),
                          ),
                          if (isDone)
                            const Text('Xong rồi! 🎉',
                                style: TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: TextButton(
                          onPressed: () {
                            timer?.cancel();
                            Navigator.pop(context);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade300),
                            ),
                          ),
                          child: const Text('Đóng',
                              style: TextStyle(
                                  color: _AppColors.muted,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                      if (!isDone && !isRunning) ...[
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              startTimer();
                              setState(() {});
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12)),
                              elevation: 0,
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.play_arrow_rounded, size: 18),
                                SizedBox(width: 6),
                                Text('Bắt đầu',
                                    style: TextStyle(fontWeight: FontWeight.w700)),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ).then((_) => timer?.cancel());
  }
}

// ─── Step Card ────────────────────────────────────────────────────────────────
class _StepCard extends StatelessWidget {
  final RecipeStep step;
  final bool isLast;
  final VoidCallback onTimer;

  const _StepCard({
    required this.step,
    required this.isLast,
    required this.onTimer,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline: số bước + đường kẻ
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
                    '${step.stepNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: _AppColors.red.withOpacity(.15),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),

          // Card nội dung bước
          Expanded(
            child: Container(
              margin: EdgeInsets.only(bottom: isLast ? 0 : 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _AppColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _AppColors.red.withOpacity(.07)),
                boxShadow: [
                  BoxShadow(
                    color: _AppColors.red.withOpacity(.06),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    step.instruction,
                    style: const TextStyle(
                      fontSize: 14,
                      color: _AppColors.dark,
                      height: 1.6,
                    ),
                  ),
                  if (step.durationSeconds != null) ...[
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: onTimer,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: _AppColors.red.withOpacity(.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: _AppColors.red.withOpacity(.2)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.timer_rounded,
                                color: _AppColors.red, size: 14),
                            const SizedBox(width: 5),
                            Text(
                              _formatDuration(step.durationSeconds!),
                              style: const TextStyle(
                                fontSize: 12,
                                color: _AppColors.red,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDuration(int seconds) {
    if (seconds < 60) return '$seconds giây';
    final m = seconds ~/ 60;
    final s = seconds % 60;
    return s == 0 ? '$m phút' : '$m phút $s giây';
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
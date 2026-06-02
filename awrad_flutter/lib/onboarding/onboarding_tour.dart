import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/ornamental_divider.dart';
import '../widgets/sufi_logo.dart';

/// A single stop in the guided tour. When [targetKey] resolves to a laid-out
/// widget, the tour cuts a spotlight around it; otherwise the step is shown as
/// a centered welcome / closing card.
class TourStep {
  const TourStep({
    this.targetKey,
    required this.icon,
    required this.title,
    required this.body,
    this.radius = 14,
    this.padding = 8,
    this.shape = TourShape.rect,
    this.isIntro = false,
    this.isOutro = false,
    this.interactive = false,
  });

  final GlobalKey? targetKey;
  final IconData icon;
  final String title;
  final String body;

  /// Corner radius of the rounded-rect spotlight.
  final double radius;

  /// Extra padding inflated around the target rect.
  final double padding;
  final TourShape shape;

  /// Intro/outro render as a centered card with the order logo and no hole.
  final bool isIntro;
  final bool isOutro;

  /// When true the spotlight is "click-through": taps inside the hole reach the
  /// real control underneath so the user can actually try it.
  final bool interactive;
}

enum TourShape { rect, circle }

/// Full-screen coach-mark overlay. Walks the user through every control with a
/// dimmed background, an animated spotlight around the active target, and a
/// message card with next / back / skip controls.
class OnboardingTour extends StatefulWidget {
  const OnboardingTour({
    super.key,
    required this.steps,
    required this.onFinish,
  });

  final List<TourStep> steps;

  /// Called once when the tour is completed or skipped.
  final VoidCallback onFinish;

  @override
  State<OnboardingTour> createState() => _OnboardingTourState();
}

class _OnboardingTourState extends State<OnboardingTour>
    with TickerProviderStateMixin {
  int _index = 0;

  late final AnimationController _pulse;
  late final AnimationController _move; // animates the spotlight between steps
  late final AnimationController _card; // fades/slides the message card in

  Rect? _fromRect;
  Rect? _toRect;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1300),
    )..repeat(reverse: true);
    _move = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _card = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );
    // Resolve the first target after the first frame so render boxes exist.
    WidgetsBinding.instance.addPostFrameCallback((_) => _settleOnCurrent());
  }

  @override
  void dispose() {
    _pulse.dispose();
    _move.dispose();
    _card.dispose();
    super.dispose();
  }

  TourStep get _step => widget.steps[_index];

  /// Measures the active step's target and animates the spotlight onto it.
  void _settleOnCurrent() {
    if (!mounted) return;
    final next = _rectFor(_step.targetKey, _step.padding);
    setState(() {
      _fromRect = _toRect ?? next;
      _toRect = next;
    });
    _move.forward(from: 0);
    _card.forward(from: 0);
  }

  Rect? _rectFor(GlobalKey? key, double pad) {
    if (key == null) return null;
    final ctx = key.currentContext;
    if (ctx == null) return null;
    final box = ctx.findRenderObject() as RenderBox?;
    if (box == null || !box.attached) return null;
    final origin = box.localToGlobal(Offset.zero);
    return (origin & box.size).inflate(pad);
  }

  void _next() {
    if (_index >= widget.steps.length - 1) {
      _finish();
      return;
    }
    setState(() => _index++);
    _settleOnCurrent();
  }

  void _back() {
    if (_index == 0) return;
    setState(() => _index--);
    _settleOnCurrent();
  }

  void _finish() => widget.onFinish();

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLast = _index == widget.steps.length - 1;
    final centered = _step.isIntro || _step.isOutro || _toRect == null;
    final interactive = !centered && _step.interactive;

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Visual scrim + spotlight cut-out + pulsing ring (paint only — never
          // eats touches, so an interactive hole can pass them through).
          Positioned.fill(
            child: IgnorePointer(
              child: AnimatedBuilder(
                animation: Listenable.merge([_move, _pulse]),
                builder: (context, _) {
                  return CustomPaint(
                    size: size,
                    painter: _SpotlightPainter(
                      hole: centered ? null : _animatedHole(),
                      radius: _holeRadius(),
                      pulse: _pulse.value,
                    ),
                  );
                },
              ),
            ),
          ),
          // Touch layer. For a normal step a single barrier absorbs taps (and
          // advances). For an interactive step we tile four barriers around the
          // hole, leaving the hole itself open so the real control is tappable.
          if (interactive)
            ..._barriersAround(_toRect!)
          else
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: _next,
              ),
            ),
          // The message card.
          _buildCard(context, size, centered, isLast, interactive),
        ],
      ),
    );
  }

  Rect? _animatedHole() => RectTween(
    begin: _fromRect,
    end: _toRect,
  ).transform(Curves.easeOutCubic.transform(_move.value));

  double _holeRadius() {
    if (_step.shape == TourShape.circle) {
      return (_animatedHole()?.longestSide ?? 0) / 2;
    }
    return _step.radius;
  }

  /// Four tappable rectangles surrounding [hole] so everything except the hole
  /// absorbs taps (and advances the tour).
  List<Widget> _barriersAround(Rect hole) {
    Widget barrier(double? left, double? top, double? width, double? height) {
      return Positioned(
        left: left,
        top: top,
        width: width,
        height: height,
        child: GestureDetector(behavior: HitTestBehavior.opaque, onTap: _next),
      );
    }

    final size = MediaQuery.of(context).size;
    return [
      barrier(0, 0, size.width, hole.top.clamp(0, size.height)), // above
      barrier(0, hole.bottom, size.width, size.height), // below
      barrier(0, hole.top, hole.left.clamp(0, size.width), hole.height), // left
      barrier(hole.right, hole.top, size.width, hole.height), // right
    ];
  }

  Widget _buildCard(
    BuildContext context,
    Size size,
    bool centered,
    bool isLast,
    bool interactive,
  ) {
    final mq = MediaQuery.of(context);
    final safeTop = mq.padding.top + 12;
    final safeBottom = mq.padding.bottom + 12;
    const gap = 16.0;

    final card = FadeTransition(
      opacity: CurvedAnimation(parent: _card, curve: Curves.easeOut),
      child: SlideTransition(
        position: Tween(
          begin: const Offset(0, 0.06),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _card, curve: Curves.easeOutCubic)),
        child: _MessageCard(
          step: _step,
          index: _index,
          total: widget.steps.length,
          isLast: isLast,
          interactive: interactive,
          onNext: _next,
          onBack: _back,
          onSkip: _finish,
        ),
      ),
    );

    Widget capped(double maxHeight) => ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight.clamp(120, size.height)),
      child: card,
    );

    if (centered) {
      return Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(22, safeTop, 22, safeBottom),
          child: capped(size.height - safeTop - safeBottom),
        ),
      );
    }

    // Keep the card in the half opposite the spotlight, fully inside the safe
    // area, so its message can never hide behind the status / navigation bars.
    final hole = _toRect!;

    // A very large spotlight (e.g. the whole reading area) leaves no room on
    // either side, so just centre the card over it.
    if (hole.height > size.height * 0.55) {
      return Center(
        child: Padding(
          padding: EdgeInsets.fromLTRB(22, safeTop, 22, safeBottom),
          child: capped(size.height - safeTop - safeBottom),
        ),
      );
    }

    final placeBelow = hole.center.dy < size.height / 2;
    if (placeBelow) {
      final top = (hole.bottom + gap).clamp(safeTop, size.height);
      return Positioned(
        left: 16,
        right: 16,
        top: top,
        child: capped(size.height - safeBottom - top),
      );
    } else {
      final bottom = (size.height - hole.top + gap).clamp(
        safeBottom,
        size.height,
      );
      return Positioned(
        left: 16,
        right: 16,
        bottom: bottom,
        child: capped(size.height - safeTop - bottom),
      );
    }
  }
}

/// Paints the translucent scrim with an optional rounded / circular cut-out and
/// a soft pulsing gold ring around it.
class _SpotlightPainter extends CustomPainter {
  _SpotlightPainter({
    required this.hole,
    required this.radius,
    required this.pulse,
  });

  final Rect? hole;
  final double radius;
  final double pulse;

  @override
  void paint(Canvas canvas, Size size) {
    final scrim = Paint()..color = Colors.black.withValues(alpha: 0.74);
    final full = Offset.zero & size;

    if (hole == null) {
      canvas.drawRect(full, scrim);
      return;
    }

    final rrect = RRect.fromRectAndRadius(hole!, Radius.circular(radius));
    final cut = Path()
      ..addRect(full)
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(cut, scrim);

    // Pulsing gold ring hugging the spotlight.
    final spread = 2.0 + pulse * 4.0;
    final ring = RRect.fromRectAndRadius(
      hole!.inflate(spread),
      Radius.circular(radius + spread),
    );
    canvas.drawRRect(
      ring,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..color = AppColors.gold.withValues(alpha: 0.85 - pulse * 0.45),
    );
  }

  @override
  bool shouldRepaint(_SpotlightPainter old) =>
      old.hole != hole || old.radius != radius || old.pulse != pulse;
}

class _MessageCard extends StatelessWidget {
  const _MessageCard({
    required this.step,
    required this.index,
    required this.total,
    required this.isLast,
    required this.interactive,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  final TourStep step;
  final int index;
  final int total;
  final bool isLast;
  final bool interactive;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final centered = step.isIntro || step.isOutro;

    return Container(
      constraints: const BoxConstraints(maxWidth: 440),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 22,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
      // Scrolls if the capped height is ever shorter than the content (very
      // small screens / large system fonts) so nothing is clipped.
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: centered
              ? CrossAxisAlignment.center
              : CrossAxisAlignment.stretch,
          children: [
            if (centered) ...[
              const SufiLogo(size: 64, showGlow: false),
              const SizedBox(height: 12),
              Text(
                step.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: AppTheme.fontScripture,
                  fontWeight: FontWeight.w700,
                  fontSize: 24,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(width: 180, child: OrnamentalDivider()),
              const SizedBox(height: 12),
            ] else ...[
              Row(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.gold.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Icon(
                      step.icon,
                      color: AppColors.goldBright,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      step.title,
                      style: const TextStyle(
                        fontFamily: AppTheme.fontUi,
                        fontWeight: FontWeight.w700,
                        fontSize: 17,
                        color: AppColors.gold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
            Text(
              step.body,
              textAlign: centered ? TextAlign.center : TextAlign.right,
              style: const TextStyle(
                fontFamily: AppTheme.fontUi,
                fontSize: 14.5,
                height: 1.8,
                color: AppColors.textPrimary,
              ),
            ),
            if (interactive) ...[const SizedBox(height: 12), const _TryHint()],
            const SizedBox(height: 16),
            _Dots(index: index, total: total),
            const SizedBox(height: 12),
            _Controls(
              index: index,
              total: total,
              isLast: isLast,
              onNext: onNext,
              onBack: onBack,
              onSkip: onSkip,
            ),
          ],
        ),
      ),
    );
  }
}

/// A gentle "try it yourself" prompt shown on interactive steps where the user
/// can tap the highlighted control through the spotlight.
class _TryHint extends StatelessWidget {
  const _TryHint();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.emerald.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.emerald.withValues(alpha: 0.5)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.touch_app_rounded, color: AppColors.greenLight, size: 18),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'جرّب الضغط على الزر المُضيء بنفسك، ثم تابع.',
              style: TextStyle(
                fontFamily: AppTheme.fontUi,
                fontWeight: FontWeight.w600,
                fontSize: 12.5,
                height: 1.5,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Dots extends StatelessWidget {
  const _Dots({required this.index, required this.total});
  final int index;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (i) {
        final active = i == index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: active ? 18 : 6,
          height: 6,
          decoration: BoxDecoration(
            color: active
                ? AppColors.gold
                : AppColors.textMuted.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(3),
          ),
        );
      }),
    );
  }
}

class _Controls extends StatelessWidget {
  const _Controls({
    required this.index,
    required this.total,
    required this.isLast,
    required this.onNext,
    required this.onBack,
    required this.onSkip,
  });

  final int index;
  final int total;
  final bool isLast;
  final VoidCallback onNext;
  final VoidCallback onBack;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Skip (hidden on the closing step where "finish" is the action).
        if (!isLast)
          TextButton(
            onPressed: onSkip,
            style: TextButton.styleFrom(
              foregroundColor: AppColors.textMuted,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            child: const Text(
              'تخطّي',
              style: TextStyle(
                fontFamily: AppTheme.fontUi,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ),
        const Spacer(),
        if (index > 0)
          TextButton.icon(
            onPressed: onBack,
            style: TextButton.styleFrom(foregroundColor: AppColors.gold),
            icon: const Icon(Icons.chevron_left_rounded, size: 20),
            label: const Text(
              'السابق',
              style: TextStyle(
                fontFamily: AppTheme.fontUi,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
        const SizedBox(width: 6),
        FilledButton(
          onPressed: onNext,
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.emerald,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 11),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isLast ? 'ابدأ القراءة' : 'التالي',
                style: const TextStyle(
                  fontFamily: AppTheme.fontUi,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Icon(
                isLast
                    ? Icons.auto_stories_rounded
                    : Icons.chevron_right_rounded,
                size: 20,
                color: Colors.white,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Builds the numbered step list — exported so the reader can pass in the
/// [GlobalKey]s attached to each real control.
List<TourStep> buildTourSteps({
  required GlobalKey menu,
  required GlobalKey bookmark,
  required GlobalKey fullscreen,
  required GlobalKey counter,
  required GlobalKey section,
  required GlobalKey pager,
  required GlobalKey prev,
  required GlobalKey notes,
  required GlobalKey jump,
  required GlobalKey search,
  required GlobalKey next,
}) {
  return [
    const TourStep(
      isIntro: true,
      icon: Icons.auto_stories_rounded,
      title: 'أهلاً بك في كتاب الأوراد',
      body:
          'دعنا في جولة سريعة نتعرّف فيها على كل زرّ وكل ميزة في التطبيق، '
          'لتقرأ أورادك براحة ويُسر. اضغط «التالي» للبدء.',
    ),
    TourStep(
      targetKey: menu,
      icon: Icons.menu_book_rounded,
      title: 'الفهرس',
      body:
          'يفتح فهرس الكتاب كاملاً: تنقّل بين الأبواب، تابع تقدّمك في كل باب، '
          'وابحث داخل الفهرس، كما تجد فيه إشاراتك المرجعية المحفوظة.',
      shape: TourShape.circle,
    ),
    TourStep(
      targetKey: bookmark,
      icon: Icons.bookmark_rounded,
      title: 'الإشارة المرجعية',
      body:
          'احفظ الصفحة الحالية بضغطة واحدة لتعود إليها متى شئت. '
          'يتحوّل لون الإشارة إلى الذهبي عندما تكون الصفحة محفوظة.',
      shape: TourShape.circle,
      interactive: true,
    ),
    TourStep(
      targetKey: fullscreen,
      icon: Icons.fullscreen_rounded,
      title: 'ملء الشاشة',
      body:
          'يخفي كل الأشرطة لتقرأ الصفحة كاملة دون أي مشتّتات. '
          'للخروج اضغط زر «خروج من ملء الشاشة» أو زر الرجوع.',
      shape: TourShape.circle,
    ),
    TourStep(
      targetKey: counter,
      icon: Icons.tag_rounded,
      title: 'رقم الصفحة',
      body:
          'يعرض رقم الصفحة الحالية من إجمالي صفحات الكتاب، '
          'بالأرقام نفسها المطبوعة في الكتاب الورقي.',
    ),
    TourStep(
      targetKey: section,
      icon: Icons.menu_rounded,
      title: 'الباب الحالي',
      body:
          'يبيّن اسم الباب الذي تقرأ فيه الآن، وشريط ذهبي يوضّح مقدار '
          'ما قطعته من هذا الباب.',
    ),
    TourStep(
      targetKey: pager,
      icon: Icons.swipe_rounded,
      title: 'تصفّح الصفحات',
      body:
          'اسحب يميناً ويساراً لتقليب الصفحات كالكتاب الحقيقي. '
          'اضغط ضغطة واحدة لإخفاء الأشرطة، وضغطتين (أو قرصاً بإصبعين) للتكبير والتصغير.',
    ),
    TourStep(
      targetKey: prev,
      icon: Icons.chevron_right_rounded,
      title: 'الصفحة السابقة',
      body:
          'السهم الموجود على يمين الشريط السفلي يرجعك صفحةً للخلف. '
          '(يظهر باهتاً ومعطّلاً عندما تكون في الصفحة الأولى.)',
      shape: TourShape.circle,
    ),
    TourStep(
      targetKey: notes,
      icon: Icons.edit_note_rounded,
      title: 'الملاحظات',
      body:
          'اكتب دعاءً أو ملاحظة على الصفحة الحالية لتعود إليها لاحقاً. '
          'تظهر نقطة ذهبية على الزر عندما تحتوي الصفحة على ملاحظة، '
          'ويمكنك تصفّح كل ملاحظاتك من هنا.',
      shape: TourShape.circle,
      interactive: true,
    ),
    TourStep(
      targetKey: jump,
      icon: Icons.tag_rounded,
      title: 'الانتقال السريع',
      body:
          'يعرض رقم صفحتك الحالية، واضغط عليه للانتقال مباشرةً '
          'إلى أي رقم صفحة تكتبه.',
      shape: TourShape.circle,
      interactive: true,
    ),
    TourStep(
      targetKey: search,
      icon: Icons.search_rounded,
      title: 'البحث في الكتاب',
      body:
          'ابحث عن أي كلمة أو جملة في الكتاب كاملاً، واضغط على أي نتيجة '
          'لتنتقل إلى موضعها مباشرة.',
      shape: TourShape.circle,
      interactive: true,
    ),
    TourStep(
      targetKey: next,
      icon: Icons.chevron_left_rounded,
      title: 'الصفحة التالية',
      body:
          'السهم الموجود على يسار الشريط السفلي ينقلك صفحةً للأمام. '
          'جرّبه الآن — اضغطه وشاهد الصفحة تتقدّم.',
      shape: TourShape.circle,
      interactive: true,
    ),
    const TourStep(
      isOutro: true,
      icon: Icons.check_circle_rounded,
      title: 'تمّت الجولة',
      body:
          'أصبحت الآن على دراية بكل مزايا التطبيق. '
          'تقبّل الله منك صالح الأعمال، وطابت أورادك.',
    ),
  ];
}

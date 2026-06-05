import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';

import '../theme/app_colors.dart';

/// A single rendered PDF page presented as a warm "manuscript" card with
/// pinch / double-tap zoom and pan. Reports zoom state up so the parent can
/// lock page swiping while the reader is zoomed in.
class BookPageView extends StatefulWidget {
  const BookPageView({
    super.key,
    required this.document,
    required this.pageNumber,
    required this.onTap,
    required this.onZoomChanged,
  });

  final PdfDocument? document;
  final int pageNumber;
  final VoidCallback onTap;
  final ValueChanged<bool> onZoomChanged;

  @override
  State<BookPageView> createState() => _BookPageViewState();
}

class _BookPageViewState extends State<BookPageView>
    with SingleTickerProviderStateMixin {
  final _tc = TransformationController();
  late final AnimationController _anim;
  Animation<Matrix4>? _zoomAnim;
  TapDownDetails? _doubleTapDetails;

  @override
  void initState() {
    super.initState();
    _anim =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 220),
        )..addListener(() {
          if (_zoomAnim != null) _tc.value = _zoomAnim!.value;
        });
    _tc.addListener(_onTransform);
  }

  void _onTransform() {
    final zoomed = _tc.value.getMaxScaleOnAxis() > 1.05;
    widget.onZoomChanged(zoomed);
  }

  void _animateTo(Matrix4 target) {
    _zoomAnim = Matrix4Tween(
      begin: _tc.value,
      end: target,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward(from: 0);
  }

  void _handleDoubleTap() {
    final zoomedIn = _tc.value.getMaxScaleOnAxis() > 1.05;
    if (zoomedIn) {
      _animateTo(Matrix4.identity());
    } else {
      final pos = _doubleTapDetails?.localPosition ?? Offset.zero;
      const scale = 2.5;
      final target = Matrix4.identity()
        ..translateByDouble(-pos.dx * (scale - 1), -pos.dy * (scale - 1), 0, 1)
        ..scaleByDouble(scale, scale, 1, 1);
      _animateTo(target);
    }
  }

  @override
  void dispose() {
    _tc.removeListener(_onTransform);
    _tc.dispose();
    _anim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onDoubleTapDown: (d) => _doubleTapDetails = d,
      onDoubleTap: _handleDoubleTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.parchment,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
          border: Border.all(
            color: AppColors.gold.withValues(alpha: 0.25),
            width: 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InteractiveViewer(
          transformationController: _tc,
          minScale: 1,
          maxScale: 4,
          panEnabled: true,
          child: SizedBox.expand(
            child: widget.document == null
                ? const _PageLoading()
                : PdfPageView(
                    document: widget.document,
                    pageNumber: widget.pageNumber,
                    alignment: Alignment.center,
                    backgroundColor: AppColors.parchment,
                    decoration: const BoxDecoration(color: AppColors.parchment),
                  ),
          ),
        ),
      ),
    );
  }
}

class _PageLoading extends StatelessWidget {
  const _PageLoading();
  @override
  Widget build(BuildContext context) =>
      const Center(child: CircularProgressIndicator(color: AppColors.goldDeep));
}

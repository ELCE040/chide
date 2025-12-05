import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/scheduler.dart';

/// Performance optimization utilities
class PerformanceOptimizations {
  /// Enable performance optimizations for the app
  static void enableOptimizations() {
    // Set preferred frame rate
    SchedulerBinding.instance.platformDispatcher.onReportTimings = (List<FrameTiming> timings) {
      // Monitor frame performance
      for (final timing in timings) {
        final frameDuration = timing.totalSpan.inMilliseconds;
        if (frameDuration > 16) {
          // Frame took longer than 16ms (60fps threshold)
          debugPrint('Slow frame detected: ${frameDuration}ms');
        }
      }
    };

    // Optimize image cache
    PaintingBinding.instance.imageCache.maximumSize = 100;
    PaintingBinding.instance.imageCache.maximumSizeBytes = 50 << 20; // 50MB
  }

  /// Optimize list performance with lazy loading
  static Widget optimizedListView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    ScrollController? controller,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
  }) {
    return ListView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      cacheExtent: 500, // Cache 500 pixels worth of items
      addAutomaticKeepAlives: false, // Don't keep items alive when off-screen
      addRepaintBoundaries: true, // Add repaint boundaries for better performance
    );
  }

  /// Optimized grid view
  static Widget optimizedGridView({
    required int itemCount,
    required Widget Function(BuildContext, int) itemBuilder,
    required SliverGridDelegate gridDelegate,
    ScrollController? controller,
    bool shrinkWrap = false,
    EdgeInsetsGeometry? padding,
  }) {
    return GridView.builder(
      controller: controller,
      shrinkWrap: shrinkWrap,
      padding: padding,
      itemCount: itemCount,
      itemBuilder: itemBuilder,
      gridDelegate: gridDelegate,
      cacheExtent: 500,
      addAutomaticKeepAlives: false,
      addRepaintBoundaries: true,
    );
  }
}

/// Repaint boundary wrapper for expensive widgets
class OptimizedWidget extends StatelessWidget {
  final Widget child;

  const OptimizedWidget({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: child,
    );
  }
}

/// Lazy loading wrapper for images
class LazyImage extends StatefulWidget {
  final String imageUrl;
  final BoxFit fit;
  final Widget? placeholder;
  final double? width;
  final double? height;

  const LazyImage({
    Key? key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.width,
    this.height,
  }) : super(key: key);

  @override
  State<LazyImage> createState() => _LazyImageState();
}

class _LazyImageState extends State<LazyImage> {
  bool _isVisible = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: Key(widget.imageUrl),
      onVisibilityChanged: (visibilityInfo) {
        if (visibilityInfo.visibleFraction > 0.1 && !_isVisible) {
          setState(() {
            _isVisible = true;
          });
        }
      },
      child: _isVisible
          ? ImageCacheService.cachedImage(
              imageUrl: widget.imageUrl,
              fit: widget.fit,
              width: widget.width,
              height: widget.height,
              placeholder: widget.placeholder,
            )
          : widget.placeholder ??
              Container(
                width: widget.width,
                height: widget.height,
                color: Colors.grey[200],
              ),
    );
  }
}

/// Visibility detector (simplified version - use visibility_detector package for production)
/// Add to pubspec.yaml: visibility_detector: ^0.4.0
/// Then replace this with: import 'package:visibility_detector/visibility_detector.dart';
class VisibilityDetector extends StatefulWidget {
  final Key key;
  final Widget child;
  final Function(VisibilityInfo) onVisibilityChanged;

  const VisibilityDetector({
    required this.key,
    required this.child,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  void _checkVisibility() {
    final renderObject = context.findRenderObject();
    if (renderObject != null && renderObject.attached) {
      final viewport = RenderAbstractViewport.of(renderObject);
      if (viewport != null) {
        final revealOffset = viewport.getRevealOffset(renderObject);
        final visibleFraction = revealOffset.clamp(0.0, 1.0);
        widget.onVisibilityChanged(VisibilityInfo(
          visibleFraction: visibleFraction,
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

class VisibilityInfo {
  final double visibleFraction;

  VisibilityInfo({required this.visibleFraction});
}

/// Debouncer for search and other input
class Debouncer {
  final Duration delay;
  Timer? _timer;

  Debouncer({this.delay = const Duration(milliseconds: 500)});

  void call(VoidCallback callback) {
    _timer?.cancel();
    _timer = Timer(delay, callback);
  }

  void dispose() {
    _timer?.cancel();
  }
}

/// Throttle for scroll events
class Throttler {
  final Duration delay;
  DateTime? _lastRun;

  Throttler({this.delay = const Duration(milliseconds: 100)});

  bool shouldRun() {
    final now = DateTime.now();
    if (_lastRun == null || now.difference(_lastRun!) >= delay) {
      _lastRun = now;
      return true;
    }
    return false;
  }
}

import 'dart:async';
import 'image_cache_service.dart';

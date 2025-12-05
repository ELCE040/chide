import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:cached_video_player/cached_video_player.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Optimized video player service with caching, preloading, and performance enhancements
class OptimizedVideoPlayerService {
  static final OptimizedVideoPlayerService _instance = OptimizedVideoPlayerService._internal();
  factory OptimizedVideoPlayerService() => _instance;
  OptimizedVideoPlayerService._internal();

  // Cache manager for video files
  static final CacheManager _cacheManager = CacheManager(
    Config(
      'video_cache',
      stalePeriod: const Duration(days: 30),
      maxNrOfCacheObjects: 100,
      repo: JsonCacheInfoRepository(databaseName: 'video_cache.db'),
    ),
  );

  // Active players map
  final Map<String, VideoPlayerController> _activePlayers = {};
  final Map<String, CachedVideoPlayerController> _cachedPlayers = {};
  
  // Preload queue
  final List<String> _preloadQueue = [];
  bool _isPreloading = false;

  /// Initialize video player with optimizations
  Future<VideoPlayerController> initializePlayer({
    required String videoUrl,
    bool useCache = true,
    bool autoPlay = false,
    bool looping = false,
    double? aspectRatio,
  }) async {
    // Check if player already exists
    if (_activePlayers.containsKey(videoUrl)) {
      return _activePlayers[videoUrl]!;
    }

    VideoPlayerController controller;

    if (useCache) {
      // Use cached video player for better performance
      controller = CachedVideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        cacheManager: _cacheManager,
        httpHeaders: {
          'Connection': 'keep-alive',
          'Cache-Control': 'max-age=31536000',
        },
      );
    } else {
      controller = VideoPlayerController.networkUrl(
        Uri.parse(videoUrl),
        httpHeaders: {
          'Connection': 'keep-alive',
          'Cache-Control': 'max-age=31536000',
        },
      );
    }

    // Set video player options
    await controller.initialize();
    
    if (looping) {
      controller.setLooping(true);
    }

    if (autoPlay) {
      await controller.play();
    }

    // Keep screen awake during playback
    if (autoPlay) {
      await WakelockPlus.enable();
    }

    _activePlayers[videoUrl] = controller;

    // Listen for completion to release wakelock
    controller.addListener(() {
      if (!controller.value.isPlaying && controller.value.position == controller.value.duration) {
        WakelockPlus.disable();
      }
    });

    return controller;
  }

  /// Preload video for smooth playback
  Future<void> preloadVideo(String videoUrl) async {
    if (_preloadQueue.contains(videoUrl) || _activePlayers.containsKey(videoUrl)) {
      return;
    }

    _preloadQueue.add(videoUrl);

    if (_isPreloading) {
      return;
    }

    _isPreloading = true;

    try {
      // Preload video into cache
      await _cacheManager.getSingleFile(videoUrl);
      
      // Initialize player but don't play
      final controller = await initializePlayer(
        videoUrl: videoUrl,
        useCache: true,
        autoPlay: false,
      );
      
      // Pre-buffer first few seconds
      await controller.setVolume(0);
      await controller.play();
      await Future.delayed(const Duration(seconds: 2));
      await controller.pause();
      await controller.setVolume(1);
    } catch (e) {
      debugPrint('Error preloading video: $e');
    } finally {
      _preloadQueue.remove(videoUrl);
      _isPreloading = false;
    }
  }

  /// Preload multiple videos
  Future<void> preloadVideos(List<String> videoUrls) async {
    for (final url in videoUrls) {
      unawaited(preloadVideo(url));
    }
  }

  /// Dispose player and free resources
  Future<void> disposePlayer(String videoUrl) async {
    final controller = _activePlayers.remove(videoUrl);
    if (controller != null) {
      await controller.dispose();
    }

    final cachedController = _cachedPlayers.remove(videoUrl);
    if (cachedController != null) {
      await cachedController.dispose();
    }

    await WakelockPlus.disable();
  }

  /// Dispose all players
  Future<void> disposeAll() async {
    for (final controller in _activePlayers.values) {
      await controller.dispose();
    }
    _activePlayers.clear();
    _cachedPlayers.clear();
    await WakelockPlus.disable();
  }

  /// Get cached video file if available
  Future<String?> getCachedVideoPath(String videoUrl) async {
    try {
      final file = await _cacheManager.getSingleFile(videoUrl);
      return file.path;
    } catch (e) {
      return null;
    }
  }

  /// Clear video cache
  Future<void> clearCache() async {
    await _cacheManager.emptyCache();
  }

  /// Get cache size
  Future<int> getCacheSize() async {
    return await _cacheManager.getTotalSize();
  }
}

/// Optimized video player widget with modern UI
class OptimizedVideoPlayer extends StatefulWidget {
  final String videoUrl;
  final bool autoPlay;
  final bool showControls;
  final bool looping;
  final double? aspectRatio;
  final Widget? placeholder;
  final Function(VideoPlayerController)? onInitialized;

  const OptimizedVideoPlayer({
    Key? key,
    required this.videoUrl,
    this.autoPlay = false,
    this.showControls = true,
    this.looping = false,
    this.aspectRatio,
    this.placeholder,
    this.onInitialized,
  }) : super(key: key);

  @override
  State<OptimizedVideoPlayer> createState() => _OptimizedVideoPlayerState();
}

class _OptimizedVideoPlayerState extends State<OptimizedVideoPlayer> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      final service = OptimizedVideoPlayerService();
      _controller = await service.initializePlayer(
        videoUrl: widget.videoUrl,
        useCache: true,
        autoPlay: widget.autoPlay,
        looping: widget.looping,
        aspectRatio: widget.aspectRatio,
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _isLoading = false;
        });

        widget.onInitialized?.call(_controller!);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return widget.placeholder ?? 
        Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(
              color: Colors.white,
            ),
          ),
        );
    }

    if (_hasError || !_isInitialized || _controller == null) {
      return widget.placeholder ??
        Container(
          color: Colors.black,
          child: const Center(
            child: Icon(Icons.error_outline, color: Colors.white),
          ),
        );
    }

    return AspectRatio(
      aspectRatio: widget.aspectRatio ?? _controller!.value.aspectRatio,
      child: Stack(
        alignment: Alignment.center,
        children: [
          VideoPlayer(_controller!),
          if (widget.showControls)
            _ModernVideoControls(controller: _controller!),
        ],
      ),
    );
  }
}

/// Modern video controls with Material Design 3
class _ModernVideoControls extends StatefulWidget {
  final VideoPlayerController controller;

  const _ModernVideoControls({required this.controller});

  @override
  State<_ModernVideoControls> createState() => _ModernVideoControlsState();
}

class _ModernVideoControlsState extends State<_ModernVideoControls> {
  bool _showControls = false;
  Timer? _hideControlsTimer;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_updateState);
  }

  @override
  void dispose() {
    _hideControlsTimer?.cancel();
    widget.controller.removeListener(_updateState);
    super.dispose();
  }

  void _updateState() {
    if (mounted) setState(() {});
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
    _resetHideTimer();
  }

  void _resetHideTimer() {
    _hideControlsTimer?.cancel();
    if (_showControls) {
      _hideControlsTimer = Timer(const Duration(seconds: 3), () {
        if (mounted) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return hours == '00' ? '$minutes:$seconds' : '$hours:$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return GestureDetector(
      onTap: _toggleControls,
      child: AnimatedOpacity(
        opacity: _showControls ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.7),
                Colors.transparent,
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Play/Pause button
              Center(
                child: IconButton(
                  icon: Icon(
                    widget.controller.value.isPlaying
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_filled,
                    size: 64,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    if (widget.controller.value.isPlaying) {
                      widget.controller.pause();
                    } else {
                      widget.controller.play();
                    }
                  },
                ),
              ),
              // Bottom controls
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Progress bar
                      VideoProgressIndicator(
                        widget.controller,
                        allowScrubbing: true,
                        colors: VideoProgressColors(
                          playedColor: theme.colorScheme.primary,
                          bufferedColor: theme.colorScheme.primary.withOpacity(0.3),
                          backgroundColor: Colors.white.withOpacity(0.2),
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Time and fullscreen
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_formatDuration(widget.controller.value.position)} / ${_formatDuration(widget.controller.value.duration)}',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.fullscreen, color: Colors.white),
                            onPressed: () {
                              // Implement fullscreen
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper function for unawaited futures
void unawaited(Future<void> future) {
  // Intentionally empty - used to suppress warnings
}

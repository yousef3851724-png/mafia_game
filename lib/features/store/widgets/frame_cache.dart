import 'package:flutter/material.dart';

class FrameImageCache {
  static final Map<String, ImageProvider> _cache = {};

  static ImageProvider getFrameImage(String frameId) {
    return _cache.putIfAbsent(
      frameId,
      () => AssetImage('assets/frames/frame_$frameId.svg'),
    );
  }

  static void preloadFrames(BuildContext context, List<String> frameIds) {
    for (final id in frameIds) {
      precacheImage(getFrameImage(id), context);
    }
  }

  static void clearCache() {
    _cache.clear();
    imageCache.clear();
  }
}

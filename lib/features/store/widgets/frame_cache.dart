import 'package:flutter/material.dart';

class FrameImageCache {
  static final Map<String, ImageProvider> _cache = {};

  static ImageProvider getFrameImage(String frameId) {
    if (_cache.containsKey(frameId)) {
      return _cache[frameId]!;
    }

    final provider = AssetImage('assets/frames/frame_$frameId.svg');
    _cache[frameId] = provider;
    return provider;
  }

  static void preloadFrames(List<String> frameIds) {
    for (final id in frameIds) {
      precacheImage(getFrameImage(id), null);
    }
  }

  static void clearCache() {
    _cache.clear();
    imageCache.clear();
  }
}

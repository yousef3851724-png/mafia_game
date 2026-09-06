import 'package:flutter/material.dart';
import '../../../../core/constants/frame_catalog.dart';
import '../../../../core/widgets/avatar_frame_widget.dart';
import '../../../../core/widgets/frames/animated_avatar_frame.dart';

class FrameShowcaseScreen extends StatefulWidget {
  const FrameShowcaseScreen({super.key});

  @override
  State<FrameShowcaseScreen> createState() => _FrameShowcaseScreenState();
}

class _FrameShowcaseScreenState extends State<FrameShowcaseScreen> {
  FrameType _selected = FrameType.fire;
  bool _simulateSpeaking = true;
  bool _simulateAlive = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121216),
      appBar: AppBar(
        title: const Text('ویترین فریم‌های رادیکال'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          const SizedBox(height: 24),
          Center(
            child: AnimatedAvatarFrame(
              size: 110,
              frameType: _selected,
              fallbackInitial: 'MR',
              isSpeaking: _simulateSpeaking,
              isAlive: _simulateAlive,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            FrameCatalog.frames[_selected]?.titleFa ?? '',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              FrameCatalog.frames[_selected]?.description ?? '',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            ),
          ),
          const Divider(color: Colors.white12, height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              FilterChip(
                label: const Text('شبیه‌سازی صحبت 🎙️'),
                selected: _simulateSpeaking,
                onSelected: (v) => setState(() => _simulateSpeaking = v),
              ),
              const SizedBox(width: 12),
              FilterChip(
                label: const Text('زنده / مرده 💀'),
                selected: _simulateAlive,
                onSelected: (v) => setState(() => _simulateAlive = v),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: FrameType.values.length,
              itemBuilder: (context, index) {
                final frame = FrameType.values[index];
                final isCurrent = _selected == frame;
                final meta = FrameCatalog.frames[frame];
                return GestureDetector(
                  onTap: () => setState(() => _selected = frame),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isCurrent ? const Color(0xFF282836) : const Color(0xFF1B1B22),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isCurrent ? Colors.amber : Colors.white10,
                        width: isCurrent ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedAvatarFrame(
                          size: 46,
                          frameType: frame,
                          fallbackInitial: meta?.titleFa[0] ?? '?',
                          isAlive: true,
                          isSpeaking: false,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          meta?.titleFa ?? '',
                          style: TextStyle(
                            color: isCurrent ? Colors.amber : Colors.white70,
                            fontSize: 11,
                            fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

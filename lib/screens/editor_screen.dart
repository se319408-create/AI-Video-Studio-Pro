import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'export_screen.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({super.key});

  @override
  State<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends State<EditorScreen> {
  String? _videoPath;
  VideoPlayerController? _controller;

  Future<void> _pickVideo() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    final path = result?.files.single.path;
    if (path == null) return;
    final controller = VideoPlayerController.file(File(path));
    await controller.initialize();
    await _controller?.dispose();
    if (!mounted) {
      await controller.dispose();
      return;
    }
    setState(() {
      _videoPath = path;
      _controller = controller;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    return Scaffold(
      appBar: AppBar(title: const Text('Video editor')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AspectRatio(
            aspectRatio: controller?.value.aspectRatio ?? 16 / 9,
            child: ColoredBox(
              color: const Color(0xFF202723),
              child: controller == null
                  ? const Center(child: Icon(Icons.movie_outlined, size: 48, color: Color(0xFF8A968F)))
                  : GestureDetector(
                      onTap: () => setState(() => controller.value.isPlaying ? controller.pause() : controller.play()),
                      child: Stack(fit: StackFit.expand, alignment: Alignment.center, children: [
                        VideoPlayer(controller),
                        if (!controller.value.isPlaying) const Icon(Icons.play_circle_outline, size: 52),
                      ]),
                    ),
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: _pickVideo, icon: const Icon(Icons.video_library_outlined), label: Text(_videoPath == null ? 'Choose video' : 'Replace video')),
          if (_videoPath != null) ...[
            const SizedBox(height: 18),
            Text(_videoPath!.split('/').last, maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 12),
            const Text('Timeline', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 9),
            LinearProgressIndicator(value: controller!.value.duration.inMilliseconds == 0 ? 0 : controller.value.position.inMilliseconds / controller.value.duration.inMilliseconds),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => ExportScreen(inputPath: _videoPath))),
              icon: const Icon(Icons.ios_share),
              label: const Text('Continue to export'),
            ),
          ],
        ],
      ),
    );
  }
}
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/ffmpeg_service.dart';
import '../services/storage_service.dart';

class ResolutionConverterScreen extends StatefulWidget {
  const ResolutionConverterScreen({super.key});

  @override
  State<ResolutionConverterScreen> createState() => _ResolutionConverterScreenState();
}

class _ResolutionConverterScreenState extends State<ResolutionConverterScreen> {
  static const _sizes = {'Original': null, '1080p': 1080, '720p': 720, '480p': 480};
  String? _inputPath;
  int? _height;
  bool _busy = false;
  String? _message;

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.video);
    if (result?.files.single.path case final path?) setState(() => _inputPath = path);
  }

  Future<void> _convert() async {
    final input = _inputPath;
    if (input == null || _busy) return;
    setState(() { _busy = true; _message = null; });
    try {
      final output = await StorageService.createOutputPath('resize', 'mp4');
      await FFmpegService.resizeVideo(inputPath: input, outputPath: output, height: _height);
      await StorageService.saveToGallery(output, isVideo: true);
      if (mounted) setState(() => _message = 'Saved to Movies/AI Video Studio Pro');
    } catch (error) {
      if (mounted) setState(() => _message = 'Conversion failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resolution converter')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const _OfflineBadge(),
        const SizedBox(height: 22),
        OutlinedButton.icon(onPressed: _busy ? null : _pick, icon: const Icon(Icons.video_file_outlined), label: Text(_inputPath == null ? 'Choose a video' : File(_inputPath!).uri.pathSegments.last)),
        const SizedBox(height: 20),
        DropdownButtonFormField<int?>(
          value: _height,
          decoration: const InputDecoration(labelText: 'Output resolution', border: OutlineInputBorder()),
          items: _sizes.entries.map((entry) => DropdownMenuItem<int?>(value: entry.value, child: Text(entry.key))).toList(),
          onChanged: _busy ? null : (value) => setState(() => _height = value),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: _inputPath == null || _busy ? null : _convert, icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.transform), label: Text(_busy ? 'Converting...' : 'Convert and save')),
        if (_message != null) ...[const SizedBox(height: 16), Text(_message!)],
      ]),
    );
  }
}

class _OfflineBadge extends StatelessWidget {
  const _OfflineBadge();

  @override
  Widget build(BuildContext context) => const Chip(label: Text('Offline Mode'), avatar: Icon(Icons.wifi_off, color: Color(0xFF50D890), size: 18));
}
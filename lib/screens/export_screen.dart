import 'dart:io';

import 'package:flutter/material.dart';

import '../services/ffmpeg_service.dart';
import '../services/storage_service.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key, this.inputPath});

  final String? inputPath;

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs = TabController(length: 2, vsync: this);
  String? _inputPath;
  bool _busy = false;
  String? _message;
  double _durationMinutes = 1;

  @override
  void initState() {
    super.initState();
    _inputPath = widget.inputPath;
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  int _estimateBytes({required bool saver}) {
    final videoBitsPerSecond = saver ? 64000 : 8000000;
    final audioBitsPerSecond = saver ? 64000 : 128000;
    return (((videoBitsPerSecond + audioBitsPerSecond) * 60 * _durationMinutes) / 8).round();
  }

  String _formatBytes(int bytes) {
    if (bytes >= 1000000000) return '${(bytes / 1000000000).toStringAsFixed(2)} GB';
    if (bytes >= 1000000) return '${(bytes / 1000000).toStringAsFixed(1)} MB';
    return '${(bytes / 1000).toStringAsFixed(0)} KB';
  }

  Future<void> _export() async {
    final input = _inputPath;
    if (input == null || _busy) return;
    setState(() { _busy = true; _message = null; });
    try {
      final saver = _tabs.index == 1;
      final output = await StorageService.createOutputPath(saver ? 'export_h265' : 'export_h264', 'mp4');
      await FFmpegService.exportVideo(inputPath: input, outputPath: output, saver: saver);
      await StorageService.saveToGallery(output, isVideo: true);
      if (mounted) setState(() => _message = 'Export complete: ${File(output).uri.pathSegments.last}');
    } catch (error) {
      if (mounted) setState(() => _message = 'Export failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Smart export')),
      body: Column(children: [
        TabBar(controller: _tabs, tabs: const [Tab(text: 'YouTube Mode'), Tab(text: 'Super Saver')]),
        Expanded(child: TabBarView(controller: _tabs, children: [
          _ModePanel(title: 'YouTube Mode', codec: 'H.264 / libx264', command: '-c:v libx264 -crf 23 -preset medium -c:a aac -b:a 128k', estimatedSize: _formatBytes(_estimateBytes(saver: false))),
          _ModePanel(title: 'Super Saver Mode', codec: 'H.265 / libx265', command: '-c:v libx265 -crf 28 -preset fast -c:a aac -b:a 64k', estimatedSize: _formatBytes(_estimateBytes(saver: true))),
        ])),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Expanded(child: _SizeEstimate(label: 'H.264 · YouTube', size: _formatBytes(_estimateBytes(saver: false)))),
              const SizedBox(width: 16),
              Expanded(child: _SizeEstimate(label: 'H.265 · Saver', size: _formatBytes(_estimateBytes(saver: true)))),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              const Text('Duration'),
              Expanded(child: Slider(value: _durationMinutes, min: 0.5, max: 30, divisions: 59, label: '${_durationMinutes.toStringAsFixed(1)} min', onChanged: (value) => setState(() => _durationMinutes = value))),
              Text('${_durationMinutes.toStringAsFixed(1)}m'),
            ]),
            if (_inputPath == null) const Padding(padding: EdgeInsets.only(bottom: 10), child: Text('Open a video in the editor to export it.', textAlign: TextAlign.center)),
            FilledButton.icon(onPressed: _inputPath == null || _busy ? null : _export, icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.file_upload_outlined), label: Text(_busy ? 'Exporting...' : 'Export to device')),
            if (_message != null) Padding(padding: const EdgeInsets.only(top: 10), child: Text(_message!, textAlign: TextAlign.center)),
          ]),
        ),
      ]),
    );
  }
}

class _ModePanel extends StatelessWidget {
  const _ModePanel({required this.title, required this.codec, required this.command, required this.estimatedSize});

  final String title;
  final String codec;
  final String command;
  final String estimatedSize;

  @override
  Widget build(BuildContext context) {
    return ListView(padding: const EdgeInsets.all(20), children: [
      const Chip(label: Text('Offline Mode'), avatar: Icon(Icons.wifi_off, color: Color(0xFF50D890), size: 18)),
      const SizedBox(height: 12),
      Text(title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Text(codec, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
      const SizedBox(height: 24),
      Text(estimatedSize, style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700)),
      const Text('Estimated size per selected duration'),
      const SizedBox(height: 20),
      const Text('Encoding settings', style: TextStyle(fontWeight: FontWeight.w600)),
      const SizedBox(height: 8),
      SelectableText(command, style: const TextStyle(fontFamily: 'monospace', color: Color(0xFF50D890))),
    ]);
  }
}

class _SizeEstimate extends StatelessWidget {
  const _SizeEstimate({required this.label, required this.size});

  final String label;
  final String size;

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontSize: 12)),
      Text(size, style: const TextStyle(fontWeight: FontWeight.w700)),
    ]);
  }
}
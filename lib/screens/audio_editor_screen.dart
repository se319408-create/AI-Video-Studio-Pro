import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import '../services/ffmpeg_service.dart';
import '../services/storage_service.dart';

class AudioEditorScreen extends StatefulWidget {
  const AudioEditorScreen({super.key});

  @override
  State<AudioEditorScreen> createState() => _AudioEditorScreenState();
}

class _AudioEditorScreenState extends State<AudioEditorScreen> {
  String? _inputPath;
  String _format = 'mp3';
  bool _busy = false;
  String? _message;

  Future<void> _pick() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result?.files.single.path case final path?) setState(() => _inputPath = path);
  }

  Future<void> _convert() async {
    final input = _inputPath;
    if (input == null || _busy) return;
    setState(() { _busy = true; _message = null; });
    try {
      final output = await StorageService.createOutputPath('audio', _format);
      await FFmpegService.convertAudio(inputPath: input, outputPath: output, format: _format);
      await StorageService.saveToGallery(output, isVideo: false);
      if (mounted) setState(() => _message = 'Saved to Music/AI Video Studio Pro');
    } catch (error) {
      if (mounted) setState(() => _message = 'Audio export failed: $error');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Audio editor')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Chip(label: Text('Offline Mode'), avatar: Icon(Icons.wifi_off, color: Color(0xFF50D890), size: 18)),
        const SizedBox(height: 20),
        OutlinedButton.icon(onPressed: _busy ? null : _pick, icon: const Icon(Icons.audio_file_outlined), label: Text(_inputPath == null ? 'Choose audio' : File(_inputPath!).uri.pathSegments.last)),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(
          value: _format,
          decoration: const InputDecoration(labelText: 'Output format', border: OutlineInputBorder()),
          items: const [DropdownMenuItem(value: 'mp3', child: Text('MP3')), DropdownMenuItem(value: 'm4a', child: Text('AAC / M4A')), DropdownMenuItem(value: 'wav', child: Text('WAV'))],
          onChanged: _busy ? null : (value) => setState(() => _format = value ?? 'mp3'),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(onPressed: _inputPath == null || _busy ? null : _convert, icon: _busy ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.music_note), label: Text(_busy ? 'Exporting...' : 'Convert and save')),
        if (_message != null) ...[const SizedBox(height: 16), Text(_message!)],
      ]),
    );
  }
}
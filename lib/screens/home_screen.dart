import 'package:flutter/material.dart';

import 'audio_editor_screen.dart';
import 'editor_screen.dart';
import 'export_screen.dart';
import 'resolution_converter_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onSelectTab});

  final ValueChanged<int> onSelectTab;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Video Studio Pro', style: TextStyle(fontWeight: FontWeight.w700)),
        actions: [IconButton(tooltip: 'Settings', onPressed: () => onSelectTab(3), icon: const Icon(Icons.tune))],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          Row(children: [
            const _StatusBadge(label: 'Offline Mode', color: Color(0xFF50D890)),
            const SizedBox(width: 8),
            const _StatusBadge(label: 'AI: Online Required', color: Color(0xFF5AA9FF)),
          ]),
          const SizedBox(height: 28),
          const Text('Make something', style: TextStyle(fontSize: 27, fontWeight: FontWeight.w700)),
          const SizedBox(height: 7),
          Text('Your media stays on this device unless you choose an online AI tool.', style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(58), alignment: Alignment.centerLeft, padding: const EdgeInsets.symmetric(horizontal: 18)),
            onPressed: () => _open(context, const EditorScreen()),
            icon: const Icon(Icons.add),
            label: const Text('New video project', style: TextStyle(fontSize: 16)),
          ),
          const SizedBox(height: 26),
          const Text('TOOLS', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, letterSpacing: 1.2, color: Color(0xFFA6B0AA))),
          const SizedBox(height: 12),
          _ToolRow(icon: Icons.aspect_ratio, title: 'Resolution converter', subtitle: 'Resize and re-encode video', onTap: () => _open(context, const ResolutionConverterScreen())),
          _ToolRow(icon: Icons.graphic_eq, title: 'Audio editor', subtitle: 'Convert audio and extract tracks', onTap: () => _open(context, const AudioEditorScreen())),
          _ToolRow(icon: Icons.file_upload_outlined, title: 'Smart export', subtitle: 'Compare H.264 and H.265 sizes', onTap: () => _open(context, const ExportScreen())),
          const SizedBox(height: 20),
          OutlinedButton.icon(onPressed: () => onSelectTab(1), icon: const Icon(Icons.folder_open), label: const Text('Browse my projects')),
        ],
      ),
    );
  }

  static void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => page));
  }
}

class _ToolRow extends StatelessWidget {
  const _ToolRow({required this.icon, required this.title, required this.subtitle, required this.onTap});

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 5),
      leading: Icon(icon, color: const Color(0xFF35D0A0)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}
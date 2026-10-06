import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

import 'screens/audio_editor_screen.dart';
import 'screens/home_screen.dart';
import 'screens/my_projects_screen.dart';
import 'screens/resolution_converter_screen.dart';
import 'screens/settings_screen.dart';
import 'services/gemini_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AIVideoStudioApp());
}

class AIVideoStudioApp extends StatelessWidget {
  const AIVideoStudioApp({super.key});

  @override
  Widget build(BuildContext context) {
    const accent = Color(0xFF35D0A0);
    return MaterialApp(
      title: 'AI Video Studio Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF101311),
        colorScheme: ColorScheme.fromSeed(
          seedColor: accent,
          brightness: Brightness.dark,
          surface: const Color(0xFF191E1B),
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF101311),
          surfaceTintColor: Colors.transparent,
        ),
        cardTheme: CardTheme(
          color: const Color(0xFF191E1B),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
      home: const StudioShell(),
    );
  }
}

class StudioShell extends StatefulWidget {
  const StudioShell({super.key});

  @override
  State<StudioShell> createState() => _StudioShellState();
}

class _StudioShellState extends State<StudioShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomeScreen(onSelectTab: (index) => setState(() => _selectedIndex = index)),
      const MyProjectsScreen(),
      const StudioToolsScreen(),
      const SettingsScreen(),
    ];
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.folder_outlined), selectedIcon: Icon(Icons.folder), label: 'Projects'),
          NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'AI Tools'),
          NavigationDestination(icon: Icon(Icons.tune_outlined), selectedIcon: Icon(Icons.tune), label: 'Settings'),
        ],
      ),
    );
  }
}

class StudioToolsScreen extends StatelessWidget {
  const StudioToolsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI Tools')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const _ModeBadge(label: 'Online Required', color: Color(0xFF5AA9FF)),
          const SizedBox(height: 18),
          const Text('Analyze your media', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          const Text('Gemini features use an online API key and are limited to text and image content analysis.'),
          const SizedBox(height: 20),
          const _GeminiAnalysisPanel(),
          const SizedBox(height: 24),
          const Text('Coming soon', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          for (final feature in ['Change Dress', 'Hairstyle', 'Deblur', 'Watermark Removal'])
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.lock_outline),
              title: Text(feature),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => showDialog<void>(
                context: context,
                builder: (context) => AlertDialog(
                  title: Text(feature),
                  content: const Text('This feature requires a paid API key (Imagen 3 - not available in free tier). Coming soon.'),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _GeminiAnalysisPanel extends StatefulWidget {
  const _GeminiAnalysisPanel();

  @override
  State<_GeminiAnalysisPanel> createState() => _GeminiAnalysisPanelState();
}

class _GeminiAnalysisPanelState extends State<_GeminiAnalysisPanel> {
  final _textController = TextEditingController();
  bool _busy = false;
  String? _analysis;

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  Future<void> _run(Future<String> Function() analyze) async {
    setState(() {
      _busy = true;
      _analysis = null;
    });
    try {
      final result = await analyze();
      if (mounted) setState(() => _analysis = result);
    } catch (error) {
      if (mounted) setState(() => _analysis = error.toString());
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _analyzeImage() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image, withData: true);
    final file = result?.files.single;
    final bytes = file?.bytes;
    if (file == null || bytes == null || bytes.isEmpty) return;
    final mimeType = switch (file.extension?.toLowerCase()) {
      'png' => 'image/png',
      'webp' => 'image/webp',
      _ => 'image/jpeg',
    };
    await _run(() => GeminiService.analyzeImage(
          prompt: 'Describe the visible content of this image.',
          mimeType: mimeType,
          bytes: bytes,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TextField(
        controller: _textController,
        minLines: 2,
        maxLines: 5,
        decoration: const InputDecoration(labelText: 'Text to analyze', border: OutlineInputBorder()),
      ),
      const SizedBox(height: 10),
      FilledButton.icon(
        onPressed: _busy ? null : () => _run(() => GeminiService.analyzeText(_textController.text)),
        icon: const Icon(Icons.notes),
        label: const Text('Analyze text'),
      ),
      const SizedBox(height: 8),
      OutlinedButton.icon(
        onPressed: _busy ? null : _analyzeImage,
        icon: const Icon(Icons.image_search_outlined),
        label: const Text('Choose image to analyze'),
      ),
      if (_busy) const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator())),
      if (_analysis != null) Padding(padding: const EdgeInsets.only(top: 12), child: SelectableText(_analysis!)),
    ]);
  }
}

class _ModeBadge extends StatelessWidget {
  const _ModeBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: DecoratedBox(
        decoration: BoxDecoration(color: color.withOpacity(0.14), borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          child: Text(label, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController _apiKeyController = TextEditingController();
  bool _showKey = false;

  @override
  void initState() {
    super.initState();
    _loadKey();
  }

  Future<void> _loadKey() async {
    final preferences = await SharedPreferences.getInstance();
    if (mounted) _apiKeyController.text = preferences.getString('gemini_api_key') ?? '';
  }

  Future<void> _saveKey() async {
    final preferences = await SharedPreferences.getInstance();
    final key = _apiKeyController.text.trim();
    if (key.isEmpty) {
      await preferences.remove('gemini_api_key');
    } else {
      await preferences.setString('gemini_api_key', key);
    }
    if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('AI settings saved')));
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(padding: const EdgeInsets.all(20), children: [
        const Text('AI analysis', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const Text('Gemini is used only for text and image content analysis. Your key is stored in local app preferences.'),
        const SizedBox(height: 16),
        TextField(
          controller: _apiKeyController,
          obscureText: !_showKey,
          autocorrect: false,
          decoration: InputDecoration(
            labelText: 'Gemini API key',
            border: const OutlineInputBorder(),
            suffixIcon: IconButton(tooltip: _showKey ? 'Hide key' : 'Show key', onPressed: () => setState(() => _showKey = !_showKey), icon: Icon(_showKey ? Icons.visibility_off : Icons.visibility)),
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(onPressed: _saveKey, icon: const Icon(Icons.save_outlined), label: const Text('Save AI settings')),
        const SizedBox(height: 30),
        const Text('Storage', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 6),
        const ListTile(contentPadding: EdgeInsets.zero, leading: Icon(Icons.folder_outlined), title: Text('Project outputs'), subtitle: Text('App storage and Movies/Music on this device')),
        const SizedBox(height: 20),
        const Text('AI Video Studio Pro · 1.0.0', style: TextStyle(color: Color(0xFF9BA69F))),
      ]),
    );
  }
}
import 'dart:io';

import 'package:flutter/material.dart';

import '../services/storage_service.dart';
import 'editor_screen.dart';

class MyProjectsScreen extends StatefulWidget {
  const MyProjectsScreen({super.key});

  @override
  State<MyProjectsScreen> createState() => _MyProjectsScreenState();
}

class _MyProjectsScreenState extends State<MyProjectsScreen> {
  late Future<List<FileSystemEntity>> _projects = StorageService.listProjects();

  Future<void> _refresh() async {
    setState(() => _projects = StorageService.listProjects());
    await _projects;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My projects')),
      body: FutureBuilder<List<FileSystemEntity>>(
        future: _projects,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final files = snapshot.data ?? const <FileSystemEntity>[];
          if (files.isEmpty) {
            return Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.video_library_outlined, size: 44, color: Color(0xFF87928B)),
              const SizedBox(height: 12),
              const Text('No local projects yet'),
              const SizedBox(height: 16),
              FilledButton.icon(onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const EditorScreen())), icon: const Icon(Icons.add), label: const Text('New project')),
            ]));
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: files.length,
              itemBuilder: (context, index) {
                final file = File(files[index].path);
                final modified = file.lastModifiedSync();
                return ListTile(
                  leading: const Icon(Icons.movie_outlined, color: Color(0xFF35D0A0)),
                  title: Text(file.uri.pathSegments.last, maxLines: 1, overflow: TextOverflow.ellipsis),
                  subtitle: Text('${_size(file.lengthSync())}  ·  ${modified.toLocal()}'),
                  onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => EditorScreen())),
                );
              },
            ),
          );
        },
      ),
    );
  }

  String _size(int bytes) => bytes >= 1000000 ? '${(bytes / 1000000).toStringAsFixed(1)} MB' : '${(bytes / 1000).toStringAsFixed(0)} KB';
}
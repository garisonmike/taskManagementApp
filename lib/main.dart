import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/datasources/local/database_helper.dart';
import 'data/datasources/local/settings_local_data_source.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Management App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
      ),
      home: const PersistenceDemo(),
    );
  }
}

class PersistenceDemo extends StatefulWidget {
  const PersistenceDemo({super.key});

  @override
  State<PersistenceDemo> createState() => _PersistenceDemoState();
}

class _PersistenceDemoState extends State<PersistenceDemo> {
  final _dbHelper = DatabaseHelper.instance;
  late final SettingsLocalDataSource _dataSource;
  String _savedValue = 'No data saved yet';
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _dataSource = SettingsLocalDataSource(_dbHelper);
    _loadSavedData();
  }

  Future<void> _loadSavedData() async {
    final value = await _dataSource.getSetting('demo_key');
    setState(() {
      _savedValue = value ?? 'No data saved yet';
      _isInitialized = true;
    });
  }

  Future<void> _saveData() async {
    final timestamp = DateTime.now().toString();
    await _dataSource.saveSetting('demo_key', timestamp);
    await _loadSavedData();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data saved! Restart app to verify persistence.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Persistence Demo'),
      ),
      body: Center(
        child: _isInitialized
            ? Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.storage, size: 64, color: Colors.brown),
                    const SizedBox(height: 24),
                    const Text(
                      'Offline-First Storage Demo',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Last saved data:',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.brown.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _savedValue,
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _saveData,
                      icon: const Icon(Icons.save),
                      label: const Text('Save Current Time'),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Data persists after app restart',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}

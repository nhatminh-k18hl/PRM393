import 'package:flutter/material.dart';
import 'screens/note_list_screen.dart';

void main() {
  runApp(const LocalJsonStorageApp());
}

class LocalJsonStorageApp extends StatelessWidget {
  const LocalJsonStorageApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab 9 JSON Local Database',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.indigo,
      ),
      home: const NoteListScreen(),
    );
  }
}

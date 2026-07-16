import 'package:flutter/material.dart';
import 'screens/post_list_screen.dart';

void main() {
  runApp(const ApiListApp());
}

class ApiListApp extends StatelessWidget {
  const ApiListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Lab 8 REST API Integration',
      theme: ThemeData(
        useMaterial3: true,
        primarySwatch: Colors.teal,
      ),
      home: const PostListScreen(),
    );
  }
}

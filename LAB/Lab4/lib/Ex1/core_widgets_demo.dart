import 'package:flutter/material.dart';

class CoreWidgetsApp extends StatelessWidget {
  const CoreWidgetsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Exercise 1: Core Widgets'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 1. Text Component
                const Text(
                  'Hệ thống hiển thị Core Widgets',
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.blueAccent),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // 2. Icon Component
                const Icon(Icons.stars, size: 60, color: Colors.amber),
                const SizedBox(height: 16),

                // 3. Image Component
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500',
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),

                // 4. Card & ListTile Components
                const Card(
                  elevation: 4,
                  child: ListTile(
                    leading:
                        Icon(Icons.workspace_premium, color: Colors.blueAccent),
                    title: Text('Material Design Core UI'),
                    subtitle: Text(
                        'Đã hoàn thành hiển thị Text, Icon, Image, Card và ListTile.'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

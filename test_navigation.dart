// Test script to diagnose navigation crashes
// Run with: flutter run test_navigation.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'lib/providers/church_provider.dart';
import 'lib/screens/agenda_screen.dart';
import 'lib/screens/podcast_list_screen.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ChurchProvider()),
      ],
      child: MaterialApp(
        home: TestNavigationScreen(),
      ),
    ),
  );
}

class TestNavigationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Test Navigation')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Test Agenda Screen'),
            onTap: () {
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AgendaScreen()),
                );
              } catch (e) {
                print('ERROR navigating to Agenda: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
          ),
          ListTile(
            title: Text('Test Podcast Screen'),
            onTap: () {
              try {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => PodcastListScreen()),
                );
              } catch (e) {
                print('ERROR navigating to Podcasts: $e');
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

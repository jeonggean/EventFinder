import 'package:flutter/material.dart';
import 'features/1_event/screens/event_list_screen.dart'; 

void main() {
  runApp(const MyApp());
}
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Event Finder (MVC)',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: EventListScreen(), 
    );
  }
}
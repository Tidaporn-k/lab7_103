import 'package:flutter/material.dart';
import 'screen/student_screen.dart';

void main() {
  runApp(MyApp());
}

// ส่วนของ Stateless widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Student',
      home: StudentScreen(),
    );
  }
}
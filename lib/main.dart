import 'package:flutter/material.dart';
import 'package:lab7_103/screen/student_screen.dart';

void main(){
    runApp(MyApp());
}
 
// ส่วนของ Stateless widget
class MyApp extends StatelessWidget{
    @override
    Widget build(BuildContext context) {
        return MaterialApp(
            title: 'lab7',
            home: StudentScreen()
        );
    }
}
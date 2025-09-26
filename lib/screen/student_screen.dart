import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../model/student.dart';

class StudentScreen extends StatefulWidget {
  static const routeName = '/';
  const StudentScreen({Key? key}) : super(key: key);
  @override
  State<StatefulWidget> createState() {
    return _StudentScreenState();
  }
}

class _StudentScreenState extends State<StudentScreen> {
  // กาํนหดตวัแปรขอ้ มูล students
  late Future<List<Student>> students;
  @override
  void initState() {
    print("initState"); // สาํ หรบั ทดสอบ
    super.initState();
    students = fetchStudents();
  }

  void _refreshData() {
    setState(() {
      print("setState"); // สาํ หรบั ทดสอบ
      students = fetchStudents();
    });
  }

  @override
  Widget build(BuildContext context) {
    print("build"); // สาํ หรบั ทดสอบ
    return Scaffold(
      appBar: AppBar(
        title: Text('Student'),
        actions: [IconButton(onPressed: () {}, icon: Icon(Icons.add))],
      ),
      body: Center(
        child: FutureBuilder<List<Student>>(
          // ชนิดของขอ้ มูล
          future: students, // ขอ้ มูล Future
          builder: (context, snapshot) {
            print("builder"); // สาํหรับทดสอบ
            print(snapshot.connectionState); // สาํ หรบั ทดสอบ
            // กรณีสถานะเป็น waiting ยงัไม่มีขอ้ มูลแสดงตวั loading
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.hasData) {
              // กรณีมีขอ้ มูล
              return Column(
                children: [
                  Container(
                    // สร้างส่วน header ของลิสรายการ
                    padding: const EdgeInsets.all(5.0),
                    decoration: BoxDecoration(
                      color: Colors.teal.withAlpha(100),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Total ${snapshot.data!.length} items',
                        ), // แสดงจาํนวนรายการ
                      ],
                    ),
                  ),
                  Expanded(
                    // ส่วนของลิสรายการ
                    child:
                        snapshot.data!.length >
                            0 // กาํหนดเงืÉอนไขตรงนีÊ
                        ? ListView.separated(
                            // กรณีมีรายการ แสดงปกติ
                            itemCount: snapshot.data!.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                title: Text(snapshot.data![index].studentName),
                                subtitle: Text(
                                  snapshot.data![index].studentCode,
                                ),
                                trailing: Wrap(
                                  children: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: Icon(Icons.edit),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        await showDialog(
                                          context: context,
                                          builder: (BuildContext context) =>
                                              AlertDialog(
                                                title: Text('Confirm Delete'),
                                                content: Expanded(
                                                  child: Text(
                                                    "Do you want to delete: " +
                                                        snapshot
                                                            .data![index]
                                                            .studentCode,
                                                  ),
                                                ),
                                                actions: <Widget>[
                                                  TextButton(
                                                    child: Text('Delete'),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                      backgroundColor:
                                                          Colors.redAccent,
                                                    ),
                                                    onPressed: () async {
                                                      await deleteStudent(
                                                        snapshot.data![index],
                                                      );
                                                      setState(() {
                                                        students =
                                                            fetchStudents();
                                                      });
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                  TextButton(
                                                    child: Text('Close'),
                                                    style: TextButton.styleFrom(
                                                      foregroundColor:
                                                          Colors.white,
                                                      backgroundColor:
                                                          Colors.blueGrey,
                                                    ),
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                    },
                                                  ),
                                                ],
                                              ),
                                        );
                                      },
                                      icon: Icon(Icons.delete),
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder:
                                (BuildContext context, int index) =>
                                    const Divider(),
                          )
                        : const Center(
                            child: Text('No items'),
                          ), // กรณีไม่มีรายการ
                  ),
                ],
              );
            } else if (snapshot.hasError) {
              // กรณี error
              return Text('${snapshot.error}');
            }
            // กรณีสถานะเป็น waiting ยงัไม่มีขอ้ มูลแสดงตวั loading
            return const CircularProgressIndicator();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // ปุ่มทดสอบสาํ หรับดึงขอ้ มูลซÊาํ
        onPressed: _refreshData,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}

// สรัางฟังกช์ นัÉ ดึงขอ้ มูล คืนค่ากลบั มาเป็นขอ้ มูล Future ประเภท List ของ Student
Future<List<Student>> fetchStudents() async {
  // ทาํการดึงขอ้ มูลจาก server ตาม url ทีÉกาํหนด
  final response = await http.get(
    Uri.parse('http://192.168.56.1/API/api/student.php'),
  );
  // เมืÉอมีขอ้ มูลกลบั มา
  if (response.statusCode == 200) {
    // ส่งขอ้ มูลทÉเป็ น ี JSON String data ไปทาํการแปลง เป็นขอ้ มูล List<Student
    // โดยใชค้าํสัÉง compute ทาํงานเบÊืองหลงั เรียกใชฟ้ ังกช์ นชื ัÉ Éอ parsestudents
    // ส่งขอ้ มูล JSON String data ผา่ นตวัแปร response.body
    return compute(parsestudents, response.body);
  } else {
    // กรณี error
    throw Exception('Failed to load Student');
  }
}

Future<int> deleteStudent(Student student) async {
  final response = await http.delete(
    Uri.parse(
      'http://192.168.56.1/API/api/student.php?student_code=${student.studentCode}',
    ),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
  );
  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return response.statusCode;
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to delete student.');
  }
}

// ฟังกช์ นÉัแปลงขอ้ มูล JSON String data เป็ น เป็นขอ้ มูล List<Student>
List<Student> parsestudents(String responseBody) {
  final parsed = jsonDecode(responseBody).cast<Map<String, dynamic>>();
  return parsed.map<Student>((json) => Student.fromJson(json)).toList();
}

import 'package:flutter/material.dart';
import 'package:project/features/controller/prayer%20times%20controller/new%20prayer%20times%20controller/sql_db.dart';

class Testpage extends StatefulWidget {
  const Testpage({super.key});

  @override
  State<Testpage> createState() => _TestpageState();
}

class _TestpageState extends State<Testpage> {
  SqlDb sqldb = SqlDb();

  String data = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Test Page")),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "Test Page",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                sqldb.readdata("SELECT * FROM prayer_times").then((value) {
                  data = value.toString();
                });
                setState(() {});
              },
              child: Text("read data"),
            ),
            SizedBox(height: 20),
            Text(
              data,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w400),
            ),
          ],
        ),
      ),
    );
  }
}

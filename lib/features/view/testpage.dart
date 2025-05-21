import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:project/features/controller/prayer%20times%20controller/get_response_body.dart';
import 'package:project/features/model/sql_db.dart';

class Testpage extends StatefulWidget {
  const Testpage({super.key});

  @override
  State<Testpage> createState() => _TestpageState();
}

class _TestpageState extends State<Testpage> {
  SqlDb sqldb = SqlDb();
  final NewResponseBody rbctrl = Get.find();

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
              onPressed: () async {
                await rbctrl.getCalendarData();
                setState(() {});
              },
              child: Text("get data"),
            ),
            SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                await sqldb.readdata("SELECT * FROM prayer_times").then((
                  value,
                ) {
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

/*
I get the response and every thing seems to be good 
tomorrow I will change the old response with the new response and 
and do what I need to do ;
*/

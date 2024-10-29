import 'package:flutter/material.dart';
import 'package:timetable_app/utils/color_constants.dart';
import 'package:timetable_app/view/add_courses/add_courses.dart';
// import 'package:timetable_app/view/assign_staffs_screen/assign_staffs.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: ColorConstants.blue,
        title: Text(
          "Welcome",
          style: TextStyle(
              color: ColorConstants.mainWhite,
              fontWeight: FontWeight.bold,
              fontSize: 30),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Start creating Timetable now!! ",
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.w700),
              ),
              SizedBox(
                height: 30,
              ),
              Text(
                "Click here",
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              Icon(
                Icons.arrow_downward,
                size: 25,
                color: ColorConstants.mainRed,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => AddCourses(),
                      ));
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    duration: Duration(seconds: 4),
                    backgroundColor: ColorConstants.gold,
                    content: Text(
                      "Start Adding Courses First",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: ColorConstants.mainBlack,
                          fontSize: 20),
                    ),
                  ));
                },
                child: Container(
                  child: Center(
                    child: Text(
                      "Add Course,Subjects,Staffs",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                    ),
                  ),
                  height: 50,
                  width: MediaQuery.sizeOf(context).width * 0.7,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: ColorConstants.mainblue),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

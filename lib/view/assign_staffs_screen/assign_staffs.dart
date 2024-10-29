import 'package:flutter/material.dart';
import 'package:timetable_app/utils/color_constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:timetable_app/view/timetable_screen/timetable_screen.dart';

class AssignStaffs extends StatefulWidget {
  const AssignStaffs({
    super.key,
    required this.courses,
    required this.subjects,
    required this.staffMapping,
  });

  final List<dynamic> courses;
  final Map<dynamic, List<dynamic>>
      subjects; // Key: course name, Value: list of subjects
  final Map<dynamic, List<String>> staffMapping;

  @override
  State<AssignStaffs> createState() => _AssignStaffsState();
}

class _AssignStaffsState extends State<AssignStaffs> {
  int n = 20;
  bool isLimit = false;
  String? course;
  String? subject;
  String? selectedStaff;
  List<dynamic> subjects = [];
  List<String> filteredStaff = []; // To hold staff for the selected course
  bool isCourseLocked = false; // To track if the course is locked

  void _updateSubjectsAndStaff(String selectedCourse) {
    // Update subjects and staff based on selected course
    subjects = widget.subjects[selectedCourse] ?? [];
    filteredStaff = widget.staffMapping[selectedCourse] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    var coursesCollection = FirebaseFirestore.instance.collection("Courses");

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Assign subjects to staffs",
          style: TextStyle(
              color: ColorConstants.mainWhite,
              fontWeight: FontWeight.bold,
              fontSize: 25),
        ),
        leading: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          child: Icon(
            Icons.arrow_back,
            color: ColorConstants.mainWhite,
          ),
        ),
        backgroundColor: ColorConstants.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Course :",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: coursesCollection.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text("No courses available");
                }

                final documents = snapshot.data!.docs;

                return DropdownButton<String>(
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 18,
                    color: ColorConstants.mainBlack,
                  ),
                  dropdownColor: ColorConstants.mainWhite,
                  value: isCourseLocked ? course : null,
                  hint: Text(
                    "Courses",
                    style: TextStyle(
                      color: ColorConstants.mainBlack,
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                    ),
                  ),
                  items: List<DropdownMenuItem<String>>.generate(
                    documents.length,
                    (index) {
                      Map<String, dynamic> data =
                          documents[index].data()! as Map<String, dynamic>;
                      return DropdownMenuItem<String>(
                        value: data['course'],
                        child: Text(data['course']),
                      );
                    },
                  ),
                  onChanged: isCourseLocked
                      ? null
                      : (value) {
                          setState(() {
                            course = value;
                            if (course != null) {
                              _updateSubjectsAndStaff(course!);
                              subject = null; // Reset subject selection
                              selectedStaff = null; // Reset staff selection
                              isCourseLocked = true; // Lock the course
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(SnackBar(
                                      backgroundColor: ColorConstants.gold,
                                      content: Text(
                                        "Now assign subjects to staffs.",
                                        style: TextStyle(
                                            color: ColorConstants.mainBlack,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      )));
                            }
                          });
                        },
                );
              },
            ),
            Text(
              "Select Subjects :",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            DropdownButton<String>(
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: ColorConstants.mainBlack,
              ),
              dropdownColor: ColorConstants.mainWhite,
              value: subject,
              hint: Text(
                "Subjects",
                style: TextStyle(
                  color: ColorConstants.mainBlack,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              items: List<DropdownMenuItem<String>>.generate(
                subjects.length,
                (index) => DropdownMenuItem<String>(
                  value: subjects[index],
                  child: Text(subjects[index]),
                ),
              ),
              onChanged: isLimit
                  ? null
                  : (value) {
                      setState(() {
                        subject = value;
                      });
                    },
            ),
            Text(
              "Select Staff for this subject :",
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 20),
            ),
            DropdownButton<String>(
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: ColorConstants.mainBlack,
              ),
              dropdownColor: ColorConstants.mainWhite,
              value: selectedStaff,
              hint: Text(
                "Staffs",
                style: TextStyle(
                  color: ColorConstants.mainBlack,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              items: List<DropdownMenuItem<String>>.generate(
                filteredStaff.length,
                (index) => DropdownMenuItem<String>(
                  value: filteredStaff[index],
                  child: Text(filteredStaff[index]),
                ),
              ),
              onChanged: isLimit
                  ? null
                  : (value) {
                      setState(() {
                        selectedStaff = value;
                      });
                    },
            ),
            SizedBox(
              height: 50,
            ),
            if (selectedStaff != null)
              Center(
                child: ElevatedButton(
                    onPressed: () async {
                      await FirebaseFirestore.instance
                          .collection("${course}table")
                          .add({
                        "course": course,
                        "subject": subject,
                        "staff": selectedStaff,
                        "time": ""
                      });
                      // Decrease the count of available documents
                      if (n > 0) {
                        n--; // Decrement the limit
                      }
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 5),
                          backgroundColor: ColorConstants.gold,
                          content: Text(
                            "Document saved! You can assign staffs for subjects $n more times for the $course course.",
                            style: TextStyle(
                                color: ColorConstants.mainBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          )));
                      // Check if n has reached its limit
                      if (n == 0) {
                        isLimit = true; // Set the limit flag
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          duration: Duration(seconds: 5),
                          backgroundColor: ColorConstants.gold,
                          content: Text(
                            "You have reached the limit. You can now generate the timetable for $course.Use the Button above",
                            style: TextStyle(
                                color: ColorConstants.mainBlack,
                                fontWeight: FontWeight.bold,
                                fontSize: 18),
                          ),
                        ));

                        setState(() {});
                      }
                    },
                    style: ButtonStyle(
                        backgroundColor:
                            WidgetStatePropertyAll(ColorConstants.maingreen)),
                    child: Text(
                      "Save data",
                      style: TextStyle(
                          fontSize: 18, color: ColorConstants.mainWhite),
                    )),
              ),
            SizedBox(
              height: 20,
            ),
            // Show "Generate Timetable" button only when n reaches 0
            isLimit
                ? Center(
                    child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => TimetableScreen(
                                  collectionName: "${course}table",
                                ),
                              ));
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: Duration(seconds: 8),
                            backgroundColor: ColorConstants.gold,
                            content: Text(
                              "You can Edit TimeTable by clicking on each period fields and also assign the time of periods",
                              style: TextStyle(
                                  color: ColorConstants.mainBlack,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            ),
                          ));
                        },
                        style: ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                ColorConstants.mainBlack)),
                        child: Text(
                          "Generate Timetable",
                          style: TextStyle(
                              fontSize: 18, color: ColorConstants.mainWhite),
                        )),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }
}

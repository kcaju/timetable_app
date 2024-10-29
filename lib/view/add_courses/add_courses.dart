import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timetable_app/utils/color_constants.dart';
import 'package:timetable_app/view/assign_staffs_screen/assign_staffs.dart';

class AddCourses extends StatefulWidget {
  const AddCourses({super.key});

  @override
  State<AddCourses> createState() => _AddCoursesState();
}

class _AddCoursesState extends State<AddCourses> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    var courseList = FirebaseFirestore.instance.collection("Courses");
    var staffList = FirebaseFirestore.instance.collection("staffList");

    void showAddSubjectDialog(BuildContext context, String course) {
      final List<TextEditingController> subjectControllers = [];
      final List<Widget> subjectFields = [];

      void addSubjectField() {
        final controller = TextEditingController();
        subjectControllers.add(controller);
        subjectFields.add(
          TextField(
            controller: controller,
            decoration: InputDecoration(
                hintText: "Enter Subject name",
                labelStyle: TextStyle(fontSize: 18),
                label: Text("Eg : Operating systems")),
          ),
        );
      }

      // Initially add one subject field
      addSubjectField();

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Add Subjects"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Ensure dialog is compact
                    children: [
                      ...subjectFields,
                      IconButton(
                        onPressed: () {
                          setState(
                            () {
                              addSubjectField(); // Add a new field when the icon is pressed
                            },
                          );
                        },
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Close",
                      style: TextStyle(color: ColorConstants.mainRed),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Check for empty subject names and prepare data for Firestore
                      List<String> subjectsToAdd = [];
                      for (var controller in subjectControllers) {
                        if (controller.text.isNotEmpty) {
                          subjectsToAdd.add(controller.text);
                        }
                      }

                      if (subjectsToAdd.isNotEmpty) {
                        // Add each subject to Firestore
                        for (var subject in subjectsToAdd) {
                          await FirebaseFirestore.instance
                              .collection(course)
                              .add({
                            'subj': subject,
                          });
                        }
                        Navigator.pop(context); // Close the dialog after adding
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: Duration(seconds: 2),
                            backgroundColor: ColorConstants.gold,
                            content: Text(
                              "The subjects are added to this course",
                              style: TextStyle(
                                  color: ColorConstants.mainBlack,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            )));
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            backgroundColor: ColorConstants.gold,
                            content: Text(
                              "Now add Staffs",
                              style: TextStyle(
                                  color: ColorConstants.mainBlack,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            )));
                      }
                    },
                    child: Text(
                      "Add",
                      style: TextStyle(color: ColorConstants.blue),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    void showAddCourseDialog(BuildContext context, String title, String hint) {
      final TextEditingController courseController = TextEditingController();
      var courseList = FirebaseFirestore.instance.collection("Courses");

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text(title),
            content: TextField(
              controller: courseController,
              decoration: InputDecoration(
                  hintText: hint,
                  labelStyle: TextStyle(fontSize: 18),
                  label: Text("Eg : Computer-Scienece")),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Close",
                  style: TextStyle(color: ColorConstants.mainRed),
                ),
              ),
              TextButton(
                onPressed: () async {
                  if (courseController.text.isNotEmpty) {
                    // Check if course already exists
                    var courseSnapshot = await courseList
                        .where('course', isEqualTo: courseController.text)
                        .get();

                    if (courseSnapshot.docs.isEmpty) {
                      // If no documents found, add the new course
                      await courseList.add({
                        'course': courseController.text,
                      });
                      Navigator.pop(context);
                      showAddSubjectDialog(context, courseController.text);
                    } else {
                      // Optionally show a message if the course already exists
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Course already exists!'),
                        ),
                      );
                    }
                  }
                },
                child: Text(
                  "Add",
                  style: TextStyle(color: ColorConstants.blue),
                ),
              ),
            ],
          );
        },
      );
    }

    void showAddStaffDialog(BuildContext context) {
      final TextEditingController courseController = TextEditingController();
      final List<TextEditingController> staffControllers = [];
      final List<Widget> staffFields = [];

      void addStaffField() {
        final controller = TextEditingController();
        staffControllers.add(controller);
        staffFields.add(
          TextField(
            controller: controller,
            decoration: InputDecoration(
              hintText: "Enter Staff name",
            ),
          ),
        );
      }

      // Initially add one staff field
      addStaffField();

      showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text("Add Staff"),
                content: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: courseController,
                        decoration: InputDecoration(
                            hintText: "Enter course name",
                            labelStyle: TextStyle(fontSize: 18),
                            label: Text("Eg : Computer-Scienece")),
                      ),
                      ...staffFields,
                      IconButton(
                        onPressed: () {
                          setState(() {
                            addStaffField(); // Add a new field when the icon is pressed
                          });
                        },
                        icon: Icon(Icons.add),
                      ),
                    ],
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text(
                      "Close",
                      style: TextStyle(color: ColorConstants.mainRed),
                    ),
                  ),
                  TextButton(
                    onPressed: () async {
                      // Check for empty staff names and prepare data for Firestore
                      List<String> staffToAdd = [];
                      for (var controller in staffControllers) {
                        if (controller.text.isNotEmpty) {
                          staffToAdd.add(controller.text);
                        }
                      }

                      // Get the course name
                      String courseName = courseController.text;

                      if (staffToAdd.isNotEmpty && courseName.isNotEmpty) {
                        // Check if the course already exists in the staffList collection
                        var courseSnapshot = await staffList
                            .where('course', isEqualTo: courseName)
                            .get();

                        if (courseSnapshot.docs.isNotEmpty) {
                          // If course exists, update the existing document
                          var existingDoc = courseSnapshot.docs.first;
                          List<dynamic> existingStaff =
                              existingDoc['staff'] ?? [];
                          existingStaff.addAll(
                              staffToAdd); // Add new staff to existing staff list
                          await staffList
                              .doc(existingDoc.id)
                              .update({'staff': existingStaff});
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              duration: Duration(seconds: 6),
                              backgroundColor: ColorConstants.gold,
                              content: Text(
                                "Now you can asssign subjects to staffs (or) keep adding staffs to the course",
                                style: TextStyle(
                                    color: ColorConstants.mainBlack,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18),
                              )));
                        } else {
                          // If course does not exist, create a new document
                          await staffList.add({
                            'course': courseName,
                            'staff': staffToAdd,
                          });
                        }
                        Navigator.pop(context); // Close the dialog after adding
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: Duration(seconds: 5),
                            backgroundColor: ColorConstants.gold,
                            content: Text(
                              "Now you can asssign staffs to subjects (or) keep adding staffs",
                              style: TextStyle(
                                  color: ColorConstants.mainBlack,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18),
                            )));
                      }
                    },
                    child: Text(
                      "Add",
                      style: TextStyle(color: ColorConstants.blue),
                    ),
                  ),
                ],
              );
            },
          );
        },
      );
    }

    return Scaffold(
      floatingActionButton: StreamBuilder<QuerySnapshot>(
        stream: staffList.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasData && snapshot.data!.docs.isNotEmpty) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 60,
              width: 160,
              child: FloatingActionButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isLoading = true; // Set loading to true
                        });

                        try {
                          // Fetch courses
                          var coursesSnapshot = await courseList.get();
                          List<dynamic> courses =
                              coursesSnapshot.docs.map((doc) {
                            return doc['course'];
                          }).toList();

                          // Fetch subjects for each course
                          Map<String, List<dynamic>> subjects = {};
                          for (var course in courses) {
                            var subjectsSnapshot = await FirebaseFirestore
                                .instance
                                .collection(course)
                                .get();
                            subjects[course] = subjectsSnapshot.docs.map((doc) {
                              return doc['subj'];
                            }).toList();
                          }

                          // Fetch staff list
                          var staffSnapshot = await staffList.get();
                          Map<String, List<String>> staffMapping = {};
                          for (var doc in staffSnapshot.docs) {
                            String courseName = doc['course'];
                            List<String> staff =
                                List<String>.from(doc['staff'] ?? []);
                            staffMapping[courseName] = staff;
                          }

                          // Navigate to AssignStaffs screen with the fetched data
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AssignStaffs(
                                staffMapping: staffMapping,
                                courses: courses,
                                subjects: subjects,
                              ),
                            ),
                          );
                        } catch (error) {
                          // Handle any errors here
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error fetching data: $error'),
                            ),
                          );
                        } finally {
                          setState(() {
                            _isLoading = false; // Reset loading state
                          });
                        }
                      },
                child: _isLoading
                    ? CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      )
                    : Text(
                        "Assign subjects to staffs",
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w700),
                      ),
              ),
            );
          } else {
            return SizedBox(); // Return an empty widget if no staff
          }
        },
      ),
      appBar: AppBar(
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
        centerTitle: true,
        title: Text(
          "Add Details",
          style: TextStyle(
              color: ColorConstants.mainWhite,
              fontWeight: FontWeight.bold,
              fontSize: 25),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    "Courses :",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Spacer(),
                  Text(
                    "Add Courses:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  InkWell(
                    onTap: () {
                      showAddCourseDialog(
                          context, "Add Course:", "Enter course name");
                    },
                    child: CircleAvatar(
                      backgroundColor: ColorConstants.green,
                      radius: 15,
                      child: Icon(Icons.add),
                    ),
                  ),
                  SizedBox(
                    width: 10,
                  ),
                ],
              ),
              SizedBox(
                height: 20,
              ),
              StreamBuilder<QuerySnapshot>(
                stream: courseList.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No courses found"));
                  }
                  final documents = snapshot.data!.docs;
                  return GridView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    shrinkWrap: true,
                    itemCount: documents.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10),
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data =
                          documents[index].data()! as Map<String, dynamic>;
                      return Stack(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 5),
                            decoration: BoxDecoration(
                                color: ColorConstants.mainGrey,
                                borderRadius: BorderRadius.circular(10)),
                            child: Center(
                              child: Text(
                                data['course'],
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 0,
                            child: InkWell(
                              onTap: () async {
                                String courseId = documents[index].id;
                                String courseName = documents[index]['course'];

                                // Fetch subjects associated with the course
                                var subjectsSnapshot = await FirebaseFirestore
                                    .instance
                                    .collection(courseName)
                                    .get();

                                // Delete each subject in the course
                                for (var subjectDoc in subjectsSnapshot.docs) {
                                  await FirebaseFirestore.instance
                                      .collection(courseName)
                                      .doc(subjectDoc.id)
                                      .delete();
                                }

                                // Now delete the course
                                await courseList.doc(courseId).delete();

                                // Optionally show a Snackbar to confirm deletion
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(SnackBar(
                                        backgroundColor: ColorConstants.gold,
                                        content: Text(
                                          '$courseName and its subjects have been deleted',
                                          style: TextStyle(
                                              color: ColorConstants.mainBlack,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18),
                                        )));
                              },
                              child: CircleAvatar(
                                backgroundColor: ColorConstants.mainRed,
                                radius: 10,
                                child: Icon(
                                  Icons.remove,
                                  size: 15,
                                ),
                              ),
                            ),
                          )
                        ],
                      );
                    },
                  );
                },
              ),
              SizedBox(
                height: 20,
              ),
              Row(
                children: [
                  Text(
                    "Staffs :",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  Spacer(),
                  Text(
                    "Add Staffs:",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                  ),
                  SizedBox(width: 10),
                  InkWell(
                    onTap: () {
                      showAddStaffDialog(context);
                    },
                    child: CircleAvatar(
                      backgroundColor: ColorConstants.green,
                      radius: 15,
                      child: Icon(Icons.add),
                    ),
                  ),
                  SizedBox(width: 10),
                ],
              ),
              SizedBox(height: 20),
              //staff stream
              StreamBuilder<QuerySnapshot>(
                stream: staffList.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No staff found"));
                  }

                  final staffDocuments = snapshot.data!.docs;
                  Future<void> deleteStaffMember(
                      String docId, String staffName) async {
                    // Get the document for the course
                    var courseDoc = await staffList.doc(docId).get();

                    if (courseDoc.exists) {
                      List<dynamic> existingStaff = courseDoc['staff'] ?? [];

                      // Remove the staff member from the list
                      existingStaff.remove(staffName);

                      if (existingStaff.isEmpty) {
                        // If no staff members are left, delete the course document
                        await staffList.doc(docId).delete();
                      } else {
                        // Update the document with the new staff list
                        await staffList
                            .doc(docId)
                            .update({'staff': existingStaff});
                      }
                    }
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: staffDocuments.length,
                    itemBuilder: (context, index) {
                      Map<String, dynamic> data =
                          staffDocuments[index].data()! as Map<String, dynamic>;
                      String course = data['course'] ?? '';
                      List<dynamic> staffNames = data['staff'] ?? [];

                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Course: $course',
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          for (var staff in staffNames)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 4.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    staff,
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete,
                                        size: 18,
                                        color: ColorConstants.mainRed),
                                    onPressed: () async {
                                      // Call the delete function
                                      await deleteStaffMember(
                                          staffDocuments[index].id, staff);
                                    },
                                  ),
                                ],
                              ),
                            ),
                          Divider(
                            thickness: 2,
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

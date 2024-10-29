import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timetable_app/utils/color_constants.dart';
import 'package:timetable_app/view/add_courses/add_courses.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key, required this.collectionName});
  final String collectionName;

  @override
  Widget build(BuildContext context) {
    List<String> days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri'];
    var collectionRef = FirebaseFirestore.instance.collection(collectionName);

    // Method to delete all documents in the collection
    Future<void> deleteCollection(CollectionReference collectionRef) async {
      final snapshots = await collectionRef.get();
      for (var doc in snapshots.docs) {
        await doc.reference.delete();
      }
    }

    void showEditDialog(BuildContext context, CollectionReference collectionRef,
        String docId, Map<String, dynamic> data) {
      TextEditingController subjectController =
          TextEditingController(text: data['subject']);
      TextEditingController staffController =
          TextEditingController(text: data['staff']);
      TextEditingController timeController =
          TextEditingController(text: data['time']);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Edit Course Details"),
            content: SingleChildScrollView(
              child: Column(
                children: [
                  TextField(
                    controller: subjectController,
                    decoration: InputDecoration(labelText: 'Subject'),
                  ),
                  TextField(
                    controller: staffController,
                    decoration: InputDecoration(labelText: 'Staff'),
                  ),
                  TextField(
                    controller: timeController,
                    decoration: InputDecoration(labelText: 'Time'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                child: Text(
                  "Cancel",
                  style: TextStyle(color: ColorConstants.mainRed),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text(
                  "Save",
                  style: TextStyle(color: ColorConstants.blue),
                ),
                onPressed: () async {
                  await collectionRef.doc(docId).update({
                    'subject': subjectController.text,
                    'staff': staffController.text,
                    'time': timeController.text,
                  });
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      floatingActionButton: Container(
        padding: EdgeInsets.all(5),
        height: 60,
        width: 150,
        child: FloatingActionButton(
          child: Text(
            "Generate timetable for another course",
            style: TextStyle(fontSize: 15),
          ),
          onPressed: () async {
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => AddCourses(),
              ),
              (route) => false,
            );

            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                duration: Duration(seconds: 5),
                backgroundColor: ColorConstants.gold,
                content: Text(
                  "Now you can add other course,subjects & staffs",
                  style: TextStyle(
                      color: ColorConstants.mainBlack,
                      fontWeight: FontWeight.bold,
                      fontSize: 18),
                )));
            await deleteCollection(collectionRef);
          },
        ),
      ),
      appBar: AppBar(
        leading: Icon(null),
        centerTitle: true,
        title: Text(
          "Time Table",
          style: TextStyle(
              color: ColorConstants.mainWhite,
              fontWeight: FontWeight.bold,
              fontSize: 25),
        ),
        backgroundColor: ColorConstants.blue,
      ),
      body: SingleChildScrollView(
        // Wrap with SingleChildScrollView
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: collectionRef.snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Get the course name from the first document
                final documents = snapshot.data!.docs;
                if (documents.isEmpty) {
                  return const Text('No courses available');
                }

                // Assuming the course name is in the first document
                final courseData = documents[0].data() as Map<String, dynamic>;
                String courseName = courseData['course'] ?? 'Unknown Course';

                return Text(
                  "Course: $courseName",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                );
              },
            ),
            Container(
              decoration: BoxDecoration(
                  color: ColorConstants.lightblue,
                  border: Border.all(color: ColorConstants.brown)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 100,
                    child: Row(
                      children: [
                        ListView.separated(
                          shrinkWrap: true,
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return Container(
                              child: Center(
                                child: Text(days[index],
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                              ),
                              height: 100,
                              width: 77,
                              decoration: BoxDecoration(
                                color: ColorConstants.peach,
                              ),
                            );
                          },
                          separatorBuilder: (context, index) =>
                              SizedBox(width: 5),
                          itemCount: days.length,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  StreamBuilder<QuerySnapshot>(
                    stream: collectionRef.snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.hasError) {
                        return const Text('Something went wrong');
                      }

                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: CircularProgressIndicator(),
                        );
                      }

                      final documents = snapshot.data!.docs;
                      return GridView.builder(
                        shrinkWrap: true,
                        physics:
                            NeverScrollableScrollPhysics(), // Prevent scrolling
                        itemCount: documents.length,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 5,
                          crossAxisSpacing: 5,
                          mainAxisSpacing: 5,
                          mainAxisExtent: 140,
                        ),
                        itemBuilder: (context, index) {
                          Map<String, dynamic> data =
                              documents[index].data()! as Map<String, dynamic>;
                          return InkWell(
                            onTap: () {
                              showEditDialog(context, collectionRef,
                                  documents[index].id, data);
                            },
                            child: Container(
                              child: Column(
                                children: [
                                  Expanded(
                                    child: Text(
                                      data['subject'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 16),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    data['staff'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 15),
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Text(
                                    data['time'],
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500,
                                        fontSize: 15),
                                  ),
                                ],
                              ),
                              height: 150,
                              width: 64,
                              decoration: BoxDecoration(
                                color: ColorConstants.peach,
                              ),
                            ),
                          );
                        },
                      );
                    },
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

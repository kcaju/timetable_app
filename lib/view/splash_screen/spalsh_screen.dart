import 'package:flutter/material.dart';
import 'package:timetable_app/utils/color_constants.dart';
import 'package:timetable_app/utils/image_constants.dart';
import 'package:timetable_app/view/home_screen/home_screen.dart';

class SpalshScreen extends StatefulWidget {
  const SpalshScreen({super.key});

  @override
  State<SpalshScreen> createState() => _SpalshScreenState();
}

class _SpalshScreenState extends State<SpalshScreen> {
  @override
  void initState() {
    Future.delayed(Duration(seconds: 3)).then(
      (value) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(),
            ));
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.lightblue,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              ImageConstants.LOGO_PNG,
              height: 200,
            ),
            SizedBox(
              height: 20,
            ),
            Text(
              "Time Table Generation App",
              style: TextStyle(
                  color: ColorConstants.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: 30),
            )
          ],
        ),
      ),
    );
  }
}

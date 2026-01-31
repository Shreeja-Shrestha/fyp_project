import 'package:flutter/material.dart';
import 'package:fyp_project/add_package_page.dart';
import 'package:fyp_project/admin_manage_packages_page.dart';
import 'package:fyp_project/getstarted.dart';
import 'package:fyp_project/hotel1.dart';
import 'package:fyp_project/hotel2.dart';
import 'package:fyp_project/login.dart';
import 'package:fyp_project/mardi.dart';
import 'package:fyp_project/home.dart';
import 'package:fyp_project/signup.dart';
import 'package:fyp_project/tour_detail_page.dart';
import 'package:fyp_project/tour_detail_page.dart';

import 'admin_manage_packages_page.dart';

//import 'signup.dart';
//import 'signup.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Login UI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const TourDetailPage(),
    );
  }
}

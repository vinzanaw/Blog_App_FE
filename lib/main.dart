import 'package:blog_app_ats/pages/homepage.dart';
import 'package:flutter/material.dart';
import 'package:blog_app_ats/pages/splash.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      routes: {
        '/splash': (context) => const SplashPage(),
        '/home': (context) => const homePage(),
      },
      initialRoute: '/splash',  
    );
  }
}
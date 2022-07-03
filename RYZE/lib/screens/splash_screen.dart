import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ryze/layout/home.dart';
import 'package:ryze/screens/auth/test_ui_auth.dart';
import 'package:ryze/shared/component/navigate.dart';
import 'package:ryze/shared/constants/constants.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    if(user != null){
      Timer(const Duration(seconds: 3), ()=> navigateToAndReplace(context, const Home()));



    }
    else
    {
      Timer(const Duration(seconds: 3), ()=> navigateToAndReplace(context, const TestUiAuth()));
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[400],
    );
  }
}
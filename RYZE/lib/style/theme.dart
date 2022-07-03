import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:ryze/shared/constants/constants.dart';


ThemeData lightTheme=ThemeData(
  primaryColor: kPrimaryLightColor,
  primarySwatch: mainColor,
  brightness: Brightness.light,
  floatingActionButtonTheme:const FloatingActionButtonThemeData(
    backgroundColor: mainColor,
  ) ,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    titleSpacing: 20.0,
    backgroundColor: Colors.white,
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: Colors.white,
      statusBarIconBrightness: Brightness.dark,
    ),
    elevation: 0.0,
    titleTextStyle: TextStyle(
      color: Colors.black,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.black),
  ),
  tabBarTheme: TabBarTheme(
    labelColor: Colors.black,
    indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(50.0),
      color: Colors.white
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    selectedItemColor: mainColor,
    elevation: 20.0,
    unselectedItemColor: Colors.grey,
    backgroundColor:  Colors.white,
  ),
  textTheme: const TextTheme(
    bodyText1: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 18.0,
      color: Colors.black,
    ),
    subtitle1: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14.0,
      color: Colors.black,
      height: 1.3,
    ),
  ),
);


ThemeData darkTheme=ThemeData(
  primaryColor: Colors.black,
  primarySwatch: mainColor,
  brightness: Brightness.dark,
  floatingActionButtonTheme:const FloatingActionButtonThemeData(
    backgroundColor: Colors.red,
  ),
  appBarTheme: AppBarTheme(
    titleSpacing: 20.0,
    backgroundColor: HexColor('333739'),
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarColor: HexColor('333739'),
      statusBarIconBrightness: Brightness.light,
    ),
    elevation: 0.0,
    titleTextStyle: const TextStyle(
      color: Colors.white,
      fontSize: 20.0,
      fontFamily: 'Batman',
      fontWeight: FontWeight.bold,
    ),
    iconTheme: const IconThemeData(color: Colors.white),
  ),
  tabBarTheme: TabBarTheme(
    labelColor: Colors.white,
    indicator: BoxDecoration(
        borderRadius: BorderRadius.circular(50.0),
        color: Colors.black
    ),
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    type: BottomNavigationBarType.fixed,
    selectedItemColor:mainColor,
    elevation: 20.0,
    unselectedItemColor: Colors.grey,
    backgroundColor:  HexColor('333739'),
  ),
  scaffoldBackgroundColor: HexColor('333739'),
  textTheme: const TextTheme(
    bodyText1: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 18.0,
      color: Colors.white,
    ),
    subtitle1: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 14.0,
      color: Colors.white,
      height: 1.3,
    ),
  ),
);

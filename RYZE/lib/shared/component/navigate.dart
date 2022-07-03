import 'package:flutter/material.dart';

void navigateTo(context, screen) => Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => screen,
    ));

void navigatePop(context) => Navigator.of(
    context).maybePop();

void navigateToAndReplace(context, screen) => Navigator.pushAndRemoveUntil(
  context,
  MaterialPageRoute(
    builder: (context) => screen,
  ),
      (Route<dynamic> route) => false,
);
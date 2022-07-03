import 'package:flutter/material.dart';
import 'package:ryze/shared/constants/constants.dart';

class Button extends StatelessWidget {
  final double? width;
  final double? height;
  final dynamic text;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final bool isGradientColor;
  final MaterialStateProperty<OutlinedBorder?>? shape;
  final double borderRadius;

  const Button({Key? key,
    this.width = 100,
    this.height = 50,
    required this.text,
    required this.onPressed,
    this.backgroundColor,
    this.isGradientColor = false,
    this.shape,
    this.borderRadius = 50.0,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: isGradientColor ? BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow:  const [
            BoxShadow(
              color: kPrimaryColor,
              offset: Offset(1.0, 1.0),
              blurRadius: 10.0,
            ),
            BoxShadow(
              color: facebookColor,
              offset: Offset(-1.0, -1.0),
              blurRadius: 10.0,
            )
          ],
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              kPrimaryColor,
              facebookColor,
            ],
            stops: [0.0, 1.0],
          ),
        ): null,
        child: InkWell(
          onTap: onPressed,
          child: text is String
              ? Center(
                child: Text(
                    text,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
              )
              : text,

        ),
      ),
    );
  }
}

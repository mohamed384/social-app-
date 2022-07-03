import 'package:flutter/material.dart';
import 'package:get/get.dart';

dialogBottomSheet(
    {required BuildContext context, required List<Widget> children}) {
  return showModalBottomSheet<void>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
          topLeft: Radius.circular(25.0),
          topRight: Radius.circular(25.0)),
    ),
    builder: (BuildContext context) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0, bottom: 18),
            child: Container(
                height: 5,
                width: 40,
                decoration: BoxDecoration(
                    color: Get.isDarkMode ? Colors.white : Colors.black,
                    borderRadius: const BorderRadius.all(Radius.circular(20)))),
          ),
          Column(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: children),
        ],
      );
    },
  );
}

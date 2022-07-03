import 'package:flutter/material.dart';

class ChoosePhotoFrom extends StatelessWidget {
  final BuildContext context;
  final GestureTapCallback onTabCamera;
  final GestureTapCallback onTabGallary;

  const ChoosePhotoFrom(
      {Key? key,required this.context,
      required this.onTabCamera,
      required this.onTabGallary}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Wrap(
      children: [
        SizedBox(
          width: MediaQuery.of(context).size.width/ 1.2,
          child: Card(
            margin: const EdgeInsets.all(10.0),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 20),
              child: Column(
                children: [
                  const Text('choose from:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),),
                  const SizedBox(height: 10,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconCreation(icons: Icons.camera_alt, color: Colors.pink, text: 'Camera', onTap: onTabCamera),
                      const SizedBox(
                        width: 40,
                      ),
                      IconCreation(icons: Icons.insert_photo, color: Colors.purple, text: "Gallery",onTap: onTabGallary),
                    ],
                  ),
                              ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class IconCreation extends StatelessWidget {
  final IconData icons;
  final Color color;
  final String text;
  final GestureTapCallback onTap;

  const IconCreation(
      {Key? key,required this.icons,
      required this.color,
      required this.text,
      required this.onTap}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 30,
            backgroundColor: color,
            child: Icon(
              icons,
              // semanticLabel: "Help",
              size: 29,
              color: Colors.white,
            ),
          ),
          const SizedBox(
            height: 5,
          ),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              // fontWeight: FontWeight.w100,
            ),
          )
        ],
      ),
    );
  }
}

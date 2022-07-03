import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ryze/models/user_data.dart';
import 'package:ryze/shared/component/choose_image.dart';
import 'package:ryze/shared/component/text_form.dart';
import 'package:ryze/shared/component/toast.dart';
import 'package:ryze/shared/constants/constants.dart';
import 'package:ryze/shared/constants/extention_text_form.dart';


class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController nameController=TextEditingController();
  final TextEditingController emailController =TextEditingController();
List profileImagePath=[];
  @override
  void initState() {
    nameController.text=meInfo[0]['name'].toString();
    emailController.text=meInfo[0]['email'].toString();
    super.initState();
  }
  @override
  void dispose() {

    nameController.dispose();
    emailController.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 1,
        title:  const Text(
          "Edit Profile",
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xff035AA6),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),

      ),
      body: Container(
        padding: const EdgeInsets.only(left: 16, top: 25, right: 16),
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: ListView(
            children: [
              Center(
                child: Stack(
                  children: [
                    Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                          border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor),
                          boxShadow: [
                            BoxShadow(
                                spreadRadius: 2,
                                blurRadius: 10,
                                color: Colors.black.withOpacity(0.1),
                                offset: const Offset(0, 10))
                          ],
                          shape: BoxShape.circle,
                          image:  DecorationImage(
                              fit: BoxFit.cover,
                              image:profileImagePath.isEmpty? CachedNetworkImageProvider(
                                  meInfo[0]['profilePhotoUrl'].toString())
                                  :FileImage(File(profileImagePath[0].path))as ImageProvider)),
                    ),
                    Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              width: 4,
                              color: Theme.of(context).scaffoldBackgroundColor,
                            ),
                            color:const Color(0xff035AA6),
                          ),
                          child: InkWell(
                            child:const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                            ), onTap: () async{
                            await showDialog(
                                context: context,
                                builder: (ctx) {
                              return Center(
                                  child: ChoosePhotoFrom(
                                      context: context,
                                      onTabCamera: () async {
                                        Navigator.pop(ctx);
                                       profileImagePath.addAll( await getImage(source: ImageSource.camera, clearList: true));
                                       setState((){});
                                      },
                                      onTabGallary: () async {
                                        Navigator.pop(ctx);
                                        profileImagePath.addAll( await getImage(source: ImageSource.gallery, clearList: true));
                                        setState((){});

                                      }));
                            });
                          } ,

                          ),
                        )),
                  ],
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              TextForm(
                controller: nameController,
                keyType: TextInputType.name,
                prePhoto: Icons.account_box_outlined,
                label: 'name'.tr,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'enter_name_pl'.tr;
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 15,
              ),
              TextForm(
                controller: emailController,
                keyType: TextInputType.emailAddress,
                prePhoto: Icons.email_outlined,
                label: 'email_address'.tr,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "enter_email_pl".tr;
                  } else if (!value.isValidEmail) {
                    return "enter_valid_email".tr;
                  }
                  return null;
                },
              ),
              const SizedBox(
                height: 35,
              ),
              MaterialButton(
                onPressed: ()async {
                  if(profileImagePath.isNotEmpty){
                    FirebaseStorage storage = FirebaseStorage.instance;
                    Reference ref =
                    storage.ref().child('users/${auth.currentUser!.uid}/profilePhoto');
                    await ref.putFile(File(profileImagePath[0].path)).then((value) async {
                       await (value).ref.getDownloadURL().then((value) {
                         FirebaseFirestore.instance.collection('users').doc(user!.uid).
                         update({
                           'profilePhotoUrl':value,
                         });
                         meInfo[0]['profilePhotoUrl']=value;
                       });
                    });
                  }
                  if(meInfo[0]['name']!=nameController.text){
                    FirebaseFirestore.instance.collection('users').doc(user!.uid).
                    update({
                      'name':nameController.text,
                    });
                    meInfo[0]['name']=nameController.text;

                  }
                  if(meInfo[0]['email']!=emailController.text){
                    FirebaseFirestore.instance.collection('users').doc(user!.uid).
                    update({
                      'email':emailController.text,
                    });
                    meInfo[0]['email']=emailController.text;

                  }
                 showToast(text: 'done', state: ToastStates.success);

                },
                color: const Color(0xff035AA6),
                padding: const EdgeInsets.symmetric(horizontal: 50),
                elevation: 2,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
                child: const Text(
                  "SAVE",
                  style: TextStyle(
                      fontSize: 14,
                      letterSpacing: 2.2,
                      color: Colors.white),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

}
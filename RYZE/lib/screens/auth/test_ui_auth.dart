import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:ryze/layout/home.dart';
import 'package:ryze/screens/auth/cubit/cubit.dart';
import 'package:ryze/screens/auth/cubit/states.dart';
import 'package:ryze/shared/component/button.dart';
import 'package:ryze/shared/component/choose_image.dart';
import 'package:ryze/shared/component/circle_edit_photo.dart';
import 'package:ryze/shared/component/navigate.dart';
import 'package:ryze/shared/component/text_form.dart';
import 'package:ryze/shared/component/toast.dart';
import 'package:ryze/shared/constants/constants.dart';
import 'package:ryze/shared/constants/extention_text_form.dart';



class TestUiAuth extends StatefulWidget {
  const TestUiAuth({Key? key}) : super(key: key);

  @override
  _TestUiAuthState createState() => _TestUiAuthState();
}

class _TestUiAuthState extends State<TestUiAuth> {
  final formKeySignup = GlobalKey<FormState>();
  final formKeyLogin = GlobalKey<FormState>();
  late final TextEditingController emailLogController;
  late final TextEditingController passwordLogController;
  late final TextEditingController nameController;
  late final TextEditingController emailSignupController;
  late final TextEditingController passwordSignupController;
  late final TextEditingController confirmPasswordController;


  @override
  void initState() {

    emailLogController = TextEditingController();
    passwordLogController = TextEditingController();
    nameController = TextEditingController();
    emailSignupController = TextEditingController();
    passwordSignupController = TextEditingController();
    confirmPasswordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    emailLogController.dispose();
    passwordLogController.dispose();
    nameController.dispose();
    emailSignupController.dispose();
    passwordSignupController.dispose();
    confirmPasswordController.dispose();
    imagesPaths.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthCubit, AuthStates>(
            listener: (context, state) {
              if (state is SocialLoginErrorState) {
                showToast(
                  text: state.error,
                  state: ToastStates.error,
                );
              }
              if (state is SocialRegisterErrorState) {
                switch (state.error) {
                  case '[firebase_auth/email-already-in-use] The email address is already in use by another account.':
                    showToast(
                      text: 'email_exist'.tr,
                      state: ToastStates.error,
                    );
                    break;
                  case '[firebase_auth/network-request-failed] A network error (such as timeout, interrupted connection or unreachable host) has occurred.':
                    showToast(
                      text: 'network_fail'.tr,
                      state: ToastStates.error,
                    );
                    break;
                  default:
                    showToast(
                      text: state.error,
                      state: ToastStates.error,
                    );
                }
              }
              if (state is SocialLoginSuccessState) {
                user =auth.currentUser;
                navigateToAndReplace(
                  context,
                  const Home(),
                );
              }
              if (state is SocialRegisterSuccessState) {
                user =auth.currentUser;
                AuthCubit.get(context).imagesPath.clear();
                AuthCubit.get(context).isSignupScreen=false;
                navigateToAndReplace(
                  context,
                  const Home(),
                );
              }
            },
            builder: (context, state) {
          return Scaffold(
            resizeToAvoidBottomInset: AuthCubit.get(context).isSignupScreen ? true: false,
            body: Container(
              height: double.infinity,
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).size.height / 10,
                  left: 20,
                  right: 20),
              color: const Color(0xFF3b5999),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                          text: 'welcome_to'.tr,
                          style: TextStyle(
                            fontSize: 25,
                            letterSpacing: 2,
                            color: Colors.yellow[300],
                          ),
                          children: [
                            TextSpan(
                              text: 'ryze'.tr,
                              style: TextStyle(
                                fontSize: 25,
                                fontWeight: FontWeight.bold,
                                color: Colors.yellow[300],
                              ),
                            )
                          ]),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      AuthCubit.get(context).isSignupScreen
                          ? 'signup_cont'.tr
                          : 'signin_cont'.tr,
                      style: TextStyle(
                        letterSpacing: 1,
                        color: Theme.of(context).textTheme.bodyText1!.color,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    DefaultTabController(
                        length: 2,
                        child: Column(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Get.isDarkMode ? Colors.black.withOpacity(.15): Colors.white.withOpacity(.15),
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: TabBar(
                                padding:
                                    const EdgeInsets.all(5.0),
                                onTap: (index) {
                                  if (index == 1 &&
                                      !AuthCubit.get(context).isSignupScreen) {
                                    AuthCubit.get(context).changeSingSection();
                                  } else if (index == 0 &&
                                      AuthCubit.get(context).isSignupScreen) {
                                    AuthCubit.get(context).changeSingSection();
                                  }
                                },
                                tabs: [
                                  Tab(
                                    text: 'login'.tr,
                                  ),
                                  Tab(
                                    text: 'signup'.tr,
                                  )
                                ],
                              ),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            SizedBox(
                              height: MediaQuery.of(context).size.height / 1.6,
                              child: Stack(
                                alignment: Alignment.topCenter,
                                children: [
                                  SizedBox(
                                    height: AuthCubit.get(context)
                                            .isSignupScreen
                                        ? MediaQuery.of(context).size.height /
                                            1.7
                                        : MediaQuery.of(context).size.height /
                                            3,
                                    child: TabBarView(
                                      physics: const NeverScrollableScrollPhysics(),
                                      children: [
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeIn,
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color:
                                            Get.isDarkMode ? Colors.black.withOpacity(.15): Colors.white.withOpacity(.15),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: LoginWidget(
                                              formKeyLogin: formKeyLogin,
                                              emailLogController:
                                                  emailLogController,
                                              passwordLogController:
                                                  passwordLogController),
                                        ),
                                        AnimatedContainer(
                                          duration: const Duration(milliseconds: 300),
                                          curve: Curves.easeIn,
                                          padding: const EdgeInsets.all(20),
                                          decoration: BoxDecoration(
                                            color:
                                            Get.isDarkMode ? Colors.black.withOpacity(.15): Colors.white.withOpacity(.15),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: SignUPWidget(
                                              formKeySignup: formKeySignup,
                                              nameController: nameController,
                                              emailSignupController:
                                                  emailSignupController,
                                              passwordSignupController:
                                                  passwordSignupController,
                                              confirmPasswordController:
                                                  confirmPasswordController),
                                        ),
                                      ],
                                    ),
                                  ),
                                  AnimatedPositioned(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeIn,
                                      top: AuthCubit.get(context).isSignupScreen
                                          ? MediaQuery.of(context).size.height /
                                              1.8
                                          : MediaQuery.of(context).size.height /
                                              3.35,
                                      child: state
                                                  is! SocialRegisterLoadingState &&
                                              state is! SocialLoginLoadingState
                                          ? Button(
                                              text: AuthCubit.get(context)
                                                      .isSignupScreen
                                                  ? 'signup'.tr
                                                  : 'login'.tr,
                                              isGradientColor: true,
                                              borderRadius: 15,
                                              onPressed: AuthCubit.get(context)
                                                      .isSignupScreen
                                                  ? () {
                                                      // signup action
                                                      if (formKeySignup
                                                          .currentState!
                                                          .validate()) {
                                                        AuthCubit.get(context)
                                                            .signUp(
                                                          name: nameController
                                                              .text,
                                                          email:
                                                              emailSignupController
                                                                  .text,
                                                          password:
                                                              passwordSignupController
                                                                  .text,
                                                          token: '',
                                                          photo:AuthCubit.get(context).imagesPath.isEmpty?"": AuthCubit.get(context).imagesPath[0].path,
                                                        );
                                                      }
                                                    }
                                                  : () {
                                                      //login action
                                                      if (formKeyLogin
                                                          .currentState!
                                                          .validate()) {
                                                        AuthCubit.get(context)
                                                            .userLogin(
                                                          email:
                                                              emailLogController
                                                                  .text,
                                                          password:
                                                              passwordLogController
                                                                  .text,
                                                        );
                                                      }
                                                    })
                                          : const Center(
                                              child:
                                                  CircularProgressIndicator()))
                                ],
                              ),
                            )
                          ],
                        )),
                  ],
                ),
              ),
            ),
          );
        });
  }
}

class LoginWidget extends StatelessWidget {
  final Key formKeyLogin;
  final TextEditingController emailLogController, passwordLogController;

  const LoginWidget(
      {Key? key,required this.formKeyLogin,
      required this.emailLogController,
      required this.passwordLogController}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: formKeyLogin,
          child: Column(
            children: [
              TextForm(
                controller: emailLogController,
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
              const SizedBox(height: 10.0),
              TextForm(
                controller: passwordLogController,
                keyType: TextInputType.visiblePassword,
                secureText: AuthCubit.get(context).isPassword,
                prePhoto: Icons.lock_outlined,
                postPhoto: IconButton(
                    icon: Icon(AuthCubit.get(context).suffix),
                  onPressed: () => AuthCubit.get(context).changePasswordVisibility(),
                ),
                label: 'password'.tr,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "password_must_exit".tr;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUPWidget extends StatelessWidget {
  final Key formKeySignup;
  final TextEditingController nameController,
      emailSignupController,
      passwordSignupController,
      confirmPasswordController;

  const SignUPWidget(
      {Key? key,required this.formKeySignup,
      required this.nameController,
      required this.emailSignupController,
      required this.passwordSignupController,
      required this.confirmPasswordController}): super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Form(
        key: formKeySignup,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 10.0),
          child: Column(
            children: [
              InkWell(
                  onTap: () async {
                    await showDialog(
                        context: context,
                        builder: (ctx) {
                          return Center(
                              child: ChoosePhotoFrom(
                                  context: context,
                                  onTabCamera: () async {
                                    Navigator.pop(ctx);
                                    AuthCubit.get(context).changeImagesPath(await getImage(source: ImageSource.camera, clearList: true));
                                  },
                                  onTabGallary: () async {
                                    Navigator.pop(ctx);
                                    AuthCubit.get(context).changeImagesPath(await getImage(source: ImageSource.gallery, clearList: true));
                                  }));
                        });

                    //ChoosePhotoFrom(context: context, onTabCamera: (){}, onTabGallary: (){});
                  },
                  child: CircleEditPhoto(imagePath: AuthCubit.get(context).imagesPath)),
              const SizedBox(height: 40),
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
              const SizedBox(height: 15),
              TextForm(
                controller: emailSignupController,
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
              const SizedBox(height: 15),
              TextForm(
                  controller: passwordSignupController,
                  keyType: TextInputType.visiblePassword,
                  secureText: AuthCubit.get(context).isPasswordSign,
                  prePhoto: Icons.lock_outlined,
                  postPhoto: IconButton(
                    icon: Icon(AuthCubit.get(context).suffixSign),
                    onPressed: () => AuthCubit.get(context).changePasswordVisibilitySign(),
                  ),
                  label: 'password'.tr,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return "password_must_exit".tr;
                    } else if (!value.isDigitPassword) {
                      return "digit_pass".tr;
                    } else if (!value.isAtleastPassword) {
                      return "length_pass".tr;
                    }
                    return null;
                  }),
              const SizedBox(height: 15),
              TextForm(
                controller: confirmPasswordController,
                keyType: TextInputType.visiblePassword,
                secureText: AuthCubit.get(context).isPasswordSign,
                prePhoto: Icons.lock_outlined,
                postPhoto: IconButton(
                  icon: Icon(AuthCubit.get(context).suffixSign),
                  onPressed: () => AuthCubit.get(context).changePasswordVisibilitySign(),
                ),
                label: 'cPassword'.tr,
                validator: (value) {
                  if (value != passwordSignupController.text) {
                    return 'pass_identical'.tr;
                  }
                  if (value!.isEmpty) {
                    return 'password_must_exit'.tr;
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

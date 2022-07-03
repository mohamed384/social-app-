import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:ryze/layout/cubit/cubit.dart';
import 'package:ryze/screens/auth/cubit/cubit.dart';
import 'package:ryze/screens/auth/test_ui_auth.dart';
import 'package:ryze/screens/comment/cubit.dart';
import 'package:ryze/screens/splash_screen.dart';
import 'package:ryze/shared/bloc_observer.dart';
import 'package:ryze/shared/constants/constants.dart';
import 'package:ryze/shared/constants/language.dart';
import 'package:ryze/shared/network/shared_pref.dart';
import 'package:ryze/style/theme.dart';

import 'layout/home.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await CashHelper.init();

  BlocOverrides.runZoned(
    () {
      runApp(const MyApp());
    },
    blocObserver: MyBlocObserver(),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  bool isDarkMode = false;
  String language = 'en_US';
  @override
  void initState() {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      isDarkMode = CashHelper.getData(key: 'isDarkMode') ?? false;
      if (!isDarkMode) {
        Get.changeThemeMode(ThemeMode.light);
      } else {
        Get.changeThemeMode(ThemeMode.dark);
      }
      language = CashHelper.getData(key: 'language') ?? 'en_US';
      Get.updateLocale(Locale(language));
    });

    super.initState();
  }
  @override
  Widget build(BuildContext context) {

    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => AuthCubit()),
        BlocProvider(create: (context) => HomeCubit()..runAll()),
        BlocProvider(create: (context) => CommentCubit()),
      ],
      child: GetMaterialApp(
        translations: LanguageString(),
        locale: Get.locale ?? const Locale('en_US'),
        builder: (_, child) {
          return Directionality(
            textDirection: Get.locale.toString() == 'en_US'
                ? TextDirection.ltr
                : TextDirection.rtl,
            child: child as Widget,
          );
        },
        debugShowCheckedModeBanner: false,
        title: 'Ryze',
        theme: lightTheme,
        darkTheme: darkTheme,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}

import 'package:chatapp/app/controllers/auth_controller.dart';
import 'package:chatapp/app/utils/theme/theme.dart';
import 'package:flutter/services.dart';
import 'package:get_storage/get_storage.dart';

import '../app/utils/splash_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import 'app/routes/app_pages.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final authC = Get.put(AuthController(), permanent: true);
  final GetStorage box = GetStorage();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: authC.firstInitializes(),
      builder: (context, snapshot2) {
        if (snapshot2.connectionState == ConnectionState.done) {
          return Obx(() => GetMaterialApp(
                theme: authC.mode.isTrue
                    ? TAppTheme.darkTheme
                    : TAppTheme.lightTheme,
                darkTheme: TAppTheme.darkTheme,
                themeMode: ThemeMode.system,
                debugShowCheckedModeBanner: false,
                title: "Chattoapps",
                initialRoute: authC.isSkipIntro.isTrue
                    ? authC.isAuth.isTrue
                        ? Routes.HOME
                        : Routes.LOGIN
                    : Routes.INTRODUCTION,
                getPages: AppPages.routes,
              ));
        }
        return SplashScreen();
      },
    );
  }
}

import 'package:chatapp/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:lottie/lottie.dart';

import '../controllers/introduction_controller.dart';

class IntroductionView extends GetView<IntroductionController> {
  const IntroductionView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: IntroductionScreen(
      pages: [
        PageViewModel(
          title: "Berinteraksi Dengan Mudah",
          body: "Chattoapps",
          image: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.width * 0.6,
            child: Center(
              child: Lottie.asset("assets/lottie/main-laptop-duduk.json"),
            ),
          ),
        ),
        PageViewModel(
          title: "Temukan Teman Barumu Dengan  Chattoapps",
          body: "Chattoapps",
          image: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.width * 0.6,
            child: Center(
              child: Lottie.asset("assets/lottie/payment.json"),
            ),
          ),
        ),
        PageViewModel(
          title: "Gabung Sekarang Juga",
          body:
              "Daftarkan diri kamu untuk jadi bagain dari kamu , dan temukan teman barumu",
          image: Container(
            width: MediaQuery.of(context).size.width * 0.6,
            height: MediaQuery.of(context).size.width * 0.6,
            child: Center(
              child: Lottie.asset("assets/lottie/register.json"),
            ),
          ),
        ),
      ],
      showSkipButton: true,
      skip: const Text("Skip"),
      next: const Text("Next"),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w700)),
      onDone: () => Get.offAllNamed(Routes.LOGIN),
    ));
  }
}

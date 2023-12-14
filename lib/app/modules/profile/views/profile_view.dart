import 'package:avatar_glow/avatar_glow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../controllers/auth_controller.dart';
import '../../../routes/app_pages.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final authC = Get.find<AuthController>();
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              authC.logout();
            },
            icon: const Icon(
              Icons.logout,
              size: 30,
            ),
          )
        ],
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            child: Column(
              children: [
                AvatarGlow(
                  endRadius: 100,
                  glowColor: const Color.fromRGBO(0, 0, 0, 1),
                  duration: Duration(seconds: 2),
                  child: Obx(() => Container(
                        margin: EdgeInsets.all(15),
                        width: 150,
                        height: 150,
                        child: authC.user.value.photoUrl == "noimage"
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.asset(
                                  "assets/logo/noimage.png",
                                  fit: BoxFit.cover,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(100),
                                child: Image.network(authC.user.value.photoUrl!,
                                    fit: BoxFit.cover),
                              ),
                      )),
                ),
                Obx(() => Text(
                      "${authC.user.value.name!}",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                Obx(() => Text(
                      "${authC.user.value.email!}",
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.black54,
                      ),
                    )),
              ],
            ),
          ),
          Expanded(
            child: Container(
              child: Column(
                children: [
                  ListTile(
                    onTap: () {
                      Get.toNamed(Routes.UPDATE_STATUS);
                    },
                    leading: const Icon(
                      Icons.note_add_outlined,
                      size: 35,
                    ),
                    title: const Text(
                      "Update Status",
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_right,
                      size: 50,
                    ),
                  ),
                  ListTile(
                    onTap: () {
                      Get.toNamed(Routes.CHANGE_PROFILE);
                    },
                    leading: const Icon(
                      Icons.person,
                      size: 35,
                    ),
                    title: const Text(
                      "Change Profile",
                      style: TextStyle(
                        fontSize: 22,
                      ),
                    ),
                    trailing: const Icon(
                      Icons.arrow_right,
                      size: 50,
                    ),
                  ),
                  ListTile(
                      onTap: () => Get.defaultDialog(
                          title: "Uppssss....",
                          middleText:
                              "Fitur Belum Tersedia ,Fitur akan di selesaikan jika developernya sempat😉😊"),
                      leading: const Icon(
                        Icons.color_lens,
                        size: 35,
                      ),
                      title: const Text(
                        "Change Theme",
                        style: TextStyle(
                          fontSize: 22,
                        ),
                      ),
                      trailing: const Text(
                        "Light",
                        style: TextStyle(fontSize: 18),
                      )),
                ],
              ),
            ),
          ),
          Container(
            margin: EdgeInsets.only(bottom: 15),
            child: const Column(
              children: [
                Text(
                  "Chat App",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
                Text(
                  "v.1.0",
                  style: TextStyle(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

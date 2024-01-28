import 'package:chatapp/app/controllers/auth_controller.dart';
import 'package:chatapp/app/routes/app_pages.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

import '../controllers/search_controller.dart' as search;

class SearchView extends GetView<search.SearchController> {
  final authC = Get.find<AuthController>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(150),
        child: AppBar(
          backgroundColor: Colors.blue.shade300,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            ),
          ),
          title: const Text(
            'Search',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: TextField(
                controller: controller.searchC,
                onChanged: (value) {
                  controller.search(
                    value,
                    authC.user.value.email!,
                  );
                },
                decoration: InputDecoration(
                    hintText: "Search New Friend",
                    fillColor: Colors.white,
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 30, vertical: 18),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    suffixIcon: IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.search,
                          size: 30,
                        ))),
              ),
            ),
          ),
        ),
      ),
      body: Obx(
        () => controller.tempSearch.length == 0
            ? Center(
                child: Container(
                  width: Get.width * 0.7,
                  height: Get.width * 0.7,
                  child: Lottie.asset("assets/lottie/empty.json"),
                ),
              )
            : ListView.builder(
                itemCount: controller.tempSearch.length,
                itemBuilder: (BuildContext context, int index) {
                  return ListTile(
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 20, horizontal: 15),
                    leading: CircleAvatar(
                      backgroundColor: Colors.black26,
                      radius: 28,
                      child: Obx(
                        () => ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: controller.tempSearch[index]["photoUrl"] ==
                                  "noimage"
                              ? Image.asset(
                                  "assets/logo/noimage.png",
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  "${controller.tempSearch[index]["photoUrl"]}",
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    title: Text(
                      "${controller.tempSearch[index]["name"]}",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    subtitle: Text(
                      "${controller.tempSearch[index]["email"]}",
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    trailing: GestureDetector(
                      onTap: () => authC.addNewConnection(
                          controller.tempSearch[index]["email"]),
                      child: Chip(
                        backgroundColor: Colors.grey.shade300,
                        side: BorderSide.none,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        label: Text("Message"),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}

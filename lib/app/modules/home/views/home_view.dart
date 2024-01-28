import 'package:chatapp/app/controllers/auth_controller.dart';
import 'package:chatapp/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  final authC = Get.find<AuthController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          Material(
            elevation: 3,
            child: Container(
              padding: EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Chattoapps",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Get.toNamed(Routes.PROFILE),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                    ),
                    icon: const Icon(
                      Icons.person,
                      size: 35,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: controller.chatStream(
                  authC.user.value.email!,
                ),
                builder: (contex, snapshot) {
                  if (snapshot.connectionState == ConnectionState.active) {
                    var allChats = snapshot.data!.docs;

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      itemCount: allChats.length,
                      itemBuilder: (BuildContext context, index) {
                        return StreamBuilder<
                                DocumentSnapshot<Map<String, dynamic>>>(
                            stream: controller.friendStream(
                              allChats[index]["connection"],
                            ),
                            builder: (contex, snapshot2) {
                              if (snapshot2.connectionState ==
                                  ConnectionState.active) {
                                var data = snapshot2.data!.data();

                                return ListTile(
                                  onTap: () => controller.goToChatRoom(
                                    "${allChats[index].id}",
                                    authC.user.value.email!,
                                    allChats[index]["connection"],
                                  ),
                                  leading: CircleAvatar(
                                    backgroundColor: Colors.black26,
                                    radius: 25,
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(100),
                                      child: data!['photoUrl'] == 'noimage'
                                          ? Image.asset(
                                              "assets/logo/noimage.png",
                                              fit: BoxFit.cover,
                                            )
                                          : Image.network( 
                                              data['photoUrl'],
                                              fit: BoxFit.cover,
                                            ),
                                    ),
                                  ),
                                  title: Text(
                                    "${data['name']}",
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                  subtitle: StreamBuilder<
                                          QuerySnapshot<Map<String, dynamic>>>(
                                      stream: controller
                                          .chatsHistory(allChats[index].id),
                                      builder: (context, chatSnap) {
                                        if (chatSnap.connectionState ==
                                            ConnectionState.active) {
                                          var chatHistory =
                                              chatSnap.data!.docs[index].data();
                                          return Text(
                                            "${chatHistory['msg']}",
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          );
                                        }
                                        return const SizedBox.shrink();
                                      }),
                                  trailing: allChats[index]['total_unread'] == 0
                                      ? SizedBox()
                                      : CircleAvatar(
                                          radius: 15,
                                          backgroundColor: Colors.blue.shade400,
                                          child: Text(
                                            "${allChats[index]['total_unread']}",
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                );
                              }
                              return const SizedBox.shrink();
                            });
                      },
                    );
                  }
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }),
          )
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue[400],
        onPressed: () => Get.toNamed(Routes.SEARCH),
        child: const Icon(
          Icons.search,
          color: Colors.white,
        ),
      ),
    );
  }
}

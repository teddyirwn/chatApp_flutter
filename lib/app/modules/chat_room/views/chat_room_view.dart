// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:chatapp/app/controllers/auth_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/chat_room_controller.dart';

class ChatRoomView extends GetView<ChatRoomController> {
  final authC = Get.find<AuthController>();
  final String chatId = (Get.arguments as Map<String, dynamic>)["chat_id"];

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Get.theme.brightness;
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: Icon(
              Icons.arrow_back,
              color: Colors.white,
              size: 30,
            ),
          ),
          leadingWidth: 50,
          backgroundColor: Get.theme.appBarTheme.backgroundColor,
          title: StreamBuilder<DocumentSnapshot<dynamic>>(
              stream: controller.streamFriendData(
                  (Get.arguments as Map<String, dynamic>)["friendEmail"]),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.active) {
                  var dataFriend =
                      snapshot.data!.data() as Map<String, dynamic>;
                  return dataFriend["status"] != ""
                      ? ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              color: Colors.grey,
                              width: 45,
                              height: 45,
                              child: dataFriend["photoUrl"] == "noimage"
                                  ? Image.asset(
                                      "assets/logo/noimage.png",
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      dataFriend["photoUrl"],
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          title: Text(
                            dataFriend["name"],
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          subtitle: Text(
                            dataFriend["status"],
                            style: const TextStyle(
                              fontSize: 15,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : ListTile(
                          contentPadding: const EdgeInsets.only(
                              left: 0, right: 0, top: 5, bottom: 10),
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(100),
                            child: Container(
                              color: Colors.grey,
                              width: 45,
                              height: 45,
                              child: dataFriend["photoUrl"] == "noimage"
                                  ? Image.asset(
                                      "assets/logo/noimage.png",
                                      fit: BoxFit.cover,
                                    )
                                  : Image.network(
                                      dataFriend["photoUrl"],
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                          title: Text(
                            dataFriend["name"],
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        );
                }
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.grey,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.asset(
                          "assets/logo/noimage.png",
                          fit: BoxFit.cover,
                        ),
                      )),
                  title: const Text(
                    "Loading...",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    "Loading...",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                    ),
                  ),
                );
              }),
          centerTitle: true,
        ),
        body: WillPopScope(
          onWillPop: () {
            if (controller.isShowEmoji.isTrue) {
              controller.isShowEmoji.value = false;
            } else {
              Navigator.pop(context);
            }
            return Future.value(false);
          },
          child: DecoratedBox(
            decoration: BoxDecoration(
                image: DecorationImage(
              image: AssetImage(brightness == Brightness.light
                  ? "assets/logo/bg-ligh.png"
                  : "assets/logo/bg-dark.jpg"),
              fit: BoxFit.cover,
              filterQuality: FilterQuality.high,
            )),
            child: Material(
              color: Colors.transparent,
              child: Column(
                children: [
                  Expanded(
                    child: Container(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                          stream: controller.streamChats(chatId),
                          builder: (contex, snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.active) {
                              var allData = snapshot.data!.docs;
                              Timer(
                                  Duration.zero,
                                  () => controller.scrollC.jumpTo(controller
                                      .scrollC.position.maxScrollExtent));
                              return ListView.builder(
                                controller: controller.scrollC,
                                itemCount: allData.length,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == 0) {
                                    return Column(
                                      children: [
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        Text(
                                          "${allData[index]['groupTime']}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        ItemChat(
                                          lastTime: allData[index]['time'],
                                          isSender: allData[index]
                                                      ['pengirim'] ==
                                                  authC.user.value.email
                                              ? true
                                              : false,
                                          msg: "${allData[index]['msg']}",
                                        ),
                                      ],
                                    );
                                  } else {
                                    if (allData[index]['groupTime'] ==
                                        allData[index - 1]['groupTime']) {
                                      return ItemChat(
                                        lastTime: allData[index]['time'],
                                        isSender: allData[index]['pengirim'] ==
                                                authC.user.value.email
                                            ? true
                                            : false,
                                        msg: "${allData[index]['msg']}",
                                      );
                                    } else {
                                      return Column(
                                        children: [
                                          Text(
                                            "${allData[index]['groupTime']}",
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          ItemChat(
                                            lastTime: allData[index]['time'],
                                            isSender: allData[index]
                                                        ['pengirim'] ==
                                                    authC.user.value.email
                                                ? true
                                                : false,
                                            msg: "${allData[index]['msg']}",
                                          ),
                                        ],
                                      );
                                    }
                                  }
                                },
                              );
                            }
                            return Center(
                              child: CircularProgressIndicator(),
                            );
                          }),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.only(
                        bottom: context.mediaQueryPadding.bottom),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            autocorrect: false,
                            controller: controller.chatC,
                            focusNode: controller.focusNote,
                            onEditingComplete: () {
                              return controller.newChat(
                                authC.user.value.email!,
                                Get.arguments as Map<String, dynamic>,
                                controller.chatC.text,
                              );
                            },
                            decoration: InputDecoration(
                              prefixIcon: IconButton(
                                  onPressed: () {
                                    controller.focusNote.unfocus();
                                    controller.isShowEmoji.toggle();
                                  },
                                  icon: Icon(Icons.emoji_emotions)),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                                borderSide: BorderSide(
                                  color: Colors.blue.shade400,
                                ),
                              ),
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 18),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.blue[400],
                            padding: EdgeInsets.all(15),
                          ),
                          onPressed: () {
                            return controller.newChat(
                              authC.user.value.email!,
                              Get.arguments as Map<String, dynamic>,
                              controller.chatC.text,
                            );
                          },
                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Obx(
                    () => (controller.isShowEmoji.isTrue)
                        ? Container(
                            height: 325,
                            child: EmojiPicker(
                              onEmojiSelected: (category, Emoji emoji) {
                                controller.addEmojiToChat(emoji);
                              },
                              onBackspacePressed: () {
                                controller.deleteEmoji();
                              },
                              config: const Config(
                                columns: 7,
                                verticalSpacing: 0,
                                horizontalSpacing: 0,
                                gridPadding: EdgeInsets.zero,
                                initCategory: Category.RECENT,
                                bgColor: Color(0xFFF2F2F2),
                                indicatorColor: Colors.blue,
                                iconColor: Colors.grey,
                                iconColorSelected: Colors.blue,
                                backspaceColor: Colors.blue,
                                skinToneDialogBgColor: Colors.white,
                                skinToneIndicatorColor: Colors.grey,
                                enableSkinTones: true,
                                recentTabBehavior: RecentTabBehavior.RECENT,
                                recentsLimit: 28,
                                noRecents: Text(
                                  'No Recents',
                                  style: TextStyle(
                                      fontSize: 20, color: Colors.black26),
                                  textAlign: TextAlign.center,
                                ), // Needs to be const Widget
                                loadingIndicator: SizedBox
                                    .shrink(), // Needs to be const Widget
                                tabIndicatorAnimDuration: kTabScrollDuration,
                                categoryIcons: CategoryIcons(),
                                buttonMode: ButtonMode.MATERIAL,
                              ),
                            ),
                          )
                        : const SizedBox(),
                  )
                ],
              ),
            ),
          ),
        ));
  }
}

class ItemChat extends StatelessWidget {
  const ItemChat({
    super.key,
    required this.isSender,
    required this.msg,
    required this.lastTime,
  });

  final bool isSender;
  final String msg;
  final String lastTime;

  @override
  Widget build(BuildContext context) {
    final Brightness brightness = Theme.of(context).brightness;
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 20,
      ),
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment:
            isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              color: brightness == Brightness.light
                  ? isSender
                      ? Colors.blue.shade400
                      : Colors.white
                  : isSender
                      ? Colors.blue.shade400
                      : Color(0xFF10212A),
              borderRadius: isSender
                  ? const BorderRadius.only(
                      bottomLeft: Radius.circular(13),
                      topLeft: Radius.circular(13),
                      topRight: Radius.circular(13),
                    )
                  : const BorderRadius.only(
                      bottomRight: Radius.circular(13),
                      topLeft: Radius.circular(13),
                      topRight: Radius.circular(13),
                    ),
            ),
            padding: const EdgeInsets.all(10),
            child: Text(
              msg,
              textWidthBasis: TextWidthBasis.longestLine,
              style: TextStyle(
                color: brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
              ),
            ),
          ),
          Text(DateFormat.jm().format(DateTime.parse(lastTime))),
        ],
      ),
    );
  }
}

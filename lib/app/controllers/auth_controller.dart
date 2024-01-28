import 'package:chatapp/app/data/models/users_model.dart';
import 'package:chatapp/app/routes/app_pages.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthController extends GetxController {
  final isSkipIntro = false.obs;
  final isLoading = false.obs;
  final isAuth = false.obs;

  final GoogleSignIn _googleSignIn = GoogleSignIn();
  GoogleSignInAccount? _currentUser;
  UserCredential? userCredential;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  final user = UsersModel().obs;
  final friendUser = UsersModel().obs;

  Future<void> firstInitializes() async {
    await autoLogin().then(
      (value) {
        if (value) {
          isAuth.value = true;
        }
      },
    );

    await skipIntro().then((value) {
      if (value) {
        isSkipIntro.value = true;
      }
    });
    update();
  }

  Future<bool> skipIntro() async {
    final box = GetStorage();
    if (box.read("skipIntro") != null) {
      return true;
    }
    return false;
  }

  Future<bool> autoLogin() async {
    try {
      final isSignIn = await _googleSignIn.isSignedIn();

      if (!isSignIn) {
        return false;
      }

      await _googleSignIn
          .signInSilently()
          .then((value) => _currentUser = value);

      final GoogleSignInAuthentication? googleAuth =
          await _currentUser!.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .then((value) => userCredential = value);

      CollectionReference users = firestore.collection("users");

      await users.doc(_currentUser!.email).update({
        "lastSignInTime":
            userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
      });

      final currUser = await users.doc(_currentUser!.email).get();
      final currUserData = currUser.data() as Map<String, dynamic>;

      user(UsersModel.fromJson(currUserData));
      user.refresh();
      final listChats =
          await users.doc(_currentUser!.email).collection("chats").get();

      if (listChats.docs.length != 0) {
        List<ChatsUser> dataListChats = [];
        listChats.docs.forEach((element) {
          var dataDocChat = element.data();
          var dataDocChatId = element.id;
          dataListChats.add(ChatsUser(
            chatId: dataDocChatId,
            connection: dataDocChat["connection"],
            lastTime: dataDocChat["lastTime"],
            total_unread: dataDocChat["total_unread"],
          ));
        });
        user.update((user) {
          user!.chats = dataListChats;
        });
      } else {
        user.update((user) {
          user!.chats = [];
        });
      }
      user.refresh();

      final box = GetStorage();
      if (box.read("isLogin") != false) {
        return true;
      }
      return false;
    } catch (err) {
      return false;
    }
  }

  Future<void> login() async {
    try {
      // await _googleSignIn.signOut();
      await _googleSignIn.signIn().then((value) => _currentUser = value);
      final isSignIn = await _googleSignIn.isSignedIn();

      if (isSignIn) {
        isLoading.value = true;
        print(_currentUser);

        final GoogleSignInAuthentication? googleAuth =
            await _currentUser?.authentication;

        print("usercredential");
        print(googleAuth?.idToken);

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth?.accessToken,
          idToken: googleAuth?.idToken,
        );
        await FirebaseAuth.instance
            .signInWithCredential(credential)
            .then((value) => userCredential = value);

        // SIMPAN STATUS USER BAHWA SUDAH PERNAH LOGIN DAN TIDAK AKAN MENAMPiLKAN INTRODUCTION KEMBALI
        final box = GetStorage();
        if (box.read("skipIntro") != null) {
          box.remove("skipIntro");
        }
        box.write("skipIntro", true);
        box.write("isLogin", true);

        // masukan data ke firebase
        CollectionReference users = firestore.collection("users");

        final checkUsers = await users.doc(_currentUser!.email).get();

        if (checkUsers.data() == null) {
          await users.doc(_currentUser!.email).set({
            "uid": userCredential!.user!.uid,
            "name": _currentUser!.displayName,
            "keyName": _currentUser!.displayName!.substring(0, 1).toUpperCase(),
            "email": _currentUser!.email,
            "photoUrl": _currentUser!.photoUrl ?? "noimage",
            "status": "",
            "createTime":
                userCredential!.user!.metadata.creationTime!.toIso8601String(),
            "lastSignInTime": userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
            "updatedTime": DateTime.now().toIso8601String(),
          });
          await users.doc(_currentUser!.email).collection("chats");
        } else {
          await users.doc(_currentUser!.email).update({
            "lastSignInTime": userCredential!.user!.metadata.lastSignInTime!
                .toIso8601String(),
          });
        }

        final currUser = await users.doc(_currentUser!.email).get();
        final currUserData = currUser.data() as Map<String, dynamic>;

        user(UsersModel.fromJson(currUserData));
        user.refresh();
        final listChats =
            await users.doc(_currentUser!.email).collection("chats").get();

        if (listChats.docs.length != 0) {
          List<ChatsUser> dataListChats = [];
          listChats.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatsUser(
              chatId: dataDocChatId,
              connection: dataDocChat["connection"],
              lastTime: dataDocChat["lastTime"],
              total_unread: dataDocChat["total_unread"],
            ));
          });
          user.update((user) {
            user!.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }
        user.refresh();
        isAuth.value = true;
        isLoading.value = false;
        print(isLoading);
        Get.offAllNamed(Routes.HOME);
      } else {
        print("tidak berhasil Login dengan akun:");
      }
    } catch (error) {
      print(error);
    }
  }

  Future<void> logout() async {
    await _googleSignIn.disconnect();
    await _googleSignIn.signOut();

    Get.toNamed(Routes.LOGIN);
  }

// profile
  void changeProfile(String nama, String status) {
    String date = DateTime.now().toIso8601String();

    // update firebase
    CollectionReference users = firestore.collection("users");

    users.doc(_currentUser!.email).update({
      "name": nama,
      "keyName": nama.substring(0, 1).toUpperCase(),
      "status": status,
      "updateTime": date,
      "lastSignInTime":
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
    });

    // update model
    user.update((data) {
      data!.name = nama;
      data.keyName = nama.substring(0, 1).toUpperCase();
      data.status = status;
      data.lastSignInTime =
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String();
      data.updatedTime = date;
    });

    user.refresh();
    Get.snackbar("Update data", "update data berhasil",
        duration: Duration(seconds: 2));
  }

  void updateStatus(String status) {
    String date = DateTime.now().toIso8601String();

    CollectionReference users = firestore.collection("users");

    users.doc(_currentUser!.email).update({
      "status": status,
      "lastSignInTime":
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String(),
    });

    // update model
    user.update((data) {
      data!.status = status;
      data.lastSignInTime =
          userCredential!.user!.metadata.lastSignInTime!.toIso8601String();
      data.updatedTime = date;
    });

    user.refresh();
    Get.snackbar("Success", "update status berhasil",
        backgroundColor: Colors.white,
        colorText: Colors.black,
        duration: Duration(seconds: 2));
  }

  void updatePhotoUrl(String url) async {
    String date = DateTime.now().toIso8601String();

    CollectionReference users = firestore.collection("users");

    await users.doc(_currentUser!.email).update({
      "photoUrl": url,
      "updatedTime": date,
    });

    // update model
    user.update((data) {
      data!.photoUrl = url;
      data.updatedTime = date;
    });

    user.refresh();
    Get.snackbar("Success", "Foto Profile Berhasil Di update",
        duration: Duration(seconds: 2));
  }

//  SEARCH
  void addNewConnection(String friendEmail) async {
    bool flagNewConnection = false;
    String date = DateTime.now().toIso8601String();
    CollectionReference chats = firestore.collection("chats");
    CollectionReference users = firestore.collection("users");
    var chatId;
    final docChats =
        await users.doc(_currentUser!.email).collection("chats").get();

    if (docChats.docs.length != 0) {
      // user sudah pernah chat dengan siapapun
      final checkConnection = await users
          .doc(_currentUser!.email)
          .collection("chats")
          .where("connection", isEqualTo: friendEmail)
          .get();

      if (checkConnection.docs.length != 0) {
        // sudah pernah buat koneksi dengan friendEmail
        flagNewConnection = false;
        chatId = checkConnection.docs[0].id;
      } else {
        // belum pernah chat siapa pun
        flagNewConnection = true;
      }
    } else {
      // belum pernah chat siapa pun
      flagNewConnection = true;
    }
    // FIXXING COLECTION CHAT

    if (flagNewConnection) {
      final chatDocs = await chats.where("connection", whereIn: [
        [
          _currentUser!.email,
          friendEmail,
        ],
        [
          friendEmail,
          _currentUser!.email,
        ],
      ]).get();

      if (chatDocs.docs.length != 0) {
        // terdapat data chats
        final chatDataId = chatDocs.docs[0].id;
        final chatsData = chatDocs.docs[0].data() as Map<String, dynamic>;

        await users
            .doc(_currentUser!.email)
            .collection("chats")
            .doc(chatDataId)
            .set({
          "connection": friendEmail,
          "lastTime": chatsData["lastTime"],
          "total_unread": 0,
        });

        final listChats =
            await users.doc(_currentUser!.email).collection("chats").get();

        if (listChats.docs.length != 0) {
          List<ChatsUser> dataListChats = List<ChatsUser>.empty().toList();
          listChats.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatsUser(
              chatId: dataDocChatId,
              connection: dataDocChat["connection"],
              lastTime: dataDocChat["lastTime"],
              total_unread: dataDocChat["total_unread"],
            ));
          });
          user.update((user) {
            user!.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }

        chatId = chatDataId;
        user.refresh();
      } else {
        // buat baru chats(belum ada koneksi )
        final newChatDoc = await chats.add({
          "connection": [
            _currentUser!.email,
            friendEmail,
          ],
        });

        await chats.doc(newChatDoc.id).collection("chat");

        await users
            .doc(_currentUser!.email)
            .collection("chats")
            .doc(newChatDoc.id)
            .set({
          "connection": friendEmail,
          "lastTime": date,
          "total_unread": 0,
        });

        final listChats =
            await users.doc(_currentUser!.email).collection("chats").get();

        if (listChats.docs.length != 0) {
          List<ChatsUser> dataListChats = List<ChatsUser>.empty();
          listChats.docs.forEach((element) {
            var dataDocChat = element.data();
            var dataDocChatId = element.id;
            dataListChats.add(ChatsUser(
              chatId: dataDocChatId,
              connection: dataDocChat["connection"],
              lastTime: dataDocChat["lastTime"],
              total_unread: dataDocChat["total_unread"],
            ));
          });
          user.update((user) {
            user!.chats = dataListChats;
          });
        } else {
          user.update((user) {
            user!.chats = [];
          });
        }

        chatId = newChatDoc.id;
        user.refresh();
      }
    }

    final updateStatusChat = await chats
        .doc(chatId)
        .collection("chat")
        .where("isRead", isEqualTo: false)
        .where("penerima", isEqualTo: _currentUser!.email)
        .get();
    updateStatusChat.docs.forEach((element) async {
      await chats.doc(chatId).collection("chat").doc(element.id).update({
        "isRead": true,
      });
    });

    await users
        .doc(_currentUser!.email)
        .collection("chats")
        .doc(chatId)
        .update({
      "total_unread": 0,
    });
    Get.toNamed(Routes.CHAT_ROOM, arguments: {
      "chat_id": "$chatId",
      "friendEmail": friendEmail,
      "friendUserModel": friendUser.value,
    });
  }
}

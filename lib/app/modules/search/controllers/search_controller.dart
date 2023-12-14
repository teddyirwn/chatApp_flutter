import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  late TextEditingController searchC;

  final query = [].obs;
  final tempSearch = [].obs;

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  void search(String keyword, String email) async {
    print("search: $keyword");
    if (keyword.length == 0) {
      query.value = [];
      tempSearch.value = [];
    } else {
      var capitalized =
          keyword.substring(0, 1).toUpperCase() + keyword.substring(1);

      if (query.length == 0 && keyword.length == 1) {
        CollectionReference users = await firestore.collection("users");
        final keyNameResult = await users
            .where("keyName", isEqualTo: keyword.substring(0, 1).toUpperCase())
            .where("email", isNotEqualTo: email)
            .get();

        print("Total data :${keyNameResult.docs.length}");

        if (keyNameResult.docs.length > 0) {
          for (int i = 0; i < keyNameResult.docs.length; i++) {
            query.add(keyNameResult.docs[i].data() as Map<String, dynamic>);
          }
          print("Query Resauld: ");
          print(query);
        } else {
          print("TIDAK ADA DATA");
        }
      }

      if (query.length != 0) {
        tempSearch.value = [];
        query.forEach((data) {
          tempSearch.add(data);
        });
      }
    }
    query.refresh();
    tempSearch.refresh();
  }

  @override
  void onInit() {
    searchC = TextEditingController();
    super.onInit();
  }

  @override
  void onClose() {
    searchC.dispose();
    super.onClose();
  }
}

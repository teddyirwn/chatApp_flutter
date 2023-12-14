class UsersModel {
  String? uid;
  String? name;
  String? keyName;
  String? email;
  String? createTime;
  String? lastSignInTime;
  String? photoUrl;
  String? status;
  String? updatedTime;
  List<ChatsUser>? chats;

  UsersModel(
      {this.uid,
      this.name,
      this.keyName,
      this.email,
      this.createTime,
      this.lastSignInTime,
      this.photoUrl,
      this.status,
      this.updatedTime,
      this.chats});

  UsersModel.fromJson(Map<String, dynamic> json) {
    uid = json['uid'];
    name = json['name'];
    keyName = json['keyName'];
    email = json['email'];
    createTime = json['createTime'];
    lastSignInTime = json['lastSignInTime'];
    photoUrl = json['photoUrl'];
    status = json['status'];
    updatedTime = json['updatedTime'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['uid'] = uid;
    data['name'] = name;
    data['keyName'] = keyName;
    data['email'] = email;
    data['createTime'] = createTime;
    data['lastSignInTime'] = lastSignInTime;
    data['photoUrl'] = photoUrl;
    data['status'] = status;
    data['updatedTime'] = updatedTime;

    return data;
  }
}

class ChatsUser {
  String? connection;
  String? chatId;
  String? lastTime;
  int? total_unread;

  ChatsUser({
    this.connection,
    this.chatId,
    this.lastTime,
    this.total_unread,
  });

  ChatsUser.fromJson(Map<String, dynamic> json) {
    connection = json['connection'];
    chatId = json['chat_id'];
    lastTime = json['lastTime'];
    total_unread = json['total_unread'];
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['connection'] = connection;
    data['chat_id'] = chatId;
    data['lastTime'] = lastTime;
    data['total_unread'] = total_unread;
    return data;
  }
}

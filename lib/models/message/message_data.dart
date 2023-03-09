class MessageData{
  String id;
  String toId;
  String msg;
  String read;
  Type type;
  String fromId;
  DateTime? messageDate;

  MessageData({
    this.id = "",
    this.toId = "",
    this.msg = "",
    this.read = "",
    this.type = Type.text,
    this.fromId = "",
    this.messageDate,
  });

  factory MessageData.fromMap(Map<String, dynamic> map){
    return MessageData(
      id: map["id"] ?? "",
      toId: map["toId"] ?? "",
      msg: map["msg"] ?? "",
      read: map["read"] ?? "",
      type: map["type"].toString() == Type.image.name ? Type.image : Type.text,
      fromId: map["fromId"] ?? "",
      messageDate: map["messageDate"].toDate(),
    );
  }

  factory MessageData.fromMapNotif(Map<String, dynamic> map){
    return MessageData(
      id: map["id"] ?? "",
      toId: map["toId"] ?? "",
      msg: map["msg"] ?? "",
      read: map["read"] ?? "",
      type: map["type"].toString() == Type.image.name ? Type.image : Type.text,
      fromId: map["fromId"] ?? "",
      messageDate: map["messageDate"],
    );
  }

  Map<String, dynamic> toMap(){
    return {
      "id" : id,
      "toId" : toId,
      "msg" : msg,
      "read" : read,
      "type" : type.name,
      "fromId" : fromId,
      "messageDate" : messageDate,
    };
  }
}

enum Type {text, image}
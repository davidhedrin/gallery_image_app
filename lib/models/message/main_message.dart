class MainMessage{
  String chatId;
  List<String>? userId;
  String chatGroup;

  MainMessage({
    this.chatId = "",
    this.chatGroup = "",
    this.userId,
  });

  factory MainMessage.fromMap(Map<String, dynamic> map){
    return MainMessage(
      chatId: map["chatId"] ?? "",
      chatGroup: map["chatGroup"] ?? "",
      userId: List<String>.from(map['userId'].map((e) => e.toString())),
    );
  }

  Map<String, dynamic> toMap(){
    return {
      "chatId" : chatId,
      "chatGroup" : chatGroup,
      "userId" : userId
    };
  }
}
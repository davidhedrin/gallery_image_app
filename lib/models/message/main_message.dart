class MainMessage{
  String chatId;
  List<String>? userId;

  MainMessage({
    this.chatId = "",
    this.userId,
  });

  factory MainMessage.fromMap(Map<String, dynamic> map){
    return MainMessage(
      chatId: map["chatId"] ?? "",
      userId: List<String>.from(map['userId'].map((e) => e.toString())),
    );
  }

  Map<String, dynamic> toMap(){
    return {
      "chatId" : chatId,
      "userId" : userId
    };
  }
}
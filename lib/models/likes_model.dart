class LikesModel{
  String by;
  String id;

  LikesModel({this.by = "", this.id = ""});

  factory LikesModel.fromMap(Map<String, dynamic> map){
    return LikesModel(
      by: map["by"] ?? "",
      id: map["id"] ?? "",
    );
  }

  Map<String, dynamic> toMapUpload(){
    return {
      "by" : by,
      "id" : id,
    };
  }
}
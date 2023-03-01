class UserMasterModel{
  String nama;
  String phone;
  List<GroupModel>? group;
  DateTime? create_date;

  UserMasterModel({
    this.nama = "",
    this.phone = "",
    this.group,
    this.create_date,
  });

  factory UserMasterModel.fromMap(Map<String, dynamic> map){
    List<GroupModel> groupList = [];
    List<Map<String, dynamic>> data = List<Map<String, dynamic>>.from(map['group']);
    for (Map<String, dynamic> map in data) {
      GroupModel group = GroupModel.fromMap(map);
      groupList.add(group);
    }
    return UserMasterModel(
      nama : map["nama"] ?? "",
      phone : map["phone"] ?? "",
      group : groupList,
      create_date : map["create_date"].toDate(),
    );
  }

  Map<String, dynamic> toMapUpload(){
    return {
      "nama": nama,
      "phone": phone,
      "group": group,
    };
  }
}

class GroupModel{
  String group_id;
  String nama_group;
  String status;

  GroupModel({this.nama_group = "", this.group_id = "", this.status = ""});

  factory GroupModel.fromMap(Map<String, dynamic> map){
    return GroupModel(
      group_id : map["group_id"] ?? "",
      nama_group : map["nama_group"] ?? "",
      status : map["status"] ?? "",
    );
  }
}
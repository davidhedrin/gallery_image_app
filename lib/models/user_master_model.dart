class UserMasterModel{
  String nama;
  String phone;
  List<GroupModel>? group;
  List<Map<String, dynamic>>? groupMap;
  DateTime? createDate;

  UserMasterModel({
    this.nama = "",
    this.phone = "",
    this.group,
    this.createDate,
    this.groupMap,
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
      groupMap: data,
      createDate : map["create_date"].toDate(),
    );
  }

  Map<String, dynamic> toMapUpload(){
    return {
      "nama": nama,
      "phone": phone,
      "group": groupMap,
      "create_date": createDate
    };
  }
}

class GroupModel{
  String groupId;
  String namaGroup;
  String status;

  GroupModel({this.namaGroup = "", this.groupId = "", this.status = ""});

  factory GroupModel.fromMap(Map<String, dynamic> map){
    return GroupModel(
      groupId : map["group_id"] ?? "",
      namaGroup : map["nama_group"] ?? "",
      status : map["status"] ?? "",
    );
  }

  Map<String, dynamic> toMapUpload(){
    return{
      "group_id": groupId,
      "nama_group": namaGroup,
      "status": status,
    };
  }
}
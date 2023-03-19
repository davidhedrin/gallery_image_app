class UserGroupMasterModel{
  String groupId;
  String namaGroup;
  DateTime? createDate;

  UserGroupMasterModel({
    this.namaGroup = "",
    this.groupId = "",
    this.createDate,
  });

  factory UserGroupMasterModel.fromMap(Map<String, dynamic> map) {
    return UserGroupMasterModel(
      groupId: map['group_id'] ?? '',
      namaGroup: map['nama_group'] ?? '',
      createDate: map['create_date'].toDate() ?? '',
    );
  }

  Map<String, dynamic> toMapUpload(){
    return {
      "group_id": groupId,
      "nama_group": namaGroup,
      "create_date": createDate
    };
  }
}
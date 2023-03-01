class UserGroupMasterModel{
  String group_id;
  String nama_group;
  DateTime? create_date;

  UserGroupMasterModel({
    this.nama_group = "",
    this.group_id = "",
    this.create_date,
  });

  factory UserGroupMasterModel.fromMap(Map<String, dynamic> map) {
    return UserGroupMasterModel(
      group_id: map['group_id'] ?? '',
      nama_group: map['nama_group'] ?? '',
      create_date: map['create_date'].toDate() ?? '',
    );
  }

  Map<String, dynamic> toMapUpload(){
    return {
      "group_id": group_id,
      "nama_group": nama_group,
      "create_date": create_date
    };
  }
}
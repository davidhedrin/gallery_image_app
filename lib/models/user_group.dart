class UserGroupModel{
  String groupId;
  String status;
  String namaGroup;

  UserGroupModel({
    this.status = "",
    this.namaGroup = "",
    this.groupId = "",
  });

  factory UserGroupModel.fromMap(Map<String, dynamic> map) {
    return UserGroupModel(
      groupId: map['group_id'] ?? '',
      namaGroup: map['nama_group'] ?? '',
      status: map['status'] ?? '',
    );
  }

  // Map<String, dynamic> toMap(){
  //   return {
  //     "id": id,
  //     "nama_group": nama_group,
  //     "create_date": create_date
  //   };
  // }
}
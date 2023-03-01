class UserGroupModel{
  String group_id;
  String status;
  String nama_group;

  UserGroupModel({
    this.status = "",
    this.nama_group = "",
    this.group_id = "",
  });

  factory UserGroupModel.fromMap(Map<String, dynamic> map) {
    return UserGroupModel(
      group_id: map['group_id'] ?? '',
      nama_group: map['nama_group'] ?? '',
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
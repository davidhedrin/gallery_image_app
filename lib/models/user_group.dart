class UserGroupModel{
  String nama_group;
  String id;

  UserGroupModel({
    this.nama_group = "",
    this.id = "",
  });

  factory UserGroupModel.fromMap(Map<String, dynamic> map) {
    return UserGroupModel(
      id: map['id'] ?? '',
      nama_group: map['nama_group'] ?? '',
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
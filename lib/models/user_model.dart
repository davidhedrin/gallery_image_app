class UserModel{
  String email;
  String flag_active;
  String id;
  String nama_lengkap;
  String password;
  String phone;
  String uidEmail;
  String uidPhone;
  String user_type;
  String img_profil_url;
  String img_cover_url;
  DateTime? create_date;
  DateTime? lastOnline;
  String statusLog;
  String pushToken;

  UserModel({
    this.email = "",
    this.flag_active = "",
    this.id = "",
    this.nama_lengkap = "",
    this.password = "",
    this.phone = "",
    this.uidEmail = "",
    this.uidPhone = "",
    this.user_type = "",
    this.img_profil_url = "",
    this.img_cover_url = "",
    this.statusLog = "",
    this.create_date,
    this.lastOnline,
    this.pushToken = "",
  });

  factory UserModel.fromMap(Map<String, dynamic> map){
    return UserModel(
      email : map['email'] ?? '',
      flag_active : map['flag_active'] ?? '',
      id : map['id'] ?? '',
      nama_lengkap : map['nama_lengkap'] ?? '',
      password : map['password'] ?? '',
      phone : map['phone'] ?? '',
      uidEmail : map['uidEmail'] ?? '',
      uidPhone : map['uidPhone'] ?? '',
      user_type : map['user_type'] ?? '',
      img_profil_url : map['img_profil_url'] ?? '',
      img_cover_url : map['img_cover_url'] ?? '',
      statusLog : map['statusLog'] ?? '',
      create_date: map['create_date'].toDate(),
      lastOnline: map['lastOnline'].toDate(),
      pushToken: map['pushToken'] ?? "",
    );
  }

  Map<String, dynamic> toMap(){
    return {
      "id": id,
      "email": email,
      "flag_active": flag_active,
      "nama_lengkap": nama_lengkap,
      "password": password,
      "phone": phone,
      "uidEmail": uidEmail,
      "uidPhone": uidPhone,
      "user_type": user_type,
      "statusLog": statusLog,
      "create_date": create_date,
      "lastOnline": lastOnline,
      "pushToken": pushToken,
    };
  }

  Map<String, dynamic> toMapUpdate(){
    return {
      "email": email,
      "nama_lengkap": nama_lengkap,
      "password": password,
      "img_profil_url": img_profil_url,
      "img_cover_url": img_cover_url
      // "user_type": user_type,
      // "phone": phone,
    };
  }
}
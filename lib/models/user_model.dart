class UserModel{
  String email;
  String flagActive;
  String id;
  String namaLengkap;
  String password;
  String phone;
  String uidEmail;
  String uidPhone;
  String userType;
  String imgProfilUrl;
  String imgCoverUrl;
  DateTime? createDate;
  DateTime? lastOnline;
  String statusLog;
  String pushToken;

  UserModel({
    this.email = "",
    this.flagActive = "",
    this.id = "",
    this.namaLengkap = "",
    this.password = "",
    this.phone = "",
    this.uidEmail = "",
    this.uidPhone = "",
    this.userType = "",
    this.imgProfilUrl = "",
    this.imgCoverUrl = "",
    this.statusLog = "",
    this.createDate,
    this.lastOnline,
    this.pushToken= "",
  });

  factory UserModel.fromMap(Map<String, dynamic> map){
    return UserModel(
      email : map['email'] ?? '',
      flagActive : map['flag_active'] ?? '',
      id : map['id'] ?? '',
      namaLengkap : map['nama_lengkap'] ?? '',
      password : map['password'] ?? '',
      phone : map['phone'] ?? '',
      uidEmail : map['uidEmail'] ?? '',
      uidPhone : map['uidPhone'] ?? '',
      userType : map['user_type'] ?? '',
      imgProfilUrl : map['img_profil_url'] ?? '',
      imgCoverUrl : map['img_cover_url'] ?? '',
      statusLog : map['statusLog'] ?? '',
      createDate: map['create_date'].toDate(),
      lastOnline: map['lastOnline'].toDate(),
      pushToken: map['pushToken'] ?? '',
    );
  }

  Map<String, dynamic> toMap(){
    return {
      "id": id,
      "email": email,
      "flag_active": flagActive,
      "nama_lengkap": namaLengkap,
      "password": password,
      "phone": phone,
      "uidEmail": uidEmail,
      "uidPhone": uidPhone,
      "user_type": userType,
      "statusLog": statusLog,
      "create_date": createDate,
      "lastOnline": lastOnline,
      "pushToken": pushToken,
    };
  }

  Map<String, dynamic> toMapUpdate(){
    return {
      "email": email,
      "nama_lengkap": namaLengkap,
      "img_profil_url": imgProfilUrl,
      "img_cover_url": imgCoverUrl,
      // "user_type": user_type,
      // "phone": phone,
    };
  }
}
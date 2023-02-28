class PostingImageModel{
  String imageId;
  String userById;
  String userByName;
  String title;
  String pemirsa;
  DateTime? tanggal;
  DateTime? uploadDate;
  String? keterangan;
  String imageUrl;
  String imageGroup;

  PostingImageModel({
    this.imageId = "",
    this.imageUrl = "",
    this.title = "",
    this.pemirsa = "",
    this.userById = "",
    this.userByName = "",
    this.tanggal,
    this.uploadDate,
    this.keterangan,
    this.imageGroup = "",
  });

  factory PostingImageModel.fromMap(Map<String, dynamic> map) {
    return PostingImageModel(
      imageId: map['imageId'] ?? '',
      userById: map['userById'] ?? '',
      userByName: map['userByName'] ?? '',
      title: map['title'] ?? '',
      pemirsa: map['pemirsa'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      tanggal: map['tanggal'].toDate() ?? '',
      uploadDate: map['uploadDate'].toDate() ?? '',
      keterangan: map['keterangan'] ?? '',
      imageGroup: map['imageGroup'] ?? '',
    );
  }

  Map<String, dynamic> toMapUpload(){
    return {
      "imageId" : imageId,
      "userById" : userById,
      "userByName" : userByName,
      "title" : title,
      "pemirsa" : pemirsa,
      "imageUrl" : imageUrl,
      "tanggal" : tanggal,
      "uploadDate" : uploadDate,
      "keterangan" : keterangan,
      "imageGroup" : imageGroup,
    };
  }
}
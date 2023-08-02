class UserModel {
  final String name;
  final String uid;
  final String profilePic;
  final String phoneNumber;
  final bool isOnline;
  final List<dynamic> groupId;

  UserModel({
    required this.name,
    required this.uid,
    required this.profilePic,
    required this.phoneNumber,
    required this.isOnline,
    required this.groupId,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      name: map['name'] ?? '',
      uid: map['uid'] ?? '',
      profilePic: map['profilePic'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      isOnline: map['isOnline'] ?? '',
      groupId: map['groupId'] ?? {},
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uid': uid,
      'profilePic': profilePic,
      'isOnline': isOnline,
      'phoneNumber': phoneNumber,
      'groupId': groupId,
    };
  }
}

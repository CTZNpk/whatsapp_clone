class Status {
  final String uid;
  String username;
  final String phoneNumber;
  final List<String> photoUrl;
  final DateTime createdAt;
  final String profilepic;
  final String statusId;
  final List<String> whoCanSee;

  Status({
    required this.uid,
    required this.username,
    required this.phoneNumber,
    required this.photoUrl,
    required this.createdAt,
    required this.profilepic,
    required this.statusId,
    required this.whoCanSee,
  });

  factory Status.fromMap(Map<String, dynamic> map) {
    return Status(
      uid: map['uid'] ?? '',
      username: map['username'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
      photoUrl: List<String>.from(map['photoUrl']),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt']),
      profilepic: map['profilepic'] ?? '',
      statusId: map['statusId'] ?? '',
      whoCanSee: List<String>.from(map['whoCanSee']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'phoneNumber': phoneNumber,
      'photoUrl': photoUrl,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'profilepic': profilepic,
      'statusId': statusId,
      'whoCanSee': whoCanSee,
    };
  }
}

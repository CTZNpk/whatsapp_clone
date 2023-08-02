class ContactModel {
  final String name;
  final String profilePic;
  final String phoneNumber;
  final String uid;

  ContactModel({
    required this.uid,
    required this.name,
    required this.profilePic,
    required this.phoneNumber,
  });

  factory ContactModel.fromMap(Map<String, dynamic> map) {
    return ContactModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      profilePic: map['profilePic'] ?? '',
      phoneNumber: map['phoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'uid': uid,
      'profilePic': profilePic,
      'phoneNumber': phoneNumber,
    };
  }
}

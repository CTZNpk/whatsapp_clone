class Group {
  final String senderId;
  final String name;
  final String groupId;
  final String lastmessage;
  final String groupPic;
  final DateTime timeSent;
  final List<dynamic> membersUid;

  Group({
    required this.senderId,
    required this.name,
    required this.groupId,
    required this.lastmessage,
    required this.groupPic,
    required this.membersUid,
    required this.timeSent,
  });

  factory Group.fromMap(Map<String, dynamic> map) {
    return Group(
      senderId: map['senderId'] ?? '',
      name: map['name'] ?? '',
      groupId: map['groupId'] ?? '',
      lastmessage: map['lastmessage'] ?? '',
      groupPic: map['groupPic'] ?? '',
      membersUid: List<String>.from(map['membersUid']),
      timeSent: DateTime.fromMillisecondsSinceEpoch(map['timeSent']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'name': name,
      'lastmessage': lastmessage,
      'groupPic': groupPic,
      'membersUid': membersUid,
      'groupId': groupId,
      'timeSent': timeSent.millisecondsSinceEpoch,
    };
  }
}


class MessageRoom {
  final String id;
  final List<String> userIds;
  final String lastMessage;
  final String lastTimestamp;

  const MessageRoom({
    required this.id,
    required this.userIds,
    required this.lastMessage,
    required this.lastTimestamp,
  });

  Map<String, dynamic> toMap() => {
    'participants': userIds,
    'lastMessage': lastMessage,
    'lastTimestamp': lastTimestamp,
  };

  factory MessageRoom.fromMap(String id, Map<String, dynamic> map) {
    return MessageRoom(
      id: id,
      userIds: List<String>.from(map['participants'] ?? const []),
      lastMessage: (map['lastMessage'] ?? '') as String,
      lastTimestamp: (map['lastTimestamp'] ?? '') as String,
    );
  }
}

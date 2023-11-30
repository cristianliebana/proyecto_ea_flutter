 class Room {
  final String userId1;
  final String userId2;

  Room({
    required this.userId1,
    required this.userId2,
  });

  factory Room.fromJson(Map<String, dynamic> json) {
    return Room(
      userId1: json['userId1'] ?? '',
      userId2: json['userId2'] ?? '',
    );
  }
}

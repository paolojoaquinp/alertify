class Friendship {
  const Friendship({
    required this.id,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.sender,
    required this.users,
  }); // id del que envia la solicitud.

  final String id;
  final FriendshipStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String sender;
  final List<String> users;
}

enum FriendshipStatus {
  pending,
  active,
  archived,
}

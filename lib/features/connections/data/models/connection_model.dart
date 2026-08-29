class ConnectionProfile {
  const ConnectionProfile({
    required this.id,
    required this.username,
    this.fullName,
    this.avatarUrl,
  });

  final String id;
  final String username;
  final String? fullName;
  final String? avatarUrl;

  factory ConnectionProfile.fromJson(Map<String, dynamic> json) {
    return ConnectionProfile(
      id: json['id'] as String,
      username: json['username'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }
}

class Connection {
  const Connection({
    required this.id,
    required this.requesterId,
    required this.addresseeId,
    required this.status,
    required this.createdAt,
    required this.requester,
    required this.addressee,
  });

  final String id;
  final String requesterId;
  final String addresseeId;
  final String status; // 'pending' | 'accepted' | 'declined'
  final DateTime createdAt;
  final ConnectionProfile requester;
  final ConnectionProfile addressee;

  /// The profile of the other person, relative to the signed-in user.
  ConnectionProfile otherProfile(String currentUserId) {
    return requesterId == currentUserId ? addressee : requester;
  }

  factory Connection.fromJson(Map<String, dynamic> json) {
    return Connection(
      id: json['id'] as String,
      requesterId: json['requester_id'] as String,
      addresseeId: json['addressee_id'] as String,
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      requester: ConnectionProfile.fromJson(json['requester'] as Map<String, dynamic>),
      addressee: ConnectionProfile.fromJson(json['addressee'] as Map<String, dynamic>),
    );
  }
}
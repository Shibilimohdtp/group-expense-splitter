class InvitedMember {
  final String name;
  final String email;

  InvitedMember({
    required this.name,
    required this.email,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
    };
  }

  factory InvitedMember.fromMap(Map<String, dynamic> map) {
    return InvitedMember(
      name: map['name'] ?? '',
      email: map['email'] ?? '',
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is InvitedMember && other.email == email;
  }

  @override
  int get hashCode => email.hashCode;

  @override
  String toString() => 'InvitedMember(name: $name, email: $email)';
}
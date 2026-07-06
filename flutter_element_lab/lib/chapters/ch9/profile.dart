class Profile {
  const Profile({required this.name, required this.count});

  final String name;
  final int count;

  Profile copyWith({String? name, int? count}) {
    return Profile(
      name: name ?? this.name,
      count: count ?? this.count,
    );
  }
}

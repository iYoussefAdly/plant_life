class UserEntity {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;

  const UserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
  });

  /// Up to two initials for the avatar fallback, e.g. `Youssef Adly` -> `YA`.
  String get initials {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final first = parts.first[0];
    final second = parts.length > 1 ? parts[1][0] : '';
    return (first + second).toUpperCase();
  }
}

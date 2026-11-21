class MemberInfo {
  const MemberInfo({required this.email, required this.nickname, required this.createdAt});
  final String email;
  final String nickname;
  final DateTime createdAt;
  factory MemberInfo.fromJson(Map<String, dynamic> data) => MemberInfo(
    email: data['email'] as String,
    nickname: data['nickname'] as String,
    createdAt: DateTime.parse(data['createdAt'] as String),
  );
}

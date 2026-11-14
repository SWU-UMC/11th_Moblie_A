class SignUpModels {
    const SignUpModels({
        required this.memberId,
        required this.email,
        required this.nickname,
    });

    final int memberId;
    final String email;
    final String nickname;

    factory SignUpModels.fromJson(Map<String, dynamic> json) {
        return SignUpModels(
            memberId: (json['memberId'] as num).toInt(),
            email: json['email'] as String,
            nickname: json['nickname'] as String,
        );
    }
}
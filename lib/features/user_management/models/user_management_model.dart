class UserModelDm {
  final int userId;
  final String username;
  final String fullName;
  final String mobileNo;

  UserModelDm({
    required this.userId,
    required this.username,
    required this.fullName,
    required this.mobileNo,
  });

  factory UserModelDm.fromJson(Map<String, dynamic> json) {
    return UserModelDm(
      userId: json['UserId'],
      username: json['USERNAME'] ?? '',
      fullName: json['FullName'] ?? '',
      mobileNo: json['MobileNo'] ?? '',
    );
  }
}

class UserAccessModelDm {
  final int menuId;
  final String menuName;
  final bool access;

  UserAccessModelDm({
    required this.menuId,
    required this.menuName,
    required this.access,
  });

  factory UserAccessModelDm.fromJson(Map<String, dynamic> json) {
    return UserAccessModelDm(
      menuId: json['MENUID'],
      menuName: json['MENUNAME'] ?? '',
      access: json['Access'] ?? false,
    );
  }
}
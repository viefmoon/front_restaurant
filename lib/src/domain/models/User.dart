import 'Role.dart';

class User {
  int? id;
  String name;
  String username;
  String? password;
  String? notificationToken;
  List<Role>? roles;
  String? roleId;

  User({
    this.id,
    required this.name,
    required this.username,
    this.password,
    this.notificationToken,
    this.roles,
    this.roleId,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"] ?? 0,
        name: json["name"] ?? '',
        username: json["username"] ?? '',
        //password: json["password"] ?? '',
        notificationToken: json["notification_token"] ?? '',
        roles:
            (json["roles"] as List?)?.map((x) => Role.fromJson(x)).toList() ??
                [],
        // roleId: json["roleId"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        //"id": id,
        "name": name,
        "username": username,
        "password": password,
        "notification_token": notificationToken,
        "roles": roles?.map((x) => x.toJson()).toList() ?? [],
        "roleId": roleId,
      };
}

import 'package:shakti/models/enums/AccountType.dart';
import 'package:shakti/models/enums/UserRole.dart';

class User {
  final String id;
  final AccountType accountType;
  final String? profileUrl;
  final String firstName;
  final String? lastName;
  final String username;
  final String email;
  final bool isLocked; // is suspended or not
  final bool isEnabled; //is verified or not
  final bool isDeleted;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? passwordUpdatedAt;
  final Set<UserRole> roles;

  const User({
    required this.id,
    required this.accountType,
    required this.firstName,
    this.profileUrl,
    this.lastName,
    required this.username,
    required this.email,
    required this.isLocked,
    required this.isEnabled,
    required this.isDeleted,
    required this.createdAt,
    required this.updatedAt,
    this.passwordUpdatedAt,
    required this.roles,
});

  factory User.fromJson(Map<String,dynamic> json){
    return User(id: json['id'],
        accountType: AccountType.fromJson(json['accountType']),
        firstName: json['firstName'],
        profileUrl: json['profileUrl'],
        lastName: json['lastName'],
        username: json['username'],
        email: json['email'],
        isLocked: json['locked'],
        isEnabled: json['enabled'],
        isDeleted: json['deleted'],
        createdAt: DateTime.parse(json['createdAt']),
        updatedAt: DateTime.parse(json['updatedAt']),
        passwordUpdatedAt: json['passwordUpdatedAt']!=null ? DateTime.parse(json['passwordUpdatedAt']) : null,
        roles: (json['roles'] as List).map((role)=>UserRole.fromJson(role)).toSet());
  }
}
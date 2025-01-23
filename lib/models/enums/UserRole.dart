enum UserRole {
  ROLE_ADMIN("ROLE_ADMIN"),
  ROLE_USER("ROLE_USER");

  const UserRole(this.role);
  final String role;

  factory UserRole.fromJson(String value,{bool throwOnNull=false}){
    return UserRole.values.firstWhere((role) => role.role==value);
  }
}
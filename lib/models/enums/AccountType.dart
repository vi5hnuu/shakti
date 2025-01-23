enum AccountType {
  GOOGLE("GOOGLE"),
  MANUAL("MANUAL");
  final String type;

  // Constructor
  const AccountType(this.type);

  factory AccountType.fromJson(String value,{bool throwOnNull=false}){
    return AccountType.values.firstWhere((role) => role.type==value);
  }
}

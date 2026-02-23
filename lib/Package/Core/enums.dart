enum OtpForWhat {
  createNewUser,
  resetPassword,
  justVerifyThatNumber,
}

enum EnumTxtBoxType {
  phoneNo,
  password,
  amount,
}

enum EnumNotificationType{
  contactUs,
  searchSomeThing
}

extension EnumNotificationTypeExtension on EnumNotificationType {
  int get value {
    switch (this) {
      case EnumNotificationType.contactUs:
        return 0;
      case EnumNotificationType.searchSomeThing:
        return 1;

    }
  }
}

enum EnumSqlQueryType{
  get,
  insert,
  update,
  delete
}

extension EnumEnumSqlQueryTypeExtension on EnumSqlQueryType {
  int get value {
    switch (this) {
      case EnumSqlQueryType.get:
        return 0;
      case EnumSqlQueryType.insert:
        return 1;
      case EnumSqlQueryType.update:
        return 2;
      case EnumSqlQueryType.delete:
        return 3;
    }
  }
}
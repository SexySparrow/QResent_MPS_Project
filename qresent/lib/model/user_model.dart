class UserModel {
  String? email;
  String? firstName;
  String? lastName;
  String? accessLevel;
  String? uid;
  String? group;
  List<dynamic>? assignedCourses;

  UserModel({
    this.email,
    this.firstName,
    this.lastName,
    this.assignedCourses,
    this.accessLevel,
    this.uid,
    this.group,
  });

  //Data fetched from firestore
  factory UserModel.fromMap(map) {
    return UserModel(
      email: map["Email"],
      accessLevel: map["AccessLevel"],
      firstName: map["FirstName"],
      lastName: map["LastName"],
      assignedCourses: map["AssignedCourses"],
      uid: map["UID"],
      group: map["Group"],
    );
  }

  // Data sent to firestre
  Map<String, dynamic> toMap() {
    return {
      "Email": email,
      "AccessLevel": accessLevel,
      "FirstName": firstName,
      "LastName": lastName,
      "AssignedCourses": assignedCourses,
      "UID": uid,
      "Group": group,
    };
  }
}

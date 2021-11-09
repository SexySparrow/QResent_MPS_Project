class UserModel {
  String? email;
  String? firstName;
  String? lastName;
  String? accessLevel;

  UserModel({this.email, this.firstName, this.lastName, this.accessLevel});

  //date primite de pe firebase
  factory UserModel.fromMap(map) {
    return UserModel(
      email: map['Email'],
      accessLevel: map['AccessLevel'],
      firstName: map['FirstName'],
      lastName: map['LastName'],
    );
  }

  // date trimise catre firebase
  Map<String, dynamic> toMap() {
    return {
      'Email': email,
      'AccessLevel': accessLevel,
      'FirstName': firstName,
      'LastName': lastName,
    };
  }
}

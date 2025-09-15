class UserDetails {
  final String uid;
   String? email;
   String? password;
  String? firstname;
  String? lastname;
  bool isGuest ;

  UserDetails({
    required this.uid,
    this.email,
     this.password,
    this.firstname,
    this.lastname,
    this.isGuest=true,
  });

  factory UserDetails.fromJson(Map<String, dynamic> json) => UserDetails(
        uid: json["uid"],
        email: json["email"],
        password: json["password"],
        firstname: json["firstName"],
        lastname: json["lastName"],
        isGuest: json["isGuest"],
      );

  Map<String, dynamic> toJson() => {
        "uid": uid,
        "email": email,
        "password": password,
        "firstName": firstname,
        "lastName": lastname,
        "isGuest": isGuest,
      };
  Map<String, dynamic> profileNameToJson() => {
        "firstName": firstname,
        "lastName": lastname,
      };
  UserDetails copyWith({
    String? uid,
    String? email,
    String? password,
    String? firstName,
    String? lastName,
    bool? isGuest,
  }) {
    return UserDetails(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      password: password ?? this.password,
      firstname: firstName ?? this.firstname,
      lastname: lastName ?? this.lastname,
      isGuest: isGuest ?? this.isGuest,
    );
  }
}

class ContactData {

  int? id;
  String name;
  String? phone;
  String? email;
  String? birthday; // YYYY,MM,DD

  ContactData({
    this.id,
    required this.name,
    this.phone,
    this.email,
    this.birthday,
  });

  @override
  String toString() {
    return "{ id=$id, name=$name, phone=$phone, "
        "email=$email, birthday=$birthday }";
  }

}
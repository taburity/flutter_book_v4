class AppointmentData {
  int? id;
  String title;
  String description;
  String apptDate; // YYYY,MM,DD
  String? apptTime; // HH,MM

  AppointmentData({
    this.id,
    required this.title,
    required this.description,
    required this.apptDate,
    this.apptTime,
  });

  @override
  String toString() {
    return "{ id=$id, title=$title, description=$description, "
        "apptDate=$apptDate, apptTime=$apptTime }";
  }
}
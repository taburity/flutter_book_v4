import 'package:flutter/material.dart';
import '../../data/appointments_repository.dart';
import '../../domain/appointment_data.dart';

class AppointmentsViewModel extends ChangeNotifier {
  int _stackIndex = 0;
  int get stackIndex => _stackIndex;
  List<AppointmentData> _appointments = [];
  List<AppointmentData> get appointments => _appointments;
  AppointmentData? entityBeingEdited;
  String? chosenDate;
  String apptTime = '';

  Future<void> loadAppointments() async {
    _appointments = await AppointmentsRepository.db.getAll();
    notifyListeners();
  }

  void startEditing({AppointmentData? appointment}) {
    entityBeingEdited = appointment ?? AppointmentData(title: '', description: '', apptDate: '');
    notifyListeners();
  }

  void setChosenDate(String? date) {
    chosenDate = date;
    notifyListeners();
  }

  void setApptTime(String time) {
    apptTime = time;
    notifyListeners();
  }

  Future<void> save() async {
    if (entityBeingEdited == null) return;
    if (entityBeingEdited!.id == null) {
      await AppointmentsRepository.db.create(entityBeingEdited!);
    } else {
      await AppointmentsRepository.db.update(entityBeingEdited!);
    }
    await loadAppointments();
    setStackIndex(0);
  }

  Future<void> delete(int id) async {
    await AppointmentsRepository.db.delete(id);
    await loadAppointments();
  }

  void setStackIndex(int index) {
    _stackIndex = index;
    notifyListeners();
  }
}

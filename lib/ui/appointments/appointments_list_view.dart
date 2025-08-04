import "package:flutter/material.dart";
import 'package:flutter_slidable/flutter_slidable.dart';
import "package:intl/intl.dart";
import "package:flutter_calendar_carousel/flutter_calendar_carousel.dart";
import "package:flutter_calendar_carousel/classes/event.dart";
import "package:provider/provider.dart";
import "../../data/appointments_repository.dart";
import "../../domain/appointment_data.dart";
import "../../l10n/app_localizations.dart";
import "appointments_view_model.dart";

class AppointmentsListView extends StatelessWidget {
  const AppointmentsListView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = Provider.of<AppointmentsViewModel>(context, listen: false);

    EventList<Event> markedDates = EventList(events: {});
    for (var appointment in vm.appointments) {
      List dateParts = appointment.apptDate.split(",");
      DateTime apptDate = DateTime(int.parse(dateParts[0]),
          int.parse(dateParts[1]), int.parse(dateParts[2]));
      markedDates.add(
        apptDate,
        Event(date: apptDate, icon: Container(decoration: BoxDecoration(color: Colors.blue))),
      );
    }

    return Consumer<AppointmentsViewModel>(
      builder: (context, vm, child) {
        return Scaffold(
          floatingActionButton: FloatingActionButton(
            tooltip: "New activity",
            child: Icon(Icons.add, color: Colors.white),
            onPressed: () {
              vm.startEditing();
              DateTime now = DateTime.now();
              vm.entityBeingEdited!.apptDate = "${now.year},${now.month},${now.day}";
              final localeName = Localizations.localeOf(context).toString();
              vm.setChosenDate(DateFormat.yMMMMd(localeName).format(now.toLocal()));
              vm.setApptTime('');
              vm.setStackIndex(1);
            },
          ),
          body: Column(
            children: [
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  child: CalendarCarousel<Event>(
                    locale: Localizations.localeOf(context).toString(),
                    thisMonthDayBorderColor: Colors.grey,
                    daysHaveCircularBorder: false,
                    markedDatesMap: markedDates,
                    onDayPressed: (DateTime date, List<Event> events) {
                      _showAppointments(date, context);
                    },
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showAppointments(DateTime date, BuildContext context) {
    final vm = Provider.of<AppointmentsViewModel>(context, listen: false);
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Scaffold(
          body: Padding(
            padding: EdgeInsets.all(10),
            child: Column(
              children: [
                Text(
                  DateFormat.yMMMMd(Localizations.localeOf(context).toString()).format(date.toLocal()),
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 24),
                ),
                Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: vm.appointments.length,
                    itemBuilder: (context, index) {
                      final appointment = vm.appointments[index];
                      if (appointment.apptDate != "${date.year},${date.month},${date.day}") {
                        return SizedBox.shrink();
                      }
                      String apptTime = "";
                      if (appointment.apptTime != null) {
                        List timeParts = appointment.apptTime!.split(",");
                        TimeOfDay at = TimeOfDay(
                            hour: int.parse(timeParts[0]),
                            minute: int.parse(timeParts[1]));
                        apptTime = " (${at.format(context)})";
                      }
                      return Slidable(
                        key: ValueKey(appointment.id),
                        endActionPane: ActionPane(
                          motion: ScrollMotion(),
                          extentRatio: 0.25,
                          children: [
                            SlidableAction(
                              onPressed: (_) => _deleteAppointment(context, appointment, vm),
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              icon: Icons.delete,
                              label: 'Delete',
                            ),
                          ],
                        ),
                        child: Container(
                          margin: EdgeInsets.only(bottom: 8),
                          color: Colors.grey.shade300,
                          child: ListTile(
                            title: Text("${appointment.title}$apptTime"),
                            subtitle: Text(appointment.description),
                            onTap: () => _editAppointment(context, appointment, vm),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _editAppointment(BuildContext context, AppointmentData appointment, AppointmentsViewModel vm) async {
    vm.startEditing(appointment: await AppointmentsRepository.db.get(appointment.id!));
    if (vm.entityBeingEdited!.apptDate.isEmpty) {
      vm.setChosenDate('');
    } else {
      List dateParts = vm.entityBeingEdited!.apptDate.split(",");
      DateTime apptDate = DateTime(
          int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
      final localeName = Localizations.localeOf(context).toString();
      vm.setChosenDate(DateFormat.yMMMMd(localeName).format(apptDate.toLocal()));
    }
    if (vm.entityBeingEdited!.apptTime == null) {
      vm.setApptTime('');
    } else {
      List timeParts = vm.entityBeingEdited!.apptTime!.split(",");
      TimeOfDay apptTime = TimeOfDay(hour: int.parse(timeParts[0]), minute: int.parse(timeParts[1]));
      vm.setApptTime(apptTime.format(context));
    }
    vm.setStackIndex(1);
    Navigator.pop(context);
  }

  Future<void> _deleteAppointment(BuildContext context, AppointmentData appointment, AppointmentsViewModel vm) async {
    final l10n = AppLocalizations.of(context)!;
    await vm.delete(appointment.id!);
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.red,
        duration: Duration(seconds: 2),
        content: Text(l10n.delete_msg('Appointment')),
      ),
    );
  }
}

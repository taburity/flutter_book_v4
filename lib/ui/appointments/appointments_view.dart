import "dart:io";
import "package:flutter/material.dart";
import "package:provider/provider.dart";
import "../../data/appointments_repository.dart";
import "appointments_list_view.dart";
import "appointments_entry_view.dart";
import "appointments_view_model.dart";

class Appointments extends StatelessWidget {
  final Directory _docsDir;

  const Appointments({super.key, required Directory docsDir}) : _docsDir = docsDir;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppointmentsViewModel>(
      create: (context) {
        final vm = AppointmentsViewModel();
        AppointmentsRepository.init(_docsDir);
        vm.loadAppointments();
        return vm;
      },
      child: Consumer<AppointmentsViewModel>(
        builder: (context, vm, child) {
          return IndexedStack(
            index: vm.stackIndex,
            children: [
              AppointmentsListView(),
              AppointmentsEntryView(),
            ],
          );
        },
      ),
    );
  }
}

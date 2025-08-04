import "package:flutter/material.dart";

Future selectDate(BuildContext inContext, [String? inDateString]) async {
  print("## globals.selectDate()");

  DateTime initialDate = DateTime.now();
  if (inDateString != null) {
    List dateParts = inDateString.split(",");
    // Usa ano, mês e dia
    initialDate = DateTime(int.parse(dateParts[0]), int.parse(dateParts[1]), int.parse(dateParts[2]));
  }

  DateTime? picked = await showDatePicker(
      context : inContext,
      initialDate : initialDate,
      firstDate : DateTime(1900),
      lastDate : DateTime(2100)
  );

  if (picked != null) {
    return "${picked.year},${picked.month},${picked.day}";
  }
}
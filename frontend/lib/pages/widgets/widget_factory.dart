import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Widget dropDownWidget({
  required List<dynamic> items,
  required dynamic dropdownValue,
  required Function(dynamic) onChanged,
}) {
  var dropdownItems = items.map<DropdownMenuItem<dynamic>>((dynamic value) {
    return DropdownMenuItem<dynamic>(
      child: Text(
        value.name,
      ),
      value: value,
    );
  }).toList();
  return DropdownButton(
    items: dropdownItems,
    value: dropdownValue,
    onChanged: onChanged,
  );
}

Widget decimalFieldWidget({
  required TextEditingController controller,
  required String labelText,
  bool isRequired = true,
}) {
  return textFieldWidget(
    controller: controller,
    labelText: labelText,
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    inputFormatters: <TextInputFormatter>[
      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
    ],
    isRequired: isRequired,
  );
}

Widget textFieldWidget({
  required TextEditingController controller,
  required String labelText,
  TextInputType? keyboardType,
  List<TextInputFormatter>? inputFormatters,
  bool obscureText = false,
  bool isRequired = true,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    decoration: InputDecoration(
      labelText: labelText,
    ),
    keyboardType: keyboardType,
    inputFormatters: inputFormatters,
    validator: (value) {
      if (isRequired && (value == null || value.isEmpty)) {
        return '$labelText is required';
      }
      return null;
    },
  );
}

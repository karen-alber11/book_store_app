import 'package:flutter/material.dart';

class DropDownButtonWidget extends StatelessWidget {
  final String selectedValue;
  final ValueChanged<String?> onChanged;

  const DropDownButtonWidget({
    Key? key,
    required this.selectedValue,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey),
      ),
      child: DropdownButton<String>(
        value: selectedValue,
        isExpanded: true,
        underline: SizedBox(),
        onChanged: onChanged,
        items: ["User", "Librarian", "Admin"].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
      ),
    );
  }
}

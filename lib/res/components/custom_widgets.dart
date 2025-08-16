import 'package:flutter/material.dart';
Widget verticalSpace({required double height}) {
  return SizedBox(
    height: height,
  );
}
Widget horizontalSpace({required double width}) {
  return SizedBox(
    width: width,
  );
}

Widget searchBarWithFilter({
  String hintText = "Szukaj pojazdu",
  VoidCallback? onFilterTap,
  ValueChanged<String>? onChanged,
}) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 12),
    decoration: BoxDecoration(
      border: Border.all(color: Colors.grey.shade400),
      borderRadius: BorderRadius.circular(30),
    ),
    child: Row(
      children: [
        const Icon(Icons.search, color: Colors.grey),
        const SizedBox(width: 8),
        Expanded(
          child: TextField(
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: hintText,
              border: InputBorder.none,
              isDense: true,
            ),
          ),
        ),
        Container(
          height: 24,
          width: 1,
          color: Colors.grey.shade400,
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: onFilterTap,
          child: Icon(Icons.filter_list, color: Colors.grey.shade700),
        ),
      ],
    ),
  );
}




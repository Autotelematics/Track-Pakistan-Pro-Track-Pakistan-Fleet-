import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';

class SearchAndFilterBar extends StatelessWidget {
  final List<String> alertTypes;
  final List<String> vehicles;
  final Function(String?) onVehicleChanged;
  final Function(String?) onAlertTypeChanged;
  final VoidCallback onSearchPressed;

  const SearchAndFilterBar({
    super.key,
    required this.alertTypes,
    required this.vehicles,
    required this.onVehicleChanged,
    required this.onAlertTypeChanged,
    required this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: _DropdownBox(
              hint: "Select Vehicle",
              items: vehicles,
              onChanged: onVehicleChanged,
            ),
          ),
          Expanded(
            child: _DropdownBox(
              hint: "Alert Type",
              items: alertTypes,
              onChanged: onAlertTypeChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _DropdownBox extends StatelessWidget {
  final String hint;
  final List<String> items;
  final Function(String?) onChanged;

  const _DropdownBox({
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton2<String>(
            hint: Text(
              hint,
              style: const TextStyle(color: Colors.grey, fontSize: 13),
            ),
            items: items
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
            buttonStyleData: const ButtonStyleData(
              height: 46,
              padding: EdgeInsets.symmetric(horizontal: 10),
            ),
            dropdownStyleData: DropdownStyleData(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.all(Radius.circular(12)),
              ),
              maxHeight: 250,
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.black54),
            ),
          ),
        ),
      ),
    );
  }
}

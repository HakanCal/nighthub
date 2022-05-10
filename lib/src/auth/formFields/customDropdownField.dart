import 'package:flutter/material.dart';

import 'customChipList.dart';

class CustomDropdownField extends StatefulWidget {
  const CustomDropdownField({
    required this.values,
    required this.hintText,
    required this.options,
    required this.validator,
    required this.onChanged,
  });

  final List<String> values;
  final String hintText;
  final List<String> options;
  final FormFieldValidator<String> validator;
  final Function(String option) onChanged;

  @override
  _CustomDropdownField createState() => _CustomDropdownField();
}

class _CustomDropdownField extends State<CustomDropdownField> {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        DropdownButtonFormField(
            isExpanded: true,
            isDense: true,
            //borderRadius: BorderRadius.circular(30),
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 22, vertical: 18),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 2,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 2,
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(30),
                borderSide: const BorderSide(
                  color: Colors.grey,
                  width: 2,
                ),
              ),
            ),
            icon: const Icon(Icons.arrow_drop_down, color: Colors.blueGrey),
            hint: Text(
              widget.hintText,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.blueGrey,
              ),
            ),
            validator: widget.validator,
            onChanged: (value) {},
            items: widget.options
                .map((String option) => DropdownMenuItem(
                    value: option,
                    child: CustomCheckboxListTile(
                      title: option,
                      onChanged: (_) {
                        widget.onChanged(option);
                      },
                      selected: widget.values.contains(option),
                    )))
                .toList(),
            selectedItemBuilder: (BuildContext context) {
              return widget.options.map<Widget>((String option) {
                return const Text('');
              }).toList();
            }),
        widget.values.isEmpty
            ? const SizedBox(height: 0)
            : const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomChipList(
                values: widget.values,
                chipBuilder: (String value) {
                  return Chip(
                    label: Text(value),
                    onDeleted: () {
                      widget.onChanged(value);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class CustomCheckboxListTile extends StatefulWidget {
  const CustomCheckboxListTile({
    required this.title,
    required this.onChanged,
    required this.selected,
  });

  final String title;
  final dynamic onChanged;
  final bool selected;

  @override
  _CustomCheckboxListTile createState() => _CustomCheckboxListTile();
}

class _CustomCheckboxListTile extends State<CustomCheckboxListTile> {
  late bool _checked;

  @override
  void initState() {
    _checked = widget.selected;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return CheckboxListTile(
      checkColor: Colors.black,
      activeColor: Colors.orange,
      value: _checked,
      selected: _checked,
      title: Text(
        widget.title,
        style: const TextStyle(
          color: Colors.black,
          fontWeight: FontWeight.w700,
        ),
      ),
      controlAffinity: ListTileControlAffinity.leading,
      onChanged: (checked) {
        widget.onChanged(checked);
        setState(() {
          _checked = checked!;
        });
      },
    );
  }
}

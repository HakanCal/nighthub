import 'package:flutter/material.dart';

class CustomChipList extends StatelessWidget {
  const CustomChipList({
    required this.values,
    required this.chipBuilder,
  });

  final List<String> values;
  final Chip Function(String) chipBuilder;

  /// Adds the chips to the list
  List _buildChipList() {
    final List items = [];
    for (String value in values) {
      items.add(chipBuilder(value));
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Wrap(
        spacing: 25,
        children: <Widget>[..._buildChipList()],
      ),
    );
  }
}

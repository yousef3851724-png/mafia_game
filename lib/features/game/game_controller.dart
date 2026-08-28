import 'package:flutter/material.dart';

class BoardTile extends StatelessWidget {
  final String value;
  final VoidCallback onTap;

  const BoardTile({super.key, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        alignment: Alignment.center,
        child: Text(
          value,
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

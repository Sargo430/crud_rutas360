
import 'package:flutter/material.dart';

class BuildSection extends StatelessWidget {
  const BuildSection({
    super.key,
    required this.mainColor,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final Color mainColor;
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: mainColor, width: 4)),
        ),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: mainColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.black54)),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
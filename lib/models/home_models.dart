import 'package:flutter/material.dart';

class DashItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const DashItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

class StatCardData {
  final IconData icon;
  final String title;
  final String? value;
  final Color color;
  final bool isLoading;
  final bool hasError;
  final VoidCallback? onRetry;

  const StatCardData({
    required this.icon,
    required this.title,
    this.value,
    required this.color,
    this.isLoading = false,
    this.hasError = false,
    this.onRetry,
  });
}

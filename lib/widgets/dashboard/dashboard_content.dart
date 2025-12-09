import 'package:flutter/material.dart';

class DashboardContent extends StatelessWidget {
  final Widget child;

  const DashboardContent({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: child,
    );
  }
}

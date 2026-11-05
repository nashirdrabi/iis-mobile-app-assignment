import 'package:flutter/material.dart';

/// Returns to the shared chooser while preserving the signed-in session.
class SwitchExperienceButton extends StatelessWidget {
  const SwitchExperienceButton({super.key, this.color});
  final Color? color;

  @override
  Widget build(BuildContext context) => IconButton(
    tooltip: 'Switch app',
    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
    icon: Icon(Icons.apps_rounded, color: color),
    visualDensity: VisualDensity.compact,
  );
}
